require_relative 'zipper_test_base'
require_relative 'null_logger'

class ExternalDiskDirTest < ZipperTestBase

  def self.hex_prefix
    '43779'
  end

  def hex_setup
    `rm -rf #{path}`
  end

  def log
    @log ||= NullLogger.new(self)
  end

  test 'EB1',
  'disk[...].path always ends in /' do
    dir.make
    assert_equal 'ABC/', disk['ABC'].path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F3',
  'disk[path].make returns',
  'true when it makes the directory',
  'false when it does not' do
    refute dir.exists?, 'dir already exists!'
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '39D',
  'object = read_json(filename) after write_json(filename, object) round-strips ok' do
    filename = 'object.json'
    assert dir.make
    refute dir.exists?(filename), "#{filename} already exists!"
    dir.write_json(filename, { 'a' => 1, 'b' => 2 })
    assert dir.exists?(filename)
    json = dir.read_json(filename)
    assert_equal 1, json['a']
    assert_equal 2, json['b']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'ACA',
  'disk.dir?(.) is true' do
    assert dir.make
    assert disk.dir?(path + '/' + '.')
  end

  test 'A3F',
  'disk.dir?(..) is true' do
    assert dir.make
    assert disk.dir?(path + '/' + '..')
  end

  test 'E82',
  'disk.dir?(a-dir) is true' do
    assert dir.make
    assert disk.dir?(path)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '40A',
  'disk.dir?(not-a-dir) is false' do
    refute disk.dir?('blah-blah')
  end

  private

  def dir
    disk[path]
  end

  def path
    tmp_root + '/' + 'host_disk_dir_tests' + '/' + test_id
  end

  def tmp_root
    '/tmp/cyber-dojo'
  end

end

