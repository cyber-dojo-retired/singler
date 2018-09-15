require_relative 'base58'

class IidGenerator

  def initialize(externals)
    @externals = externals
  end

  def generate
    iid = nil
    loop do
      iid = Base58.string(10)
      break if valid?(iid)
    end
    iid
  end

  private

  def singler
    #@externals.singler
  end

  def valid?(iid)
    #!singler.exists?(iid) &&
      !iid.include?('L') &&
        !iid.include?('l')
  end

end
