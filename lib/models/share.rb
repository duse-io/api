class Share
  include DataMapper::Resource

  property :content, Text, required: true
  property :signature, Text, required: true

  belongs_to :secret_part, key: true
  belongs_to :user,        key: true

  validates_with_method :signature, method: :validate_signature

  private

  def validate_signature
    last_edited_by = self.secret_part.secret.last_edited_by
    key = OpenSSL::PKey::RSA.new last_edited_by.public_key
    digest = OpenSSL::Digest::SHA256.new
    unless key.verify digest, self.signature, self.content
      return [false, 'Authenticity could not be verified. Wrong signature.']
    end
    true
  end
end
