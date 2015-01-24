class UserValidator
  def validate(user)
    errors = Set.new

    username = user[:username]
    password = user[:password]
    password_confirmation = user[:password_confirmation]
    public_key = user[:public_key]

    if !password.nil? && !password_confirmation.nil? && password != password_confirmation
      errors << 'Password and password confirmation do not match'
    end

    if !password.nil? && !is_password_complex_enough?(password)
      errors << 'Password too weak.'
    end

    if !password.nil? && password.length < 8
      errors << 'Password must be at least 8 characters long'
    end

    if !public_key.nil? && !is_valid_public_key?(public_key)
      errors << 'Public key is not a valid RSA Public Key.'
    end

    if !username.nil? && (username.length < 4 || username.length > 30)
      errors << 'Username must be between 4 and 30 characters'
    end

    if !username.nil? && username !~ /[a-zA-Z0-9_-]+$/
      errors << 'Username must be only letters, numbers, "-" and "_"'
    end

    errors
  end

  private

  def is_password_complex_enough?(password)
    if (/.*[[:punct:]\W]+.*/ =~ password).nil? || # special chars
        (/.*[[:upper:]]+.*/  =~ password).nil? || # upper chars
        (/.*[[:lower:]]+.*/  =~ password).nil? || # lower chars
        (/.*\d+.*/           =~ password).nil?    # digits
      return false
    end
    true
  end

  def is_valid_public_key?(public_key)
    key = OpenSSL::PKey::RSA.new public_key
    fail OpenSSL::PKey::RSAError unless key.public?
    true
  rescue OpenSSL::PKey::RSAError
    false
  end
end
