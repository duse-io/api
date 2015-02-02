require 'json'

class JSONView
  class Property
    attr_reader :name

    def initialize(name, options = {}, value_block)
      @name        = name
      @options     = options
      @value_block = value_block
    end

    def value_for(subject, options)
      @value_block.call(subject, options)
    end

    def show?(subject, options)
      return true if type.nil?
      return type == options[:type]
    end

    def type
      @options[:type]
    end
  end

  attr_reader :subject
  attr_reader :options

  def initialize(subject, options = {})
    @subject = subject
    @options = options
  end

  def serialize_as_json
    result = {}
      
    properties.each do |property|
      if property.show?(subject, options)
        result[property.name] = property.value_for subject, options
      end
    end

    result.to_json
  end

  def properties
    self.class.properties
  end

  class << self
    def property(name, options = {}, &block)
      block ||= ->(subject, _) { subject.public_send(name) }
      properties << Property.new(name, options, block)
    end

    def properties
      @properties ||= []
    end
  end
end

