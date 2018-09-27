require_relative 'test_base'
require 'json'

class SinglerServiceTest < TestBase

  def self.hex_prefix
    '6AA1B'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '966',
  %w( malformed id on any method raises ) do
    error = assert_raises { singler.manifest(nil) }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'SinglerService', error.service_name
    assert_equal 'manifest', error.method_name
    json = JSON.parse(error.message)
    assert_equal 'ArgumentError', json['class']
    assert_equal 'id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190',
  %w( sha ) do
    sha = singler.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6E7',
  %w( retrieved manifest contains id ) do
    manifest = make_manifest
    files = starting_files
    id = singler.create(manifest, files)
    manifest['id'] = id
    assert_equal manifest, singler.manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after create() then
  the id can be completed
  and id?() is true
  and the increments has tag0
  and the manifest can be retrieved ) do
    manifest = make_manifest
    files = starting_files
    id = singler.create(manifest, files)
    assert singler.id?(id)
    assert_equal([tag0], singler.increments(id))
    assert_equal id, singler.id_completed(id[0..5])
    outer = id[0..1]
    inner = id[2..-1]
    id_completions = singler.id_completions(outer)
    assert id_completions.include?(outer+inner)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A20',
  'ran_tests() returns increments' do
    # This is an optimization to avoid web service
    # having to make a call back to storer to get the
    # tag numbers for the new traffic-light's diff handler.
    manifest = make_manifest
    files = starting_files
    id = singler.create(manifest, files)

    tag1_files = starting_files
    tag1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assert failed'
    colour = 'amber'
    tags = singler.ran_tests(id, tag1_files, now, stdout, stderr, colour)

    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1}
    ]
    assert_equal expected, tags

    now = [2016,12,5, 21,2,15]
    tags = singler.ran_tests(id, tag1_files, now, stdout, stderr, colour)
    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1},
      {"colour"=>"amber", "time"=>[2016,12,5, 21,2,15], "number"=>2}
    ]
    assert_equal expected, tags
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A21',
  'after ran_tests()',
  'visible_files can be retrieved for any tag' do
    manifest = make_manifest
    files = starting_files
    id = singler.create(manifest, files)
    tag0_files = starting_files

    assert_equal tag0_files, singler.visible_files(id)
    assert_equal tag0_files, singler.tag_visible_files(id,-1)

    tag1_files = starting_files
    tag1_files.delete('output')
    tag1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assert failed'
    colour = 'amber'
    singler.ran_tests(id,tag1_files, now, stdout, stderr, colour)
    tag1_files['output'] = stdout + stderr

    assert_equal tag1_files, singler.visible_files(id)
    assert_equal tag1_files, singler.tag_visible_files(id, -1)

    tag2_files = tag1_files.clone
    tag2_files.delete('output')
    tag2_files['readme.txt'] = 'Your task is to print...'
    now = [2016,12,6, 9,31,56]
    stdout = 'All tests passed'
    stderr = ''
    colour = 'green'
    singler.ran_tests(id, tag2_files, now, stdout, stderr, colour)
    tag2_files['output'] = stdout + stderr

    assert_equal tag2_files, singler.visible_files(id)
    assert_equal tag2_files, singler.tag_visible_files(id, -1)

    assert_equal tag0_files, singler.tag_visible_files(id,0)
    assert_equal tag1_files, singler.tag_visible_files(id, 1)
    assert_equal tag2_files, singler.tag_visible_files(id, 2)

    hash = singler.tags_visible_files(id, was_tag=0, now_tag=1)
    assert_equal tag0_files, hash['was_tag']
    assert_equal tag1_files, hash['now_tag']

    hash = singler.tags_visible_files(id, was_tag=1, now_tag=2)
    assert_equal tag1_files, hash['was_tag']
    assert_equal tag2_files, hash['now_tag']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'ran_tests() with very large file does not raise' do
    # This test fails if docker-compose.yml uses
    # [read_only:true] without also using
    # [tmpfs: /tmp]
    manifest = make_manifest
    files = starting_files
    id = singler.create(manifest, files)

    files = starting_files
    files['very_large'] = 'X'*1024*500
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assertion failed'
    colour = 'amber'
    singler.ran_tests(id, files, now, stdout, stderr, colour)
  end

  private

  def make_manifest
    manifest = starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
    manifest.delete('visible_files')
    manifest
  end

  def starting_files
    manifest = starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
    manifest['visible_files']
  end

  def tag0
    {
      'event'  => 'created',
      'time'   => starter.creation_time,
      'number' => 0
    }
  end

end
