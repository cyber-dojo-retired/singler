require_relative 'test_base'
require_relative '../../src/external_disk_writer'

class ExternalDiskWriterTest < TestBase

  def self.hex_prefix
    'FDF'
  end

  def disk
    ExternalDiskWriter.new
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '436',
  'dir can already exist' do
    dir = disk['/tmp']
    assert dir.exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'dir.exists? is false before dir.make and true after' do
    dir = disk['/katas/FD/F4/37']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438',
  'dir.read() reads back what dir.write() wrote' do
    dir = disk['/katas/FD/F4/38']
    dir.make
    filename = 'limerick.txt'
    content = 'the boy stood on the burning deck'
    dir.write(filename, content)
    assert_equal content, dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '439',
  'dir.append() appends to the end' do
    dir = disk['/katas/FD/F4/39']
    dir.make
    filename = 'readme.md'
    content = 'hello world'
    dir.append(filename, content)
    assert_equal content, dir.read(filename)
    dir.append(filename, content.reverse)
    assert_equal "#{content}#{content.reverse}", dir.read(filename)
  end

end
