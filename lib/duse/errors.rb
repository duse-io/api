module Duse
  class ValidationFailed < StandardError; end
  class NotFound < StandardError; end
  class AlreadyConfirmed < StandardError; end
  class UserNotConfirmed < StandardError; end
end

