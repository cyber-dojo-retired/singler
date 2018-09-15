
class Singler

  def initialize(externals)
    @externals = externals
    @path = '/persistent-dir/ids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    id_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

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

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    assert_id_exists(id)
    dir = id_dir(id)
    json = dir.read(manifest_filename)
    JSON.parse(json)
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_completed(partial_id)
    # Attempt to complete partial_id into a full (10 character) id.
    outer_dir = disk[dir_join(path, outer(partial_id))]
    unless outer_dir.exists?
      return ''
    end
    # As the number of inner dirs increases this
    # gets sloooooow...
    dirs = outer_dir.each_dir.select { |inner_dir|
      inner_dir.start_with?(inner(partial_id))
    }
    unless dirs.length == 1
      return ''
    end
    outer(partial_id) + dirs[0] # success!
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_completions(outer_id)
    # for Batch-Method iteration over large number of pratice-sessions...
    unless disk[dir_join(path, outer_id)].exists?
      return []
    end
    disk[dir_join(path, outer_id)].each_dir.collect { |dir|
      outer_id + dir
    }
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
