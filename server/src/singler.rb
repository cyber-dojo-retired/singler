
class Singler

  def initialize(externals)
    @externals = externals
    @path = '/persistent-dir/ids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  def exists?(id)
    id_dir(id).exists?
  end

  def create(manifest)
    # Generates an id, puts it in the manifest,
    # saves the manifest, and returns the id.
    # Rack calls create() in threads so in theory
    # you could get a race condition with both
    # threads attempting a create with the same id.
    # Assuming base58 id generation is reasonably well
    # behaved (random) this is extremely unlikely.
    id = id_generator.generate
    manifest['id'] = id
    dir = id_dir(id)
    dir.make
    dir.write(manifest_filename, JSON.unparse(manifest))
    id
  end

  def manifest(id)
    assert_id_exists(id)
    dir = id_dir(id)
    json = dir.read(manifest_filename)
    JSON.parse(json)
  end

  private

  def id_generator
    @externals.id_generator
  end

  def assert_id_exists(id)
    unless exists?(id)
      invalid('id')
    end
  end

  def id_dir(id)
    disk[id_path(id)]
  end

  def id_path(id)
    dir_join(path, outer(id), inner(id))
  end

  def outer(id)
    id[0..1]  # eg 'e5' 2-chars long
  end

  def inner(id)
    id[2..-1] # eg '6aM327PE' 8-chars long
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

  def invalid(name)
    fail ArgumentError.new("#{name}:invalid")
  end

  def disk
    @externals.disk
  end

end
