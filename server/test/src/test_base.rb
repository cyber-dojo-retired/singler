require_relative 'hex_mini_test'
require_relative 'external_starter'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def sha
    singler.sha
  end

  # - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    singler.kata_exists?(id)
  end

  def kata_create(manifest, files)
    singler.kata_create(manifest, files)
  end

  def kata_manifest(id)
    singler.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
    singler.kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
  end

  def kata_tags(id)
    singler.kata_tags(id)
  end

  def kata_tag(id, n)
    singler.kata_tag(id, n)
  end

  #- - - - - - - - - - - - - - -

  def stub_kata_create(stub_id)
    manifest = starter.manifest
    manifest['id'] = stub_id
    id = kata_create(manifest, starter.files)
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