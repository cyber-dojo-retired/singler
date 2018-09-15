
class ExternalDisk

  def initialize(externals)
    @externals = externals
  end

  def dir?(name)
    File.directory?(name)
  end

  def [](name)
    ExternalDir.new(@externals, self, name)
  end

end

# - - - - - - - - - - - - - - - - - - - - -

class ExternalDir

  def initialize(externals, disk, path)
    @externals = externals
    @disk = disk
    @path = path
    @path += '/' unless @path.end_with?('/')
  end

  attr_reader :path

  def exists?(filename = nil)
    return File.directory?(path) if filename.nil?
    return File.exist?(path + filename)
  end

  def make
    # Can't find a Ruby library method allowing you to do a
    # mkdir_p and know if a dir was created or not. So using shell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    output,_exit_status = shell.exec("mkdir -vp #{path}")
    output != ''
  end

  def write_json(filename, json)
    write(filename, JSON.unparse(json))
  end

  def write(filename, content)
    IO.write(path + filename, content)
  end

  def read_json(filename)
    JSON.parse(read(filename))
  end

  def read(filename)
    IO.read(path + filename)
  end

  private # = = = = = = = = = = = = = = =

  def shell
    @externals.shell
  end

end
