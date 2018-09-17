require_relative 'hex_mini_test'
require_relative '../../src/singler_service'

class TestBase < HexMiniTest

  def singler
    SinglerService.new
  end

end
