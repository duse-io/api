class JSONSchema
  attr_reader :items

  def initialize(schema, name = nil)
    @schema = schema
    @name = name

    if nested?
      if hash?
        properties.each_key do |key|
          name = key.to_s.capitalize
          properties[key] = JSONSchema.new properties[key], name
        end
      end
      if array?
        @items = JSONSchema.new @schema[:items]
      end
    end
  end

  def nested?
    hash? || array?
  end

  def hash?
    type == Hash
  end

  def array?
    type == Array
  end

  def allow_empty?
    @schema.fetch :allow_empty, true
  end

  def optional?
    @schema.fetch :optional, false
  end

  def properties
    @schema[:properties]
  end

  def type
    @schema[:type]
  end

  def message
    @schema[:message]
  end

  def name
    @schema[:name] || @name
  end
end

