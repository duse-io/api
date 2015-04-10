class SecretValidator
  class TitleValidator
    def validate(secret)
      if !secret.title.nil? && secret.title.empty?
        secret.errors[:base] << 'Title must not be blank'
      end

      if !secret.title.nil? && secret.title.length > 80
        secret.errors[:base] << 'Title must not be longer than 80 characters'
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
          validate_secret_part(secret_part, user_ids, secret.errors[:base])
        end
      end
    end

    private

    def validate_secret_part(secret_part, allowed_user_ids, errors)
      share_user_ids = extract_user_ids(secret_part)
      unless consistent_users?(allowed_user_ids, share_user_ids)
        errors << 'Users referenced in shares do not match in all parts'
      end

      secret_part.each do |share|
        unless user_exists? share[:user_id]
          errors << 'One or more of the provided users do not exist'
        end
        if user_exists?(share[:user_id]) && !length_matches_key?(share[:content], Duse::Models::User.find(share[:user_id]).public_key)
          errors << 'Public key and share content lengths do not match'
        end
        unless @user.verify_authenticity share[:signature], share[:content]
          errors << 'Authenticity could not be verified. Wrong signature.'
        end
      end
    end

    def length_matches_key?(share_content, public_key)
      public_key.n.num_bytes == Encryption.decode(share_content).bytes.length
    end

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
