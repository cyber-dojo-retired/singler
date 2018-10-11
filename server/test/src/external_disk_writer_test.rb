require_relative 'test_base'

class ExternalDiskWriterTest < TestBase

  def self.hex_prefix
    'FDF'
  end

  def disk
    externals.disk
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'dir.exists? is false before dir.make and true after' do
    dir = disk['/katas/FC/FD/C8']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438',
  'dir.read() reads back what dir.write() wrote' do
    dir = disk['/katas/F7/C1/4D']
    dir.make
    filename = 'limerick.txt'
    content = 'the boy stood on the burning deck'
    dir.write(filename, content)
    assert_equal content, dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '439',
  'dir.append() appends to the end' do
    dir = disk['/katas/D9/8A/EC']
    dir.make
    filename = 'readme.md'
    content = 'hello world'
    dir.append(filename, content)
    assert_equal content, dir.read(filename)
    dir.append(filename, content.reverse)
    assert_equal "#{content}#{content.reverse}", dir.read(filename)
  end

end
