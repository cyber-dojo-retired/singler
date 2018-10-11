require 'open3'

class ExternalDirWriter

  def initialize(name)
    @name = name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def exists?
    File.directory?(name)
  end

  def make
    # Returns true iff the dir does not already exist
    # and is made. Can't find a Ruby library method
    # that does this, so using shell.
    # Note: FileUtils.mkdir_p() does not tell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    stdout,stderr,r = Open3.capture3("mkdir -vp #{name}")
    status = r.exitstatus
    stdout != '' && stderr == '' && status == 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def append(filename, content)
    File.open(pathed(filename), 'a') { |fd| fd.write(content) }
  end

  def write(filename, content)
    File.open(pathed(filename), 'w') { |fd| fd.write(content) }
  end

  def read(filename)
    File.open(pathed(filename), 'r') { |fd| fd.read }
  end

  private

  attr_reader :name

  def pathed(filename)
    File.join(name, filename)
  end

end