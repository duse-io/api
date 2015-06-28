class FolderValidator
  class NameValidator
    def validate(folder)
      if !folder.name.nil? && folder.name !~ /[a-zA-Z0-9]/
        folder.errors[:base] << 'Folder name contains illegal characters'
      end
      if !folder.name.nil? && !folder.name.length.between?(1, 50)
        folder.errors[:base] << 'Folder name must be between 1 and 50 characters long'
      end
    end
  end

  class Folder
    include ActiveModel::Model

    attr_accessor :name

    validate do |folder|
      NameValidator.new.validate(folder)
    end
  end

  def initialize(options = {})
    @options = options
  end

  def validate(folder)
    folder = Folder.new(folder)
    folder.valid?
    folder.errors.full_messages
  end
end

