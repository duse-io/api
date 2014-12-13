require 'validators/json_validator'

describe JSONValidator do

  it 'should work with simple hashes' do
    schema = {
      type: Hash,
      message: 'must be a hash',
      properties: {
        title: { type: String, message: 'Title must be a string' },
        required: { type: Integer, message: 'Required must be an integer' }
      }
    }
    hash = { title: 1, required: 'Test' }
    expect(JSONValidator.validate(hash, schema)).to eq Set.new([
      "Title must be a string",
      "Required must be an integer"
    ])
  end

  it 'should work with nested hashes' do
    schema = {
      type: Hash,
      message: 'must be a hash',
      properties: {
        test_hash: {
          type: Hash,
          message: 'Test hash must be a hash',
          properties: {
            test: { type: String, message: 'Test must be a string' }
          }
        }
      }
    }
    hash = { hash: [1] }
    expect(JSONValidator.validate(hash, schema)).to eq Set.new([
      'Test hash must be a hash'
    ])
    hash = { test_hash: { test: '1' } }
    expect(JSONValidator.validate(hash, schema)).to eq Set.new
  end

  it 'should work with nested arrays' do
    schema = {
      type: Array,
      message: 'must be an array',
      items: {
        type: Array,
        message: 'items must be an array',
        items: {
          type: Integer,
          message: 'items must be integers'
        }
      }
    }
    array = [{test: 1}]
    expect(JSONValidator.validate(array, schema)).to eq Set.new([
      'items must be an array'
    ])
    expect(JSONValidator.validate([[1]], schema)).to eq Set.new
  end

end

#{
#  type: Hash
#  message: 'Secret must be an object'
#  properties: {
#    title:    { type: String,  message: 'Title must be a string' }
#    required: { type: Integer, message: 'Required must be an integer' }
#    parts: {
#      type: Array,
#      message: 'Parts must be an array',
#      items: {
#        type: Array,
#        message: 'A part must be an array',
#        items: {
#          type: Hash,
#          message: 'A share must be an object',
#          properties: {
#            user_id:   { type: [String, Integer], message: 'User id must be "me", "server", or the users id' },
#            content:   { type: String, message: 'Content must be a string' },
#            signature: { type: String, message: 'Signature must be a string' }
#          }
#        }
#      }
#    }
#  }
#}
