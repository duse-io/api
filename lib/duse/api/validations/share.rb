require "duse/api/validations/model"
require "duse/api/validations/multi"
require "duse/api/validations/format"
require "duse/api/validations/length_between"

module Duse
  module API
    module Validations
      class Share < Model
        class BelongsToCurrentUser
          include Single

          def invalid?(share_id)
            !belongs_to_current_user?(Models::Share.find_by_id(share_id))
          end

          def belongs_to_current_user?(share)
            share.nil? || share.user == options[:current_user]
          end

          def error_msg
            "Share does not belong to you."
          end
        end

        class Id < Multi
          validate ModelExists, model_class: Models::Share
          validate BelongsToCurrentUser
        end

        class CipherValidation
          attr_reader :current_user
          private :current_user

          def initialize(options)
            @current_user = options[:current_user]
          end

          def validate(share)
            errors = []

            if !current_user.length_matches_key?(share.content)
              errors << "Authenticity could not be verified. Wrong signature."
            end

            if !current_user.verify_authenticity(share.signature, share.content)
              errors << "Authenticity could not be verified. Wrong signature."
            end

            errors
          end
        end

        validate Id, :id
        validate CipherValidation
      end
    end
  end
end

