require_relative 'id_splitter'
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
    @path = '/singler/ids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest, files)
    id = id_generator.generate
    manifest['id'] = id
    dir = id_dir(id)
    dir.make
    dir.write(manifest_filename, json_pretty(manifest))
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
    json_parse(id_dir(id).read(manifest_filename))
  end

  # - - - - - - - - - - - - - - - - - - -

  def id?(id)
    id_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, n, files, now, stdout, stderr, status, colour)
    assert_id_exists(id)
    invalid('n', n) unless n >= 1

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
      invalid('n', n) unless tag_exists?(id, n)
    end
    read_tag(id, n)
  end

  private

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - -

  def append_tags(id, tag)
    dir = id_dir(id)
    dir.append(tags_filename, json_plain(tag) + "\n")
  end

  def read_tags(id)
    read_lined_tags(id).lines.map{ |line|
      json_parse(line)
    }
  end

  def read_lined_tags(id)
    dir = id_dir(id)
    dir.read(tags_filename)
  end

  def tags_filename
    'tags.json'
  end

  # - - - - - - - - - - - - - -

  def write_tag(id, n, files, stdout, stderr, status)
    dir = tag_dir(id, n)

    begin
      dir.make
    rescue
      invalid('n', n)
    end

    json = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    dir.write(tag_filename, json_pretty(json))
  end

  def read_tag(id, n)
    dir = tag_dir(id, n)
    json_parse(dir.read(tag_filename))
  end

  def most_recent_tag(id)
    read_lined_tags(id).count("\n") - 1
  end

  def tag_filename
    'tag.json'
  end

  # - - - - - - - - - - - - - -

  def assert_id_exists(id)
    unless id_dir(id).exists?
      invalid('id', id)
    end
  end

  def id_dir(id)
    disk[id_path(id)]
  end

  def id_path(id)
    dir_join(path, outer(id), inner(id))
  end

  include IdSplitter

  # - - - - - - - - - - - - - -

  def tag_exists?(id, n)
    tag_dir(id, n).exists?
  end

  def tag_dir(id, n)
    disk[tag_path(id, n)]
  end

  def tag_path(id, n)
    dir_join(id_path(id), n.to_s)
  end

  # - - - - - - - - - - - - - -

  def dir_join(*args)
    File.join(*args)
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

  def disk
    @externals.disk
  end

  def id_generator
    @externals.id_generator
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    fail ArgumentError.new("#{name}:invalid:#{value}")
  end

end
