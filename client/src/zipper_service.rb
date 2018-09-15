require_relative 'http_json_service'

class ZipperService

  def sha
    get(__method__)
  end

  def zip(kata_id)
    get(__method__, kata_id)
  end

  def zip_tag(kata_id, avatar_name, tag)
    get(__method__, kata_id, avatar_name, tag)
  end

  private

  include HttpJsonService

  def hostname
    'zipper'
  end

  def port
    4587
  end

end
