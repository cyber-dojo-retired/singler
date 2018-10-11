
class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id) # eg '0215AF'
    if id.upcase.include?('L')
      false
    else
      args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
      !disk[File.join(*args)].exists?
    end
  end

  private

  def disk
    @externals.disk
  end

end
