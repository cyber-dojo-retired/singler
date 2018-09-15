
class IdGeneratorStub

  def initialize
    @stubbed = []
  end

  def stub(*kata_ids)
    @stubbed = kata_ids
  end

  def generate
    @stubbed.shift
  end

end
