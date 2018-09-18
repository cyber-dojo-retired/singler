require 'json'

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
    id = id_generator.generate
    manifest['id'] = id
    dir = id_dir(id)
    dir.make
    dir.write(manifest_filename, json_unparse(manifest))
    tag0 = {
         'event' => 'created',
          'time' => manifest(id)['created'],
        'number' => 0
      }
    write_increments(id, [tag0])
    write_tag_files(id, 0, manifest['visible_files'])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    assert_id_exists(id)
    dir = id_dir(id)
    json_parse(dir.read(manifest_filename))
  end

  # - - - - - - - - - - - - - - - - - - -

  def id?(id)
    id_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_completed(partial_id)
    outer_dir = disk[dir_join(path, outer(partial_id))]
    unless outer_dir.exists?
      return ''
    end
    # Slower with more inner dirs.
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
    # for Batch-Method iteration over large number of practice-sessions...
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
    files['output'] = stdout + stderr
    write_tag_files(id, tag, files)
    increments
  end

  # - - - - - - - - - - - - - - - - - - -

  def increments(id)
    assert_id_exists(id)
    read_increments(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def visible_files(id)
    assert_id_exists(id)
    tag = most_recent_tag(id)
    read_tag_files(id, tag)
  end

  # - - - - - - - - - - - - - - - - - - -
  # tag
  # - - - - - - - - - - - - - - - - - - -

  def tag_visible_files(id, tag)
    if tag == -1
      assert_id_exists(id)
      tag = most_recent_tag(id)
    else
      assert_tag_exists(id, tag)
    end
    read_tag_files(id, tag)
  end

  def tags_visible_files(id, was_tag, now_tag)
    {
      'was_tag' => tag_visible_files(id, was_tag),
      'now_tag' => tag_visible_files(id, now_tag)
    }
  end

  private

  def manifest_filename
    'manifest.json'
  end

  def increments_filename
    'increments.json'
  end

  # - - - - - - - - - - - - - -

  def write_increments(id, increments)
    dir = id_dir(id)
    dir.write(increments_filename, json_unparse(increments))
  end

  def read_increments(id)
    dir = id_dir(id)
    json_parse(dir.read(increments_filename))
  end

  # - - - - - - - - - - - - - -

  def write_tag_files(id, tag, files)
    dir = tag_dir(id, tag)
    dir.make
    dir.write(manifest_filename, json_unparse(files))
  end

  def read_tag_files(id, tag)
    dir = tag_dir(id, tag)
    json_parse(dir.read(manifest_filename))
  end

  def most_recent_tag(id, increments = nil)
    increments ||= read_increments(id)
    increments.size - 1
  end

  # - - - - - - - - - - - - - -

  def assert_id_exists(id)
    unless id_dir(id).exists?
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
    id[0..1]  # 2-chars long. eg 'e5'
  end

  def inner(id)
    id[2..-1] # 8-chars long. eg '6aM327PE'
  end

  # - - - - - - - - - - - - - -

  def assert_tag_exists(id, tag)
    unless tag_dir(id, tag).exists?
      invalid('tag')
    end
  end

  def tag_dir(id, tag)
    disk[tag_path(id, tag)]
  end

  def tag_path(id, tag)
    dir_join(id_path(id), tag.to_s)
  end

  def dir_join(*args)
    File.join(*args)
  end

  def invalid(name)
    fail ArgumentError.new("#{name}:invalid")
  end

  # - - - - - - - - - - - - - -

  def json_unparse(o)
    JSON.pretty_generate(o)
  end

  def json_parse(s)
    JSON.parse(s)
  end

  # - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

  def id_generator
    @externals.id_generator
  end

end
