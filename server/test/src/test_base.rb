require_relative 'hex_mini_test'
require_relative '../../src/externals'
#require 'json'

class TestBase < HexMiniTest

  def iid
    singler.iid
  end

  private

  include Externals

end