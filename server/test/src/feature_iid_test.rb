require_relative 'test_base'
require_relative '../../src/base58'

class IidTest < TestBase

  def self.hex_prefix
    '5187E'
  end

  # - - - - - - - - - - - - - - - -

  test '52E',
  'iid generates an available Base58 id' do
    generated = iid
    assert Base58.string?(generated), "Base58.string?(#{generated})"
    assert_equal 10, iid.size
    #refute exists?(generated)
  end

end