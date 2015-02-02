describe JSONExtractor do
  it 'should generate json by calling the appropriate methods by default' do
    test_class = Class.new(JSONView)
    test_class.property :test_string
    test_class.property :test_integer

    subject = OpenStruct.new({ test_string: 'test', test_integer: 1 })

    expect(test_class.new(subject).serialize_as_json).to eq({
      test_string: 'test',
      test_integer: 1
    }.to_json)
  end

  it 'should call the block for a properties value when a block is defined' do
    test_class = Class.new(JSONView)
    test_class.property :test_string
    test_class.property :test_integer do |_, _|
      1
    end

    subject = OpenStruct.new({ test_string: 'test' })

    expect(test_class.new(subject).serialize_as_json).to eq({
      test_string: 'test',
      test_integer: 1
    }.to_json)
  end

  it 'should extract properties according to the type' do
    test_class = Class.new(JSONView)
    test_class.property :test_string, type: :full
    test_class.property :test_integer

    subject = OpenStruct.new({ test_string: 'test', test_integer: 1 })

    expect(test_class.new(subject, type: :full).serialize_as_json).to eq({
      test_string: 'test',
      test_integer: 1
    }.to_json)
  end

  it 'should ignore properties that do not match the type' do
    test_class = Class.new(JSONView)
    test_class.property :test_string, type: :full
    test_class.property :test_integer

    subject = OpenStruct.new({ test_string: 'test', test_integer: 1 })

    expect(test_class.new(subject).serialize_as_json).to eq({
      test_integer: 1
    }.to_json)
  end
end

