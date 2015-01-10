describe JSONExtractor do
  it 'should correctly extract from a hash' do
    hash = {
      title: 'test',
      to_be_removed: 'test'
    }
    schema = {
      type: Hash,
      name: 'Test hash',
      properties: { title: { type: String, name: 'Test string' } }
    }

    expect(JSONExtractor.new(schema).extract(hash)).to eq(title: 'test')
  end

  it 'should correctly extract from a hash within an array' do
    hash = [{
      title: 'test',
      to_be_removed: 'test'
    }]
    schema = {
      type: Array,
      name: 'Test array',
      items: {
        type: Hash,
        name: 'Test hash',
        properties: { title: { type: String, name: 'Test string' } }
      }
    }

    expect(JSONExtractor.new(schema).extract(hash)).to eq([{ title: 'test' }])
  end

  it 'should not set non existing keys to nil' do
    schema = {
      type: Hash,
      name: 'Test hash',
      properties: { title: { type: String, name: 'Test string' } }
    }

    expect(JSONExtractor.new(schema).extract({})).to eq({})
  end
end
