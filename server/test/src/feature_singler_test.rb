require_relative 'test_base'
require_relative 'id_generator_stub'

class ExistsTest < TestBase

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

  test '190', %w( sha is exposed via API ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # path
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '218',
  'singler.path is set but in test there is no volume-mount so its emphemeral' do
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

  test '42E',
  'manifest round-trip' do
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
    stub_id_generator.stub(stub_id)
    refute id?(stub_id)
    create(create_manifest)
    assert id?(stub_id)
  end

  test '393',
  'id_completed returns id when unique completion' do
    stub_id = 'E4ABB48CA4'
    stub_id_generator.stub(stub_id)
    id = create(create_manifest)
    partial_id = id[0...6]
    assert_equal id, id_completed(partial_id)
  end

  test '394',
  'id_completed return empty-string when no completion' do
    partial_id = 'AC9A0215C9'
    assert_equal '', id_completed(partial_id)
  end

  test '395',
  'id_completed returns empty-string when no unique completion' do
    stub_id = '9504E6559'
    id0 = stub_id + '0'
    id1 = stub_id + '1'
    stub_id_generator.stub(id0, id1)
    manifest = create_manifest
    id = create(manifest)
    assert_equal id0, id
    id = create(manifest)
    assert_equal id1, id
    partial_id = stub_id[0...6]
    assert_equal '', id_completed(partial_id)
  end

  test '396',
  'id_completions when no completions' do
    outer_id = '28'
    assert_equal [], id_completions(outer_id)
  end

  test '397',
  'id_completions when a single completion' do
    stub_id = '7CA8A87A2B'
    stub_id_generator.stub(stub_id)
    id = create(create_manifest)
    outer_id = id[0...2]
    assert_equal [id], id_completions(outer_id)
  end

  test '398',
  'id_completions when two completions' do
    outer_id = '22'
    id0 = outer_id + '0' + '3D2DF43'
    id1 = outer_id + '1' + '3D2DF43'
    stub_id_generator.stub(id0, id1)
    manifest = create_manifest
    id = create(manifest)
    assert_equal id0, id
    id = create(manifest)
    assert_equal id1, id
    assert_equal [id0,id1].sort, id_completions(outer_id).sort
  end

end