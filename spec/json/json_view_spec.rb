describe JSONExtractor do
  it 'should generate json by calling the appropriate methods by default' do
    test_class = Class.new(JSONView)
    test_class.property :test_string
    test_class.property :test_integer

    subject = OpenStruct.new({ test_string: 'test', test_integer: 1 })

    expect(test_class.new(subject).render).to eq({
      test_string: 'test',
      test_integer: 1
    })
  end

  it 'should call the block for a properties value when a block is defined' do
    test_class = Class.new(JSONView)
    test_class.property :test_string
    test_class.property :test_integer do |_, _|
      1
    end

    subject = OpenStruct.new({ test_string: 'test' })

    expect(test_class.new(subject).render).to eq({
      test_string: 'test',
      test_integer: 1
    })
  end

  it 'should extract properties according to the type' do
    test_class = Class.new(JSONView)
    test_class.property :test_string, type: :full
    test_class.property :test_integer

    subject = OpenStruct.new({ test_string: 'test', test_integer: 1 })

    expect(test_class.new(subject, type: :full).render).to eq({
      test_string: 'test',
      test_integer: 1
    })
  end

  it 'should ignore properties that do not match the type' do
    test_class = Class.new(JSONView)
    test_class.property :test_string, type: :full
    test_class.property :test_integer

    subject = OpenStruct.new({ test_string: 'test', test_integer: 1 })

    expect(test_class.new(subject).render).to eq({
      test_integer: 1
    })
  end

  it 'should serialize arrays of objects correctly' do
    test_class = Class.new(JSONView)
    test_class.property :test_string
    test_class.property :test_integer

    subject = []
    subject << OpenStruct.new({ test_string: 'test1', test_integer: 1 })
    subject << OpenStruct.new({ test_string: 'test2', test_integer: 2 })

    expect(test_class.new(subject).render).to eq([
      {
        test_string: 'test1',
        test_integer: 1
      },
      {
        test_string: 'test2',
        test_integer: 2
      },
    ])
  end

  it 'should serialize active relations correctly' do
    test_class = Class.new(JSONView)
    test_class.property :test_string
    test_class.property :test_integer

    subject = Duse::Models::Secret.all

    expect(test_class.new(subject).render).to eq([])
  end

  it 'should serialize active relations correctly' do
    inner_test_class = Class.new(JSONView)
    inner_test_class.property :inner_test_string
    inner_test_class.property :inner_test_integer
    test_class = Class.new(JSONView)
    test_class.property :test_string
    test_class.property :inner_object, as: inner_test_class

    subject = OpenStruct.new({
      test_string: 'test',
      inner_object: OpenStruct.new({
        inner_test_string: 'inner_test',
        inner_test_integer: 1
      })
    })

    expect(test_class.new(subject).render).to eq({
      test_string: 'test',
      inner_object: {
        inner_test_string: 'inner_test',
        inner_test_integer: 1
      }
    })
  end
end

