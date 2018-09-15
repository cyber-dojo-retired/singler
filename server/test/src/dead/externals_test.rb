require_relative 'zipper_test_base'

class ExternalsTest < ZipperTestBase

  def self.hex_prefix
    '7A98A'
  end

  test '920',
  'default file is ExternalDisk' do
    assert_equal 'ExternalDisk', disk.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test '3EC',
  'default log is ExternalStdoutLogger' do
    assert_equal 'ExternalStdoutLogger', log.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test '1B1',
  'default shell is ExternalSheller' do
    assert_equal 'ExternalSheller', shell.class.name
  end

end
