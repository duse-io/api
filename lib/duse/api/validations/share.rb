require "duse/api/validations/model"
require "duse/api/validations/multi"
require "duse/api/validations/format"
require "duse/api/validations/length_between"

module Duse
  module API
    module Validations
      class Share < Model
        class Id < Multi
          validate ModelExists, model_class: Models::Share
        end

        class Content < Multi
        end

        class Signature < Multi
        end

        validate Id, :id
        validate Content, :content
        validate Signature, :signature
      end
    end
  end
end

