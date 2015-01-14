class UserJSON < DefaultJSON
  def schema
    {
      type: Hash,
      message: 'User must be an object',
      properties: {
        username:              { type: String, name: 'Username' },
        password:              { type: String, name: 'Password' },
        password_confirmation: { type: String, name: 'Password confirmation' },
        public_key:            { type: String, name: 'Public key' }
      }
    }
  end
end
