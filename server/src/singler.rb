require_relative 'base58'
require 'json'

class Singler

  def initialize(disk)
    @disk = disk
  end

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    kata_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_create(manifest, files)
    if manifest['id'].nil?
      id = generate_id
      manifest['id'] = id
    else
      id = manifest['id']
      unless valid?(id)
        invalid('id', id)
      end
    end

    dir = kata_dir(id)
    unless dir.make
      # :nocov:
      invalid('id', id)
      # :nocov:
    end

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

  def kata_manifest(id)
    assert_id_exists(id)
    json_parse(kata_dir(id).read(manifest_filename))
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
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

  def kata_tags(id)
    assert_id_exists(id)
    read_tags(id)
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_tag(id, n)
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
    kata_dir(id).append(tags_filename, json_plain(tag) + "\n")
  end

  def read_tags(id)
    read_lined_tags(id).lines.map{ |line|
      json_parse(line)
    }
  end

  def read_lined_tags(id)
    kata_dir(id).read(tags_filename)
  end

  def tags_filename
    'tags.json'
  end

  # - - - - - - - - - - - - - -

  def write_tag(id, n, files, stdout, stderr, status)
    dir = kata_dir(id,n)
    unless dir.make
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
    json_parse(kata_dir(id,n).read(tag_filename))
  end

  def most_recent_tag(id)
    read_lined_tags(id).count("\n") - 1
  end

  def tag_filename
    'tag.json'
  end

  # - - - - - - - - - - - - - -

  def assert_id_exists(id)
    unless kata_dir(id).exists?
      invalid('id', id)
    end
  end

  # - - - - - - - - - - - - - -

  def tag_exists?(id, n)
    kata_dir(id, n).exists?
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

  def generate_id
    loop do
      id = Base58.string(6)
      if valid?(id)
        return id
      end
    end
  end

  # - - - - - - - - - - - - - -

  def valid?(id)
    if id.upcase.include?('L')
      false
    else
      !kata_dir(id).exists?
    end
  end

  def invalid(name, value)
    fail ArgumentError.new("#{name}:invalid:#{value}")
  end

  # - - - - - - - - - - - - - -

  def kata_dir(id, index=nil)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/porter
    args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
    unless index.nil?
      args << index.to_s
    end
    @disk[File.join(*args)]
  end

end
