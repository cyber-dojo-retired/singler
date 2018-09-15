require_relative 'hex_mini_test'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def externals
    @externals ||= Externals.new
  end

  #- - - - - - - - - - - - - - -

  def sha
    singler.sha
  end

  def iid
    singler.iid
  end

  private

  def singler
    externals.singler
  end

end