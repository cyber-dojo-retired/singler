
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
    write_increments(id, [])
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

  def id?(id)
    id_dir(id).exists?
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

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, files, now, stdout, stderr, colour)
    assert_id_exists(id)
    increments = read_increments(id)
    tag = most_recent_tag(id, increments) + 1
    increments << { 'colour' => colour, 'time' => now, 'number' => tag }
    write_increments(id, increments)
    # don't alter caller's files argument
    files = files.clone
    files['output'] = stdout + stderr
    write_tag_files(id, tag, files)
    increments
  end

  # - - - - - - - - - - - - - - - - - - -

  def increments(id)
    assert_id_exists(id)
    # Return increments with tag0 to avoid client
    # having to make extra service call
    tag0 =
      {
         'event' => 'created',
          'time' => manifest(id)['created'],
        'number' => 0
      }
    [tag0] + read_increments(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def visible_files(id)
    assert_id_exists(id)
    tag = most_recent_tag(id)
    tag_visible_files(id, tag)
  end

  # - - - - - - - - - - - - - - - - - - -
  # tag
  # - - - - - - - - - - - - - - - - - - -

  def tag_visible_files(id, tag)
    assert_id_exists(id)
    if tag == -1
      tag = most_recent_tag(id)
    end
    assert_tag_exists(id, tag)
    if tag == 0 # tag zero is a special case
      return manifest(id)['visible_files']
    end
    dir = tag_dir(id, tag)
    if dir.exists? # new non-git-format
      read_tag_files(id, tag)
    else # old git-format
      path = id_path(id)
      git = "git show #{tag}:#{manifest_filename}"
      src = shell.cd_exec(path, git)[0]
      JSON.parse(src)
    end
  end

  private

  def id_generator
    @externals.id_generator
  end

  def assert_id_exists(id)
    unless id?(id)
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

  def write_increments(id, increments)
    json = JSON.unparse(increments)
    dir = id_dir(id)
    dir.write(increments_filename, json)
  end

  def read_increments(id)
    # increments holds a cache of colours
    # and time-stamps for all the [test]s.
    # Helps optimize dashboard traffic-lights views.
    # Not saving tag0 in increments.json
    # to maintain compatibility with old git-format
    dir = id_dir(id)
    json = dir.read(increments_filename)
    JSON.parse(json)
  end

  def increments_filename
    'increments.json'
  end

  # - - - - - - - - - - - - - -

  def assert_tag_exists(id, tag)
    unless tag_exists?(id, tag)
      invalid('tag')
    end
  end

  def tag_exists?(id, tag)
    # Has to work with old git-format and new non-git format
    0 <= tag && tag <= most_recent_tag(id)
  end

  def write_tag_files(id, tag, files)
    json = JSON.unparse(files)
    dir = tag_dir(id, tag)
    dir.make
    dir.write(manifest_filename, json)
  end

  def read_tag_files(id, tag)
    dir = tag_dir(id, tag)
    json = dir.read(manifest_filename)
    JSON.parse(json)
  end

  def most_recent_tag(id, increments = nil)
    increments ||= read_increments(id)
    increments.size
  end

  def tag_dir(id, tag)
    disk[tag_path(id, tag)]
  end

  def tag_path(id, tag)
    dir_join(id_path(id), tag.to_s)
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
