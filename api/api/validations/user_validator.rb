class UserValidator
  def validate(user)
    errors = Set.new

    unless user[:password] == user[:password_confirmation]
      errors << 'Password and password confirmation do not match'
    end

    unless is_password_complex_enough? user[:password]
      errors << 'Password too weak.'
    end

    unless user[:password].length >= 8
      errors << 'Password must be at least 8 characters long'
    end

    unless is_valid_public_key? user[:public_key]
      errors << 'Public key is not a valid RSA Public Key.'
    end

    if user[:username].length < 4 || user[:username].length > 30
      errors << 'Username must be between 4 and 30 characters'
    end

    unless user[:username] =~ /[a-zA-Z0-9_-]+$/
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
