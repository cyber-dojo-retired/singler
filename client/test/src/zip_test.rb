require 'base64'
require_relative 'test_base'
require_relative 'id_splitter'

class ZipTest < TestBase

  def self.hex_prefix
    'CE167'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '8BE',
  'zip raises when kata_id is empty' do
    error = assert_raises { zip(kata_id = '') }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'ZipperService', error.service_name
    assert_equal 'zip', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ServiceError', exception['class']
    json = JSON.parse(exception['message'])
    assert_equal 'ArgumentError', json['class']
    assert_equal 'kata_id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '8BF',
  'zip raises when kata_id is malformed' do
    error = assert_raises { zip(kata_id = '--') }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'ZipperService', error.service_name
    assert_equal 'zip', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ServiceError', exception['class']
    json = JSON.parse(exception['message'])
    assert_equal 'ArgumentError', json['class']
    assert_equal 'kata_id:malformed', json['message']
    assert_equal 'Array', json['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '561',
  'info from unzipped files matches info from storer' do
    # TODO: old-style katas (.git dir)
    started_kata_ids = started_kata_args.map { |args| args[0] }
    (started_kata_ids + [ unstarted_kata_id ]).each do |id|
      encoded = zip(id)
      assert_unzip_matches_storer(id, encoded)
    end
  end

  private # = = = = = = = = = = = = = = = = = =

  include IdSplitter

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

end
