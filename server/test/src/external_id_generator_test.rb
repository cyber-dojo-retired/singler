require_relative 'test_base'

class ExternalIdGeneratorTest < TestBase

  def self.hex_prefix
    '9E748'
  end

  # - - - - - - - - - - - - - - - -

  test '926',
  'generates Base56 ids' do
    id = externals.id_generator.generate
    assert Base56.string?(id), "Base56.string?(#{id})"
    assert_equal 10, id.size
  end

end
