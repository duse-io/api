class SecretValidator
  def initialize(options)
    @user   = options[:current_user]
    @server = Duse::Models::Server.get
  end

  def validate(secret)
    errors = Set.new

    errors << 'Title must not be blank' if !secret[:title].nil? && secret[:title].empty?

    secret_parts = secret[:parts]

    unless secret_parts.nil?
      user_ids = extract_user_ids(secret_parts.first)
      errors << 'Each user must only have one share'    unless user_ids_unique?(user_ids)
      errors << 'Shares for the server must be present' unless user_ids.include? @server.id
      errors << 'Shares for your user must be present'  unless user_ids.include? @user.id

      secret_parts.each do |secret_part|
        share_user_ids = extract_user_ids(secret_part)
        unless consistent_users?(user_ids, share_user_ids)
          errors << 'Users referenced in shares do not match in all parts'
        end

        secret_part.each do |share|
          unless user_exists? share[:user_id]
            errors << 'One or more of the provided users do not exist'
          end
          unless @user.verify_authenticity share[:signature], share[:content]
            errors << 'Authenticity could not be verified. Wrong signature.'
          end
        end
      end
    end

    errors
  end

  private

  def user_exists?(user_id)
    Duse::Models::User.exists?(user_id)
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

