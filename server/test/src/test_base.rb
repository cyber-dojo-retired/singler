require_relative 'hex_mini_test'
require_relative 'external_starter'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def sha
    singler.sha
  end

  # - - - - - - - - - - - - - - - - -

  def id?(id)
    singler.id?(id)
  end

  def create(manifest, files)
    singler.create(manifest, files)
  end

  def manifest(id)
    singler.manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def ran_tests(id, n, files, now, stdout, stderr, status, colour)
    singler.ran_tests(id, n, files, now, stdout, stderr, status, colour)
  end

  def tags(id)
    singler.tags(id)
  end

  def tag(id, n)
    singler.tag(id, n)
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