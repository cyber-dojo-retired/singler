require_relative 'singler'
require_relative 'external_bash_sheller'
require_relative 'external_disk_writer'
require_relative 'external_id_generator'
require_relative 'external_id_validator'
require_relative 'external_stdout_logger'

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
  def id_validator=(arg)
    @id_validator = arg
  end

  def logger
    @logger ||= ExternalStdoutLogger.new(self)
  end
  def logger=(arg)
    @logger = arg
  end

  def shell
    @shell ||= ExternalBashSheller.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new(self)
  end

end
