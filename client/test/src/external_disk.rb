
class ExternalDisk

  def initialize(_parent)
  end

  def [](name)
    ExternalDir.new(name)
  end

end

# - - - - - - - - - - - - - - - - - - - - -

class ExternalDir

  def initialize(path)
    @path = path
    @path += '/' unless @path.end_with?('/')
  end

  attr_reader :path

  def read_json(filename)
    JSON.parse(read(filename))
  end

  def read(filename)
    IO.read(path + filename)
  end

end
