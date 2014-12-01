class Share
  include DataMapper::Resource

  property :content,   Text, required: true
  property :signature, Text, required: true

  belongs_to :secret_part, key: true
  belongs_to :user,        key: true

  validates_with_method :signature, method: :validate_signature

  private

  def validate_signature
    last_edited_by = secret_part.secret.last_edited_by
    unless last_edited_by.verify_authenticity signature, content
      return [false, 'Authenticity could not be verified. Wrong signature.']
    end
    true
  end
end
