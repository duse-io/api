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
    expect(JSONValidator.new(schema).validate(hash)).to eq Set.new([
      'Title must be a string',
      'Required must be an integer'
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
    validator = JSONValidator.new(schema)
    hash = { test_hash: [1] }
    expect(validator.validate(hash)).to eq Set.new([
      'Nested test hash must be a hash'
    ])
    hash = { test_hash: { test: '1' } }
    expect(validator.validate(hash)).to eq Set.new
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
    array = [{ test: 1 }]
    validator = JSONValidator.new(schema)
    expect(validator.validate(array)).to eq Set.new([
      'Test items must be an array'
    ])
    expect(validator.validate([[1]])).to eq Set.new
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

    expect(JSONValidator.new(schema).validate({})).to eq Set.new([
      'Test property must not be blank'
    ])
  end

  it 'should not be in strict mode when setting it to false' do
    expect(JSONValidator.new({}, strict: false).strict?).to be false
  end

  it 'should ignore not required flags when not in strict mode' do
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

    expect(JSONValidator.new(schema, strict: false) .validate({})).to eq Set.new
  end
end

