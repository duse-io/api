class SecretValidator
  def self.validate_json(secret)
    errors = Set.new

    secret_parts = secret[:parts]

    # malformed
    errors << 'Secret parts must be an array' unless secret_parts.is_a? Array
    errors << 'Amount of secret parts is smaller than required to decrypt' if secret_parts.length < secret[:required]

    keys = secret_parts.first.keys
    secret_parts.each do |secret_part|
      errors << 'Users referenced in secret parts do not match in all parts' unless (keys - secret_part.keys).empty?
      errors << 'Shares for the server must be present' unless secret_part.key? 'server'

      # check for malformed when secret_part is not an array

      secret_part.keys.each do |user_id|
        if 'server' != user_id && Model::User.get(user_id).nil?
          errors << 'One or more of the provided users do not exist'
        end
      end
    end

    errors
  end
end
