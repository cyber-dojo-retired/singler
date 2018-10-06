require_relative 'http_json_service'

class SinglerService

  def sha
    get(__method__)
  end

  # - - - - - - - - - - - -

  def id?(id)
    get(__method__, id)
  end

  def create(manifest, files)
    post(__method__, manifest, files)
  end

  def manifest(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def ran_tests(id, n ,files, now, stdout, stderr, status, colour)
    post(__method__, id, n, files, now, stdout, stderr, status, colour)
  end

  def tags(id)
    get(__method__, id)
  end

  def tag(id, n)
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
