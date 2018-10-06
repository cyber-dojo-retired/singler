require_relative 'test_base'
require 'json'

class SinglerServiceTest < TestBase

  def self.hex_prefix
    '6AA1B'
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

  test '6E7',
  %w( retrieved manifest contains id ) do
    manifest = starter.manifest
    id = singler.create(manifest, starter.files)
    manifest['id'] = id
    assert_equal manifest, singler.manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after create() then
  and exists?() is true
  and the tags has tag0
  and the manifest can be retrieved ) do
    id = singler.create(starter.manifest, starter.files)
    assert singler.exists?(id)
    assert_equal([tag0], singler.tags(id))
    expected = {
      'files' => starter.files,
      'stdout' => '',
      'stderr' => '',
      'status' => 0
    }
    assert_equal expected, singler.tag(id, 0)
    assert_equal expected, singler.tag(id, -1)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A20',
  'ran_tests() returns tags' do
    # This is an optimization to avoid web service
    # having to make a call back to storer to get the
    # tag numbers for the new traffic-light's diff handler.
    id = singler.create(starter.manifest, starter.files)
    tag1_files = starter.files
    tag1_files.delete('hiker.h')
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assert failed'
    status = 6
    colour = 'amber'
    tags = singler.ran_tests(id, 1, tag1_files, now, stdout, stderr, status, colour)
    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1}
    ]
    assert_equal expected, tags

    now = [2016,12,5, 21,2,15]
    tags = singler.ran_tests(id, 2, tag1_files, now, stdout, stderr, status, colour)
    expected = [
      tag0,
      {"colour"=>"amber", "time"=>[2016,12,5, 21,1,34], "number"=>1},
      {"colour"=>"amber", "time"=>[2016,12,5, 21,2,15], "number"=>2}
    ]
    assert_equal expected, tags
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'ran_tests() with very large file does not raise' do
    # This test fails if docker-compose.yml uses
    # [read_only:true] without also using
    # [tmpfs: /tmp]
    id = singler.create(starter.manifest, starter.files)

    files = starter.files
    files['very_large'] = 'X'*1024*500
    now = [2016,12,5, 21,1,34]
    stdout = 'missing include'
    stderr = 'assertion failed'
    status = 41
    colour = 'amber'
    singler.ran_tests(id, 1, files, now, stdout, stderr, status, colour)
  end

  private

  def tag0
    {
      'event'  => 'created',
      'time'   => starter.creation_time,
      'number' => 0
    }
  end

end
