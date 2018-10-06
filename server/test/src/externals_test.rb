require_relative 'test_base'

class ExternalsTest < TestBase

  def self.hex_prefix
    '7A9B4'
  end

  # - - - - - - - - - - - - - - - - -

  test '543',
  'default externals are set' do
    externals = Externals.new
    assert_equal 'Singler',      externals.singler.class.name
    assert_equal 'ExternalDiskWriter',   externals.disk.class.name
    assert_equal 'ExternalStdoutLogger', externals.logger.class.name
    assert_equal 'ExternalIdGenerator',  externals.id_generator.class.name
  end

end