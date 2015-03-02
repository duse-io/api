describe JSONExtractor do
  it 'should correctly extract from a hash' do
    hash = {
      title: 'test',
      to_be_removed: 'test'
    }
    schema = JSONSchema.new({
      type: Hash,
      name: 'Test hash',
      properties: { title: { type: String, name: 'Test string' } }
    })

    expect(JSONExtractor.new(schema).extract(hash)).to eq(title: 'test')
  end

  it 'should correctly extract from a hash within an array' do
    hash = [{
      title: 'test',
      to_be_removed: 'test'
    }]
    schema = JSONSchema.new({
      type: Array,
      name: 'Test array',
      items: {
        type: Hash,
        name: 'Test hash',
        properties: { title: { type: String, name: 'Test string' } }
      }
    })

    expect(JSONExtractor.new(schema).extract(hash)).to eq([{ title: 'test' }])
  end

  it 'should not set non existing keys to nil' do
    schema = JSONSchema.new({
      type: Hash,
      name: 'Test hash',
      properties: {
        title: { type: String, name: 'Test string' },
        descr: { type: String, name: 'Test string' },
      }
    })

    hash = { title: 'test', something: 'remove this' }
    expect(JSONExtractor.new(schema).extract(hash)).to eq({ title: 'test' })
  end

  it 'should not set an array to empty array it does not exist' do
    schema = JSONSchema.new({
      type: Hash,
      name: 'Test hash',
      properties: {
        title: { type: String, name: 'Test string' },
        array: {
          type: Array,
          name: 'Test array',
          items: { type: String, name: 'Test inner string' }
        },
      }
    })

    hash = { title: 'test' }
    expect(JSONExtractor.new(schema).extract(hash)).to eq({ title: 'test' })
  end

  it 'should keep correct values' do
    schema = JSONSchema.new({
      type: Hash,
      name: 'Test hash',
      properties: { title: { type: String, name: 'Test string' } }
    })

    expect(JSONExtractor.new(schema).extract({title: 'test'})).to eq({title: 'test'})
  end
end

