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
end
