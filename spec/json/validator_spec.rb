describe JSONValidator do
  it 'should work with simple hashes' do
    schema = {
      type: Hash,
      name: 'Test hash',
      properties: {
        title:    { type: String,  name: 'Title' },
        required: { type: Integer, name: 'Required' }
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
      name: 'Test hash',
      properties: {
        test_hash: {
          type: Hash,
          name: 'Nested test hash',
          properties: {
            test: { type: String, name: 'Test' }
          }
        }
      }
    }
    hash = { test_hash: [1] }
    expect(JSONValidator.validate(hash, schema)).to eq Set.new([
      'Nested test hash must be a hash'
    ])
    hash = { test_hash: { test: '1' } }
    expect(JSONValidator.validate(hash, schema)).to eq Set.new
  end

  it 'should work with nested arrays' do
    schema = {
      type: Array,
      name: 'Test array',
      items: {
        type: Array,
        name: 'Test items',
        items: {
          type: Integer,
          name: 'Test item'
        }
      }
    }
    array = [{test: 1}]
    expect(JSONValidator.validate(array, schema)).to eq Set.new([
      'Test items must be an array'
    ])
    expect(JSONValidator.validate([[1]], schema)).to eq Set.new
  end

  it 'should handle multiple types' do
    schema = {
      name: 'Test hash',
      type: Hash,
      properties: {
        property: {
          name: 'Test property',
          type: [String, Integer],
          message: 'Test property must be string or integer'
        }
      }
    }

    expect(JSONValidator.validate({property: 1},   schema)).to eq Set.new
    expect(JSONValidator.validate({property: '1'}, schema)).to eq Set.new
    expect(JSONValidator.validate({property: 1.0}, schema)).to eq Set.new([
      'Test property must be string or integer'
    ])
  end

  it 'should check for presence by default' do
    schema = {
      name: 'Test hash',
      type: Hash,
      properties: {
        property: {
          name: 'Test property',
          type: String,
          message: 'Test property must be a string'
        }
      }
    }

    expect(JSONValidator.validate({}, schema)).to eq Set.new([
      'Test property must not be blank'
    ])
  end
end
