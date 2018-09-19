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

  test '218',
  %w( singler's path is set but in test there its volume-mounted to /tmp so its emphemeral ) do
    assert_equal '/persistent-dir/ids', singler.path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create(manifest) manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '42D',
  'manifest raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      manifest('B4AB376BE2')
    }
    assert_equal 'id:invalid', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42E',
  'create-manifest round-trip' do
    stub_id = '0ADDE7572A'
    stub_id_generator.stub(stub_id)
    expected = create_manifest
    id = create(expected)
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
  # ran_tests(id,...), increments(id), visible_files(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '822',
  'increments raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      increments('B4AB376BE2')
    }
    assert_equal 'id:invalid', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '823',
  'ran_tests raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      ran_tests(*make_args('B4AB376BE2', edited_files))
    }
    assert_equal 'id:invalid', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '825',
  'after ran_tests() there is one more tag and one more traffic-light' do
    id = stub_create('9DD618D263')

    lights = [
      { 'event'  => 'created',
        'time'   => creation_time,
        'number' => (was_tag=0)
      }
    ]
    diagnostic = '#0 increments(id)'
    assert_equal lights, increments(id), diagnostic

    ran_tests(*make_args(id, edited_files))

    lights << {
      'colour' => red,
      'time'   => time_now,
      'number' => (now_tag=1)
    }
    diagnostic = '#1 increments(id)'
    assert_equal lights, increments(id), diagnostic
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '826',
  'visible_files are retrievable by implicit current tag' do
    id = stub_create('79608F899B')

    actual = visible_files(id)
    diagnostic = "#0 visible_files(#{id})"
    output = ''
    assert_visible_files(starting_files, actual, output, diagnostic)

    ran_tests(*make_args(id, edited_files))

    actual = visible_files(id)
    diagnostic = "#1 visible_files(#{id})"
    output = stdout+stderr
    assert_visible_files(edited_files, actual, output, diagnostic)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '827',
  'visible_files are retrievable by explicit tag' do
    id = stub_create('02238A79A3')

    actual = tag_visible_files(id, 0)
    diagnostic = "tag_visible_files(#{id},0)"
    output = ''
    assert_visible_files(starting_files, actual, output, diagnostic)

    ran_tests(*make_args(id, edited_files))

    actual = tag_visible_files(id, 1)
    diagnostic = "tag_visible_files(#{id},1)"
    output = stdout+stderr
    assert_visible_files(edited_files, actual, output, diagnostic)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '828',
  'visible_files are retrievable by explicit -1 tag (most recent)' do
    id = stub_create('41B318D009')

    actual = tag_visible_files(id, -1)
    diagnostic = "#0 tag_visible_files(#{id},-1)"
    output = ''
    assert_visible_files(starting_files, actual, output, diagnostic)

    ran_tests(*make_args(id, edited_files))

    actual = tag_visible_files(id, -1)
    diagnostic = "#1 tag_visible_files(#{id},-1)"
    output = stdout+stderr
    assert_visible_files(edited_files, actual, output, diagnostic)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '829',
  'two sets of visible files can be retrieved at once' do
    id = stub_create('D1620CC63B')
    ran_tests(*make_args(id, edited_files))

    hash = tags_visible_files(id, was_tag=0, now_tag=1)

    actual = hash['was_tag']
    diagnostic = "tags_visible_files(#{id},0,1)['was_tag']"
    output = ''
    assert_visible_files(starting_files, actual, output, diagnostic)

    actual = hash['now_tag']
    diagnostic = "tags_visible_files(#{id},0,1)['now_tag']"
    output = stdout+stderr
    assert_visible_files(edited_files, actual, output, diagnostic)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '926',
  'visible_files raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      visible_files('B4AB376BE2')
    }
    assert_equal 'id:invalid', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '927',
  'tag_visible_files raises when tag does not exist' do
    id = stub_create('53A8779B07')
    error = assert_raises(ArgumentError) {
      tag_visible_files(id, 1)
    }
    assert_equal 'tag:invalid', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '928',
  'tags_visible_files raises when now_tag does not exist' do
    id = stub_create('E05D5FB3CA')
    error = assert_raises(ArgumentError) {
      tags_visible_files(id, 0, 1)
    }
    assert_equal 'tag:invalid', error.message
  end

  private

  def stub_create(stub_id)
    stub_id_generator.stub(stub_id)
    id = create(create_manifest)
    assert_equal stub_id, id
    id
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def assert_visible_files(expected, actual, output, diagnostic)
    assert actual.keys.include?('output'), diagnostic + ' [output]'
    assert_equal output, actual['output']
    expected.each do |filename,content|
      assert_equal content, actual[filename], diagnostic + " [#{filename}]"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def make_args(id, files)
    [ id, files, time_now, stdout, stderr, red ]
  end

  def starting_files
    manifest = create_manifest
    manifest['visible_files']
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

  def red
    'red'
  end

end