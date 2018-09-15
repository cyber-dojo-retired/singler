require_relative 'zipper_test_base'
require_relative '../../src/id_splitter'

class IdSplitterTest < ZipperTestBase

  include IdSplitter

  def self.hex_prefix
    '80DBC'
  end

  test 'E81',
  'outer(id) is first 2 chars of id in uppercase' do
    assert_equal 'A7', outer('a73457AD02')
  end

  test 'FC6',
  'inner(id) is last 8 chars of id in uppercase' do
    assert_equal '3457ADF2', inner('a73457ADf2')
  end

end
