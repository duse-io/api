class SecretValidator
  def self.validate_json(secret)
    errors = []

    secret_parts = secret[:parts]

    # malformed
    errors << 'Secret parts must be an array' unless secret_parts.is_a? Array
    errors << 'Amount of secret parts is smaller than required to decrypt' if secret_parts.length < secret[:required]

    keys = secret_parts.first.keys
    secret_parts.each do |secret_part|
      errors << 'Users referenced in secret parts do not match in all parts' unless (keys - secret_part.keys).empty?
      errors << 'Shares for the server must be present' unless secret_part.has_key? Model::User.first(username: 'server').id.to_s

      # check for malformed when secret_part is not an array

      secret_part.each do |user_id, share|
        user = Model::User.get user_id
        errors << 'One or more of the provided users do not exist' if user.nil?
      end
    end

    errors.uniq
  end
end
