require_relative 'test_base'
require_relative 'id_generator_stub'

class SinglerTest < TestBase

  def self.hex_prefix
    '97431'
  end

  def hex_setup
    @real_id_generator = externals.id_generator
    @stub_id_generator = IdGeneratorStub.new
    externals.id_generator = @stub_id_generator
  end

  def hex_teardown
    externals.id_generator = @real_id_generator
  end

  attr_reader :stub_id_generator

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190', %w( sha of image's git commit ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # path
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '218', %w(
  singler's path is set
  but in test its volume-mounted to /tmp
  so its emphemeral ) do
    assert_equal '/singler/ids', singler.path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create() manifest()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '42D',
  'manifest raises when id does not exist' do
    id = 'B4AB376BE2'
    error = assert_raises(ArgumentError) {
      manifest(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42E',
  'create/manifest round-trip' do
    stub_id = '0ADDE7572A'
    stub_id_generator.stub(stub_id)
    expected = starter.manifest
    id = create(expected, starter.files)
    assert_equal stub_id, id
    expected['id'] = id
    actual = manifest(id)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id?(id), id_completed(partial_id), id_completions(outer_id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'id? is false before creation, true after creation' do
    stub_id = '50C8C661CD'
    refute id?(stub_id)
    stub_create(stub_id)
    assert id?(stub_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '393',
  'id_completed returns id when unique completion' do
    id = stub_create('E4ABB48CA4')
    partial_id = id[0...6]
    assert_equal id, id_completed(partial_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '394',
  'id_completed returns empty-string when no completion' do
    partial_id = 'AC9A0215C9'
    assert_equal '', id_completed(partial_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '395',
  'id_completed returns empty-string when no unique completion' do
    stub_id = '9504E6559'
    stub_create(stub_id + '0')
    stub_create(stub_id + '1')
    partial_id = stub_id[0...6]
    assert_equal '', id_completed(partial_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '396',
  'id_completions when no completions' do
    outer_id = '28'
    assert_equal [], id_completions(outer_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '397',
  'id_completions when a single completion' do
    id = stub_create('7CA8A87A2B')
    outer_id = id[0...2]
    assert_equal [id], id_completions(outer_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '398',
  'id_completions when two completions' do
    outer_id = '22'
    id0 = outer_id + '0' + '3D2DF43'
    id1 = outer_id + '1' + '3D2DF43'
    stub_create(id0)
    stub_create(id1)
    assert_equal [id0,id1].sort, id_completions(outer_id).sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # ran_tests(id,...), tags(id), tag(id,n)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '821',
  'tags raises when id does not exist' do
    id = 'B4AB376BE2'
    error = assert_raises(ArgumentError) {
      tags(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '822',
  'tag raises when n does not exist' do
    id = stub_create('AB5AEEF6BD')
    error = assert_raises(ArgumentError) {
      tag(id, 1)
    }
    assert_equal 'n:invalid:1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '823',
  'ran_tests raises when id does not exist' do
    id = 'B4AB376BE2'
    error = assert_raises(ArgumentError) {
      ran_tests(*make_args(id, 1, edited_files))
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '824', %w(
  ran_tests raises when n is -1
  because -1 can only be used on tag()
  ) do
    id = stub_create('FCF211235B')
    error = assert_raises(ArgumentError) {
      ran_tests(*make_args(id, -1, edited_files))
    }
    assert_equal 'n:invalid:-1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '825', %w(
  ran_tests raises when n is 0
  because 0 is used for create()
  ) do
    id = stub_create('08739D07A3')
    error = assert_raises(ArgumentError) {
      ran_tests(*make_args(id, 0, edited_files))
    }
    assert_equal 'n:invalid:0', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '826', %w(
  ran_tests raises when n already exists
  and does not add a new tag ) do
    id = stub_create('C7112B4C22')
    expected = []
    expected << {
      'event' => 'created',
       'time' => creation_time,
     'number' => 0
    }
    assert_equal expected, tags(id)

    ran_tests(*make_args(id, 1, edited_files))
    expected << {
      'colour' => red,
      'time' => time_now,
      'number' => 1
    }
    assert_equal expected, tags(id)

    error = assert_raises(ArgumentError) {
      ran_tests(*make_args(id, 1, edited_files))
    }
    assert_equal 'n:invalid:1', error.message

    assert_equal expected, tags(id)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '827', %w(
  ran_tests does NOT raise when n-1 does not exist
  and the reason for this is partly speed
  and partly robustness against temporary singler failure ) do
    id = stub_create('710145D963')
    ran_tests(*make_args(id, 1, edited_files))
    # ran_tests(*make_args(id, 2, ...)) assume failed
    ran_tests(*make_args(id, 3, edited_files)) # <====
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '829',
  'after ran_tests() there is one more tag' do
    id = stub_create('9DD618D263')

    tag0 = {
      'event'  => 'created',
      'time'   => creation_time,
      'number' => (was_tag=0)
    }
    lights = [tag0]
    diagnostic = '#0 tags(id)'
    assert_equal lights, tags(id), diagnostic

    expected = {
      'files' => starter.files,
      'stdout' => '',
      'stderr' => '',
      'status' => 0
    }
    assert_equal expected, tag(id, 0), 'tag(id,0)'
    assert_equal expected, tag(id, -1), 'tag(id,-1)'

    ran_tests(*make_args(id, 1, edited_files))

    lights << {
      'colour' => red,
      'time'   => time_now,
      'number' => (now_tag=1)
    }
    diagnostic = '#1 tags(id)'
    assert_equal lights, tags(id), diagnostic

    expected = {
      'files' => edited_files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    assert_equal expected, tag(id, 1), 'tag(id,1)'
    assert_equal expected, tag(id, -1), 'tag(id,-1)'
  end

  private

  def make_args(id, n, files)
    [ id, n, files, time_now, stdout, stderr, status, red ]
  end

  def edited_files
    { 'cyber-dojo.sh' => 'gcc',
      'hiker.c'       => '#include "hiker.h"',
      'hiker.h'       => '#ifndef HIKER_INCLUDED',
      'hiker.tests.c' => '#include <assert.h>'
    }
  end

  def time_now
    [2016,12,2, 6,14,57]
  end

  def stdout
    ''
  end

  def stderr
    'Assertion failed: answer() == 42'
  end

  def status
    23
  end

  def red
    'red'
  end

end