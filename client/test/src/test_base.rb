require_relative 'hex_mini_test'
require_relative '../../src/singler_service'

class TestBase < HexMiniTest

  def singler
    SinglerService.new
  end

=begin
  def sha
    singler.sha
  end

  # - - - - - - - - - - - -

  def create(manifest)
    singler.create(manifest)
  end

  def manifest(id)
    singler.manifest(id)
  end

  # - - - - - - - - - - - -

  def id?(id)
    singler.ids?(id)
  end

  def id_completed(partial_id)
    singler.completed(partial_id)
  end

  def id_completions(outer_id)
    singler.completions(outer_id)
  end

  # - - - - - - - - - - - -

  def ran_tests(id, files, now, stdout, stderr, colour)
    singler.ran_tests(id, files, now, stdout, stderr, colour)
  end

  def increments(id)
    singler.increments(id)
  end

  # - - - - - - - - - - - -

  def visible_files(id)
    singler.visible_files(id)
  end

  def tag_visible_files(id, tag)
    singler.tag_visible_files(id, tag)
  end

  def tags_visible_files(id, was_tag, now_tag)
    singler.tags_visible_files(id, was_tag, now_tag)
  end
=end

  private

end
