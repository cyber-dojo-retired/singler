
class Singler

  def initialize(externals)
    @externals = externals
    @path = '/resistent-dir/iids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  def iid
    iid_generator.generate
  end

  def exists?(iid)
    iid_dir(iid).exists?
  end

  private

  def iid_generator
    @externals.iid_generator
  end

  def iid_dir(iid)
    disk[iid_path(iid)]
  end

  def iid_path(iid)
    dir_join(path, outer(iid), inner(iid))
  end

  def outer(iid)
    iid[0..1]  # eg 'e5' 2-chars long
  end

  def inner(iid)
    iid[2..-1] # eg '6aM327PE' 8-chars long
  end

  # - - - - - - - - - - - - - -

  def dir_join(*args)
    File.join(*args)
  end

  def disk
    @externals.disk
  end

end
