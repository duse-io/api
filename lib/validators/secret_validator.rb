class SecretValidator
  def self.validate(secret)
    errors = Set.new

    secret_parts = secret[:parts]

    if secret_parts.first.length < secret[:required]
      errors << 'Amount of secret parts is smaller than required to decrypt'
    end

    user_ids = extract_user_ids(secret_parts.first)
    errors << 'Shares for the server must be present' unless user_ids.include? 'server'
    errors << 'Shares for your user must be present'  unless user_ids.include? 'me'

    secret_parts.each do |secret_part|
      share_user_ids = extract_user_ids(secret_part)
      unless consistent_users?(user_ids, share_user_ids)
        errors << 'Users referenced in shares do not match in all parts'
      end

      share_user_ids.each do |user_id|
        unless user_exists? user_id
          errors << 'One or more of the provided users do not exist'
        end
      end
    end

    errors
  end

  def self.user_exists?(user_id)
    'server' != user_id || 'me' != user_id || User.get(user_id).nil?
  end

  def self.consistent_users?(allowed_users, requested_users)
    (allowed_users - requested_users).empty?
  end

  def self.extract_user_ids(shares)
    shares.map { |share| share[:user_id] }
  end
end
