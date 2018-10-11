require_relative 'singler'
require_relative 'external_disk_writer'

class Externals

  def singler
    @singler ||= Singler.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

  # - - - - - - - - - - - - - - - - - - -

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
