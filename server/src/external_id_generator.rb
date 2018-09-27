require_relative 'base56'

# Rack calls singler.create() in threads so in
# theory you could get a race condition with both
# threads attempting a create with the same id.
# Assuming base56 id generation is reasonably well
# behaved (random) this is extremely unlikely.

class ExternalIdGenerator

  def initialize(externals)
    @externals = externals
  end

  def generate
    iid = nil
    loop do
      iid = Base56.string(10)
      break if valid?(iid)
    end
    iid
  end

  private

  def valid?(id)
    !singler.id?(id)
  end

  def singler
    @externals.singler
  end

end
