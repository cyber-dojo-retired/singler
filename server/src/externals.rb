require_relative 'singler'
require_relative 'external_disk_writer'
require_relative 'external_id_generator'
require_relative 'external_id_validator'

class Externals

  def singler
    @singler ||= Singler.new(self)
  end

  def id_generator
    @id_generator ||= ExternalIdGenerator.new(self)
  end

  def id_validator
    @id_validator ||= ExternalIdValidator.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

end
