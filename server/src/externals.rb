require_relative 'singler'
require_relative 'external_disk_writer'

class Externals

  def singler
    @singler ||= Singler.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

end
