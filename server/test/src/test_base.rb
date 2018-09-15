require_relative 'hex_mini_test'
require_relative 'starter_service'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def externals
    @externals ||= Externals.new
  end

  #- - - - - - - - - - - - - - -

  def sha
    singler.sha
  end

  def exists?(iid)
    singler.exists?(iid)
  end

  def create(manifest)
    singler.create(manifest)
  end

  #- - - - - - - - - - - - - - -

  def create_manifest(visible_files = nil)
    manifest = starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
    unless visible_files.nil?
      manifest['visible_files'] = visible_files
    end
    manifest['created'] = creation_time
    manifest
  end

  #- - - - - - - - - - - - - - -

  def bare_manifest
    {
      'display_name' => 'C (gcc), assert',
      'visible_files' => { 'cyber-dojo.sh' => 'make' },
      'image_name' => 'cyberdojofoundation/gcc_assert',
      'runner_choice' => 'stateless',
      'created' => [2018,3,28, 11,31,45],
      'filename_extension' => [ '.c', '.h' ]
    }.dup
  end

  private

  def creation_time
    [2016,12,2, 6,13,23]
  end

  #- - - - - - - - - - - - - - -

  def singler
    externals.singler
  end

  def starter
    StarterService.new
  end

end