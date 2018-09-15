require_relative 'test_base'

class ZipTagTest < TestBase

  def self.hex_prefix
    '7C880'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '2A4',
  'zip_tag raises when kata_id is empty' do
    error = assert_raises {
      zip_tag(kata_id = '', 'salmon', 2)
    }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'ZipperService', error.service_name
    assert_equal 'zip_tag', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ServiceError', exception['class']
    json = JSON.parse(exception['message'])
    assert_equal 'ArgumentError', json['class']
    assert_equal 'kata_id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '2A5',
  'zip_tag raises when kata_id is malformed' do
    error = assert_raises {
      zip_tag(kata_id = '--', 'salmon', 2)
    }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'ZipperService', error.service_name
    assert_equal 'zip_tag', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ServiceError', exception['class']
    json = JSON.parse(exception['message'])
    assert_equal 'ArgumentError', json['class']
    assert_equal 'kata_id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def zip_tag(kata_id, avatar_name, tag)
    zipper.zip_tag(kata_id, avatar_name, tag)
  end

end
