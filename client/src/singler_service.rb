require_relative 'http_json_service'

class SinglerService

  def sha
    get(__method__)
  end

  # - - - - - - - - - - - -

  def kata_exists?(id)
    get(__method__, id)
  end

  def kata_create(manifest, files)
    post(__method__, manifest, files)
  end

  def kata_manifest(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def kata_ran_tests(id, n ,files, now, stdout, stderr, status, colour)
    post(__method__, id, n, files, now, stdout, stderr, status, colour)
  end

  def kata_tags(id)
    get(__method__, id)
  end

  def kata_tag(id, n)
    get(__method__, id, n)
  end

  private

  include HttpJsonService

  def hostname
    'singler'
  end

  def port
    4517
  end

end
