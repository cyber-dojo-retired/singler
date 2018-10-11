require_relative 'singler'
require_relative 'external_disk_writer'
require_relative 'external_id_generator'
require_relative 'external_id_validator'

class Externals

  def singler
    @singler ||= Singler.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

  def id_generator
    @id_generator ||= ExternalIdGenerator.new(self)
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_validator
    @id_validator ||= ExternalIdValidator.new(self)
  end

  def kata_dir(id, index=nil)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/porter
    args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
    unless index.nil?
      args << index.to_s
    end
    disk[File.join(*args)]
  end

end
