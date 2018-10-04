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
  'dir.name does not ends in /' do
    dir = disk['/tmp/437']
    assert_equal '/tmp/437', dir.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0DB',
  'dir.exists? is false before dir.make and true after' do
    dir = disk['/tmp/0DB']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1B5',
  'dir.make is true if the dir is newly made, false if not' do
    dir = disk['/tmp/1B5']
    refute dir.exists?
    assert dir.make
    refute dir.make
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '61F',
  'dir.exists?(filename) false when file does not exist, true when it does' do
    dir = disk['/tmp/61F']
    dir.make
    refute dir.exists?(filename )
    dir.write(filename, content)
    assert dir.exists?(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D4C',
  'dir.read() reads back what dir.write() wrote' do
    dir = disk['/tmp/D4C']
    dir.make
    dir.write(filename, content)
    assert_equal content, dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D4D',
  'dir.append() appends!' do
    dir = disk['/tmp/D4D']
    dir.make
    dir.append(filename, "A\n")
    dir.append(filename, "B\n")
    dir.append(filename, "C\n")
    assert_equal "A\nB\nC\n", dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0CC',
  'dir.each_dir() returns dir names but not . or ..' do
    dir = disk['/tmp/0CC']
    disk['/tmp/0CC/alpha'].make
    disk['/tmp/0CC/beta' ].make
    disk['/tmp/0CC/gamma'].make
    disk['/tmp/0CC/.git' ].make
    assert_equal %w( .git alpha beta gamma ), dir.each_dir.entries.sort
  end

  test '7E1',
  'dir.each_dir() returns [] when there are no sub-dirs' do
    dir = disk['/tmp/7E1']
    dir.make
    assert_equal [], dir.each_dir.entries
  end

  private # = = = = = = = = = = = = = = = =

  def filename
    'limerick.txt'
  end

  def content
    'the boy stood on the burning deck'
  end

end