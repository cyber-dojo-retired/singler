
class Singler

  def initialize(externals)
    @externals = externals
    @path = '/persistent-dir/iids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  def exists?(iid)
    iid_dir(iid).exists?
  end

  def create(manifest)
    # Generates an iid, puts it in the manifest,
    # saves the manifest, and returns the iid.
    # Rack calls create() in threads so in theory
    # you could get a race condition with both
    # threads attempting a create with the same id.
    # Assuming base58 id generation is reasonably well
    # behaved (random) this is extremely unlikely.
    iid = iid_generator.generate
    manifest['id'] = iid
    dir = iid_dir(iid)
    dir.make
    dir.write(manifest_filename, JSON.unparse(manifest))
    iid
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

  def manifest_filename
    # A manifest stores the meta information such as
    # such as the chosen language, chosen tests framework.
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def dir_join(*args)
    File.join(*args)
  end

  def disk
    @externals.disk
  end

end
