class TitleValidator
  def validate(secret)
    if !secret.title.nil? && secret.title.empty?
      secret.errors[:base] << 'Title must not be blank'
    end
  end
end

class SecretPartsValidator
  def initialize(options)
    @user, @server = options[:required_users]
  end

  def validate(secret)
    secret_parts = secret.parts
    unless secret_parts.nil?
      user_ids = extract_user_ids(secret_parts.first)
      secret.errors[:base] << 'Each user must only have one share'    unless user_ids_unique?(user_ids)
      secret.errors[:base] << 'Shares for the server must be present' unless user_ids.include? @server.id
      secret.errors[:base] << 'Shares for your user must be present'  unless user_ids.include? @user.id

      secret_parts.each do |secret_part|
        share_user_ids = extract_user_ids(secret_part)
        unless consistent_users?(user_ids, share_user_ids)
          secret.errors[:base] << 'Users referenced in shares do not match in all parts'
        end

        secret_part.each do |share|
          unless user_exists? share[:user_id]
            secret.errors[:base] << 'One or more of the provided users do not exist'
          end
          unless @user.verify_authenticity share[:signature], share[:content]
            secret.errors[:base] << 'Authenticity could not be verified. Wrong signature.'
          end
        end
      end
    end
  end

  private

  def user_exists?(user_id)
    Duse::Models::User.exists?(user_id)
  end

  def consistent_users?(allowed_users, requested_users)
    (allowed_users - requested_users).empty?
  end

  def extract_user_ids(shares)
    shares.map { |share| share[:user_id] }
  end

  def user_ids_unique?(user_ids)
    user_ids == user_ids.uniq
  end
end

class SecretValidator
  class Secret
    include ActiveModel::Model

    attr_accessor :title, :parts

    def validation_options
      @validation_options ||= {}
    end

    validate do |secret|
      TitleValidator.new.validate(secret)
      SecretPartsValidator.new(validation_options).validate(secret)
    end
  end

  def initialize(options)
    @user   = options[:current_user]
    @server = Duse::Models::Server.get
  end

  def validate(secret)
    secret = Secret.new(secret)
    secret.validation_options[:required_users] = [@user, @server]
    secret.valid?
    secret.errors.full_messages
  end
end

