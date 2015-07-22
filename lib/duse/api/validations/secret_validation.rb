require 'duse/api/validations/model_validation'
require 'duse/api/validations/multi_validation'
require 'duse/api/validations/non_empty_validation'
require 'duse/api/validations/length_between_validation'
require 'duse/api/validations/format_validation'
require 'duse/api/validations/max_length_validation'
require 'duse/api/validations/model_exists_validation'
require 'duse/api/models/folder'

class SecretValidation < ModelValidation
  class TitleValidation < MultiValidation
    validate NonEmptyValidation
    validate LengthBetweenValidation, min: 1, max: 80
  end

  class CipherTextValidation < MultiValidation
    BASE64_REGEX = /^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)$/

    validate NonEmptyValidation, subject_name: 'Cipher'
    validate FormatValidation, format: BASE64_REGEX, msg: 'Cipher is expected to be base64 encoded'
    validate MaxLengthValidation, max: 5000, msg: 'Secret is too long'
  end

  class FolderValidation < MultiValidation
    validate ModelExistsValidation, model_class: Duse::API::Models::Folder, subject_name: 'Folder'
  end

  class ShareValidation
    def initialize(shares_sym, options)
      @shares_sym = shares_sym
      @user   = options[:current_user]
      @server = Duse::API::Models::Server.get
    end

    def validate(secret)
      shares = secret.public_send(@shares_sym)
      errors = []
      if !shares.nil?
        user_ids = extract_user_ids(shares)
        errors << 'Each user must only have one share'    unless user_ids_unique?(user_ids)
        errors << 'Shares for the server must be present' unless user_ids.include? @server.id
        errors << 'Shares for your user must be present'  unless user_ids.include? @user.id

        shares.each do |share|
          unless user_exists? share[:user_id]
            errors << 'One or more of the provided users do not exist'
          end
          if user_exists?(share[:user_id]) && !length_matches_key?(share[:content], Duse::API::Models::User.find(share[:user_id]).public_key)
            errors << 'Public key and share content lengths do not match'
          end
          unless @user.verify_authenticity share[:signature], share[:content]
            errors << 'Authenticity could not be verified. Wrong signature.'
          end
        end
      end
      errors
    end

    private

    def length_matches_key?(share_content, public_key)
      public_key.n.num_bytes == Encryption.decode(share_content).bytes.length
    end

    def user_exists?(user_id)
      Duse::API::Models::User.exists?(user_id)
    end

    def extract_user_ids(shares)
      shares.map { |share| share[:user_id] }
    end

    def user_ids_unique?(user_ids)
      user_ids == user_ids.uniq
    end
  end

  validate TitleValidation, :title
  validate CipherTextValidation, :cipher_text
  validate FolderValidation, :folder_id
  validate ShareValidation, :shares
end

