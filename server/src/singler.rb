require 'json'

# If all ids came from a single server I could use
# 6-character ids as the directory names and guarantee
# uniqueness at id generation.
# However, it is not uncommon to copy practice-sessions
# from one server to another, and uniqueness cannot be
# guaranteed in this case.
# Hence a 'visible' id is 6-characters and is
# completed to a 'private' 10-character id.
# When entering an id you will almost always only need
# 6-characters, but very very occasionally you may need
# to enter a 7th,8th.
# Using a base58 alphabet (but excluding L)
#   ==> 3^10 unique  6-character ids.
#   ==> 3^16 unique 10-character ids.

class Singler

  def initialize(externals)
    @externals = externals
  end

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def id?(id)
    dir[id].exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest, files)
    if manifest['id'].nil?
      id = id_generator.generate
      manifest['id'] = id
    else
      id = manifest['id']
      unless id_validator.valid?(id)
        invalid('id', id)
      end
    end

    unless dir[id].make
      invalid('id', id)
    end

    dir[id].write(manifest_filename, json_pretty(manifest))
    write_tag(id, 0, files, '', '', 0)
    tag0 = {
         'event' => 'created',
          'time' => manifest['created'],
        'number' => 0
      }
    append_tags(id, tag0)
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    assert_id_exists(id)
    json_parse(dir[id].read(manifest_filename))
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, n, files, now, stdout, stderr, status, colour)
    assert_id_exists(id)
    unless n >= 1
      invalid('n', n)
    end

    write_tag(id, n, files, stdout, stderr, status)
    tag = { 'colour' => colour, 'time' => now, 'number' => n }
    append_tags(id, tag)

    read_tags(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def tags(id)
    assert_id_exists(id)
    read_tags(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def tag(id, n)
    if n == -1
      assert_id_exists(id)
      n = most_recent_tag(id)
    else
      unless tag_exists?(id, n)
        invalid('n', n)
      end
    end
    read_tag(id, n)
  end

  private

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def append_tags(id, tag)
    dir[id].append(tags_filename, json_plain(tag) + "\n")
  end

  def read_tags(id)
    read_lined_tags(id).lines.map{ |line|
      json_parse(line)
    }
  end

  def read_lined_tags(id)
    dir[id].read(tags_filename)
  end

  def tags_filename
    'tags.json'
  end

  # - - - - - - - - - - - - - -

  def write_tag(id, n, files, stdout, stderr, status)
    unless dir[id,n].make
      invalid('n', n)
    end

    json = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    dir[id,n].write(tag_filename, json_pretty(json))
  end

  def read_tag(id, n)
    json_parse(dir[id,n].read(tag_filename))
  end

  def most_recent_tag(id)
    read_lined_tags(id).count("\n") - 1
  end

  def tag_filename
    'tag.json'
  end

  # - - - - - - - - - - - - - -

  def assert_id_exists(id)
    unless dir[id].exists?
      invalid('id', id)
    end
  end

  # - - - - - - - - - - - - - -

  def tag_exists?(id, n)
    dir[id, n].exists?
  end

  # - - - - - - - - - - - - - -

  def json_plain(o)
    JSON.generate(o)
  end

  def json_pretty(o)
    JSON.pretty_generate(o)
  end

  def json_parse(s)
    JSON.parse(s)
  end

  # - - - - - - - - - - - - - -

  def dir
    @externals.disk
  end

  def id_generator
    @externals.id_generator
  end

  def id_validator
    @externals.id_validator
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    fail ArgumentError.new("#{name}:invalid:#{value}")
  end

end
