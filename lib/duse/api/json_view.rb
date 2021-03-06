require "json"

class JSONView
  class Property
    attr_reader :name

    def initialize(name, options = {}, value_block)
      @name        = name
      @options     = options
      @value_block = value_block
    end

    def value_for(subject, options)
      value = @value_block.call(subject, options)
      return render_nested_view(value, options) if nested?
      value
    end

    def show?(subject, options)
      return eval_if_condition(subject) if @options.key?(:if)
      return true if type.nil?
      return type == options[:type]
    end

    def type
      @options[:type]
    end

    def eval_if_condition(subject)
      if @options.key?(:if) && @options[:if] == :not_nil
        return !subject[name].nil?
      end
      @options[:if].call(subject)
    end

    def nested?
      !!nested_view
    end

    def nested_view
      @options[:as]
    end

    def render_nested_view(value, options)
      options = options.merge({ type: @options[:render_type] }) if @options.key? :render_type
      nested_view.new(value, options).render
    end
  end

  attr_reader :subject
  attr_reader :options

  def initialize(subject, options = {})
    @subject = subject
    @options = options
  end

  def render
    return convert_to_hash(subject) unless subject.respond_to? :to_ary
    subject.map do |s|
      convert_to_hash(s)
    end
  end

  private

  def convert_to_hash(object)
    result = {}
      
    properties.each do |property|
      if property.show?(object, options)
        result[property.name] = property.value_for object, options
      end
    end

    result
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

