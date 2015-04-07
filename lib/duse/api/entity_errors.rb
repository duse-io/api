class EntityErrors
  def initialize(errors_to_ignore = [])
    @errors_to_ignore = errors_to_ignore
  end

  def collect_from(entities)
    errors = Set.new

    entities.each do |entity|
      errors = errors.merge entity.errors.full_messages unless entity.valid?
    end

    errors.subtract @errors_to_ignore
  end
end

