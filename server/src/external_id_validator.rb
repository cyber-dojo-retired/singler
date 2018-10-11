
class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id) # eg '0215AF'
    if id.upcase.include?('L')
      false
    else
      !@externals.kata_dir(id).exists?
    end
  end

end
