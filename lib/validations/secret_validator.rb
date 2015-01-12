class SecretValidator
  def initialize(current_user)
    @user_id   = current_user.id
    @server_id = Server.get.id
  end

  def validate(secret)
    errors = Set.new

    secret_parts = secret[:parts]

    unless secret_parts.nil?
      user_ids = extract_user_ids(secret_parts.first)
      errors << 'Each user must only have one share'    unless user_ids_unique?(user_ids)
      errors << 'Shares for the server must be present' unless user_ids.include? @server_id.to_s
      errors << 'Shares for your user must be present'  unless user_ids.include? @user_id.to_s

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
    end

    errors
  end

  private

  def user_exists?(user_id)
    !User.get(user_id).nil?
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
