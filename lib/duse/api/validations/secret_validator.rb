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

  class CipherTextValidator
    BASE64_REGEX = /^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)$/

    def validate(secret)
      if !secret.cipher_text.nil? && secret.cipher_text.empty?
        secret.errors[:base] << 'Cipher text must not be blank'
      end
      if !secret.cipher_text.nil? && !secret.cipher_text.empty? && secret.cipher_text !~ BASE64_REGEX
        secret.errors[:base] << 'Cipher is expected to be base64 encoded'
      end
      if !secret.cipher_text.nil? && !secret.cipher_text.empty? && secret.cipher_text.length > 5000
        secret.errors[:base] << 'Secret too long'
      end
    end
  end

  class SharesValidator
    def initialize(options)
      @user, @server = options[:required_users]
    end

    def validate(secret)
      shares = secret.shares
      unless shares.nil?
        user_ids = extract_user_ids(shares)
        secret.errors[:base] << 'Each user must only have one share'    unless user_ids_unique?(user_ids)
        secret.errors[:base] << 'Shares for the server must be present' unless user_ids.include? @server.id
        secret.errors[:base] << 'Shares for your user must be present'  unless user_ids.include? @user.id
        secret.errors[:base] << 'Number of participants must be ten or less' if shares.length > 10

        shares.each do |share|
          unless user_exists? share[:user_id]
            secret.errors[:base] << 'One or more of the provided users do not exist'
          end
          if user_exists?(share[:user_id]) && !length_matches_key?(share[:content], Duse::Models::User.find(share[:user_id]).public_key)
            secret.errors[:base] << 'Public key and share content lengths do not match'
          end
          unless @user.verify_authenticity share[:signature], share[:content]
            secret.errors[:base] << 'Authenticity could not be verified. Wrong signature.'
          end
        end
      end
    end

    private

    def length_matches_key?(share_content, public_key)
      public_key.n.num_bytes == Encryption.decode(share_content).bytes.length
    end

    def user_exists?(user_id)
      Duse::Models::User.exists?(user_id)
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

    attr_accessor :title, :shares, :cipher_text

    def validation_options
      @validation_options ||= {}
    end

    validate do |secret|
      TitleValidator.new.validate(secret)
      CipherTextValidator.new.validate(secret)
      SharesValidator.new(validation_options).validate(secret)
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

