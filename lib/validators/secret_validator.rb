class SecretValidator
  def self.validate_json(secret)
    errors = Set.new

    secret_parts = secret[:parts]

    # malformed
    errors << 'Secret parts must be an array' unless secret_parts.is_a? Array
    errors << 'Amount of secret parts is smaller than required to decrypt' if secret_parts.first.length < secret[:required]

    user_ids = extract_user_ids(secret_parts.first)
    errors << 'Shares for the server must be present' unless user_ids.include? 'server'
    errors << 'Shares for your user must be present' unless user_ids.include? 'me'

    secret_parts.each do |secret_part|
      share_user_ids = extract_user_ids(secret_part)
      errors << 'Users referenced in secret parts do not match in all parts' unless (user_ids - share_user_ids).empty?

      # check for malformed when secret_part is not an array

      share_user_ids.each do |user_id|
        next if 'server' == user_id
        next if 'me'     == user_id
        if User.get(user_id).nil?
          errors << 'One or more of the provided users do not exist'
        end
      end
    end

    errors
  end

  def self.extract_user_ids(shares)
    shares.map { |share| share[:user_id] }
  end
end
