require_relative 'test_base'

class ExternalDiskWriterTest < TestBase

  def self.hex_prefix
    'FDF13'
  end

  def disk
    externals.disk
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'dir.exists? is false before dir.make and true after' do
    dir = disk['FCFDC8']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438',
  'dir.read() reads back what dir.write() wrote' do
    dir = disk['F7C14D']
    dir.make
    filename = 'limerick.txt'
    content = 'the boy stood on the burning deck'
    dir.write(filename, content)
    assert_equal content, dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '439',
  'dir.append() appends to the end' do
    dir = disk['D98AEC']
    dir.make
    filename = 'readme.md'
    dir.append(filename, "## GET tags\n")
    assert_equal "## GET tags\n", dir.read(filename)
    dir.append(filename, "## POST create\n")
    assert_equal "## GET tags\n## POST create\n", dir.read(filename)
  end

end
