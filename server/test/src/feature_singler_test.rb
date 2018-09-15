require_relative 'test_base'
require_relative 'id_generator_stub'

class ExistsTest < TestBase

  def self.hex_prefix
    '97431'
  end

  # - - - - - - - - - - - - - - - - -
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
  'singler.path is set but there is no volume-mount so its emphemeral' do
    assert_equal '/persistent-dir/ids', singler.path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(id) create(manifest) manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '42B',
  'exists? is false before creation' do
    refute exists?('123456789A')
  end

  test '42C',
  'exists? is true after creation' do
    id = create(create_manifest)
    assert exists?(id)
  end

  test '42D',
  'manifest raises when id does not exist' do
    error = assert_raises(ArgumentError) {
      manifest('B4AB376BE2')
    }
    assert_equal 'id:invalid', error.message
  end

  test '42E',
  'manifest round-trip' do
    expected = create_manifest
    id = create(expected)
    expected['id'] = id
    actual = manifest(id)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id_completed(partial_id), id_completions(outer_id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '393',
  'id_completed returns empty-string when no completion' do
    partial_id = '28EEC2'
    assert_equal '', id_completed(partial_id)
  end

  test '394',
  'id_completed returns id when unique completion' do
    id = create(create_manifest)
    partial_id = id[0...6]
    assert_equal id, id_completed(partial_id)
  end

  test '395',
  'id_completed returns empty-string when no unique completion' do
    externals.id_generator = IdGeneratorStub.new
    stub_id = '9504E6559'
    id0 = stub_id + '0'
    id1 = stub_id + '1'
    externals.id_generator.stub(id0, id1)
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
    id = create(create_manifest)
    outer_id = id[0...2]
    assert_equal [id], id_completions(outer_id)
  end

  test '398',
  'id_completions when two completions' do
    externals.id_generator = IdGeneratorStub.new
    stub_id = '223D2DF43'
    id0 = stub_id + '0'
    id1 = stub_id + '1'
    externals.id_generator.stub(id0, id1)
    manifest = create_manifest
    id = create(manifest)
    assert_equal id0, id
    id = create(manifest)
    assert_equal id1, id
    outer_id = stub_id[0...2]
    assert_equal [id0,id1].sort, id_completions(outer_id).sort
  end

end