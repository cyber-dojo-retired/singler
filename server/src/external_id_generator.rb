require_relative 'base58'

class ExternalIdGenerator

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
    @externals.singler
  end

  def valid?(id)
    !singler.id?(id) &&
      !id.include?('L') &&
        !id.include?('l')
  end

end
