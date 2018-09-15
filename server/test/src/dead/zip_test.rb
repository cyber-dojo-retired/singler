require 'base64'
require_relative 'zipper_test_base'
require_relative 'null_logger'
require_relative '../../src/id_splitter'

class ZipTest < ZipperTestBase

  def self.hex_prefix
    '03DB2'
  end

  def log
    @log ||= NullLogger.new(self)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BEC',
  'zip with empty id raises' do
    error = assert_raises { zip(id = '') }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'StorerService', error.service_name
    assert_equal 'kata_manifest', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ArgumentError', exception['class']
    assert_equal 'kata_id:malformed', exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '849',
  'zip with bad id raises' do
    error = assert_raises { zip(id = 'XX') }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'StorerService', error.service_name
    assert_equal 'kata_manifest', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ArgumentError', exception['class']
    assert_equal 'kata_id:malformed', exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '561',
  'info from unzipped files matches info from storer' do
    started_kata_ids = started_kata_args.map { |args| args[0] }
    (started_kata_ids + [ unstarted_kata_id ]).each do |id|
      encoded = zip(id)
      assert_unzip_matches_storer(id, encoded)
    end
  end

  private # = = = = = = = = = = = = = = = = = =

  def assert_unzip_matches_storer(id, encoded)
    Dir.mktmpdir('zipper') do |tmp_dir|
      tgz_filename = "#{tmp_dir}/#{id}.tgz"
      File.open(tgz_filename, 'wb') { |file|
        file.write(Base64.decode64(encoded))
      }

      command = "cat #{tgz_filename} | tar xfz -"
      _,status = shell.cd_exec(tmp_dir, command)
      assert_equal 0, status, "FAILED: #{command}"

      kata_path = "#{tmp_dir}/#{outer(id)}/#{inner(id)}"
      zipper_manifest = disk[kata_path].read_json('manifest.json')
      storer_manifest = storer.kata_manifest(id)
      diagnostic = "#{id} manifests are NOT the same"
      assert_equal storer_manifest, zipper_manifest, diagnostic

      storer.avatars_started(id).each do |avatar_name|
        avatar_path = "#{kata_path}/#{avatar_name}"
        zipper_rags = disk[avatar_path].read_json('increments.json')
        storer_rags = storer.avatar_increments(id, avatar_name)
        # storer does not store tag0 in each avatar's manifest.
        # Retain this form so a tgz file can be copied between
        # storers on different servers.
        storer_rags.shift
        diagnostic = "#{id}-#{avatar_name} increments are NOT the same"
        assert_equal storer_rags, zipper_rags, diagnostic

        (1..zipper_rags.size).each do |tag|
          tag_path = "#{avatar_path}/#{tag}"
          zipper_tag = disk[tag_path].read_json('manifest.json')
          storer_tag = storer.tag_visible_files(id, avatar_name, tag)
          diagnostic = "#{id}-#{avatar_name}-#{tag} tag is NOT the same"
          assert_equal storer_tag, zipper_tag, diagnostic
        end
      end
    end
  end

  include IdSplitter

end
