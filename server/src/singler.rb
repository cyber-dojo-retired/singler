
class Singler

  def initialize(externals)
    @externals = externals
  end

  def iid
    iid_generator.generate
  end

  private

  def iid_generator
    @externals.iid_generator
  end

end
