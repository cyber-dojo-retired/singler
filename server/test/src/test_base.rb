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

  def create(manifest)
    singler.create(manifest)
  end

  def manifest(id)
    singler.manifest(id)
  end

  def id?(id)
    singler.id?(id)
  end

  def id_completed(partial_id)
    singler.id_completed(partial_id)
  end

  def id_completions(outer_id)
    singler.id_completions(outer_id)
  end

  def ran_tests(id, files, now, stdout, stderr, colour)
    singler.ran_tests(id, files, now, stdout, stderr, colour)
  end

  def increments(id)
    singler.increments(id)
  end

  def visible_files(id)
    singler.visible_files(id)
  end

  def tag_visible_files(id, tag)
    singler.tag_visible_files(id, tag)
  end

  def tags_visible_files(id, was_tag, now_tag)
    singler.tags_visible_files(id, was_tag, now_tag)
  end

  #- - - - - - - - - - - - - - -

  def create_manifest
    manifest = starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
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