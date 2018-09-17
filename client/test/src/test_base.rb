require_relative 'hex_mini_test'
require_relative '../../src/singler_service'
require_relative '../../src/starter_service'

class TestBase < HexMiniTest

  def singler
    SinglerService.new
  end

  def starter
    StarterService.new
  end

end
