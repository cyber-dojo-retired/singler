require_relative 'test_base'

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
    assert_equal '/persistent-dir/iids', singler.path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '42E',
  'exists? is false before creation' do
    refute exists?('123456789A')
  end

  test '42F',
  'exists? is true after creation' do
    iid = create(create_manifest)
    assert exists?(iid)
  end

end