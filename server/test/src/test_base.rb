require_relative 'hex_mini_test'
require_relative 'external_starter'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def sha
    singler.sha
  end

  # - - - - - - - - - - - - - - - - -

  def create(manifest, files)
    singler.create(manifest, files)
  end

  def manifest(id)
    singler.manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def id?(id)
    singler.id?(id)
  end

  def id_completed(partial_id)
    singler.id_completed(partial_id)
  end

  def id_completions(outer_id)
    singler.id_completions(outer_id)
  end

  # - - - - - - - - - - - - - - - - -

  def ran_tests(id, files, now, stdout, stderr, status, colour)
    singler.ran_tests(id, files, now, stdout, stderr, status, colour)
  end

  def increments(id)
    singler.increments(id)
  end

  # - - - - - - - - - - - - - - - - -

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

  def stub_create(stub_id)
    stub_id_generator.stub(stub_id)
    id = create(starter.manifest, starter.files)
    assert_equal stub_id, id
    id
  end

  #- - - - - - - - - - - - - - -

  def starter
    ExternalStarter.new
  end

  def creation_time
    starter.creation_time
  end

  def externals
    @externals ||= Externals.new
  end

  private

  def singler
    externals.singler
  end

end