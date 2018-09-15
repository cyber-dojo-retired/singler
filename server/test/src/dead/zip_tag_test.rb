require 'base64'
require_relative 'zipper_test_base'
require_relative '../../src/id_splitter'

class ZipTagTest < ZipperTestBase

  def self.hex_prefix
    '0AA1E'
  end

  def log
    @log ||= NullLogger.new(self)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Positive test
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2A8',
  'zip_tag() unzipped content matches storer content' do
    started_kata_args.each do |kata_id, avatar_name, max_tag|
      (0..max_tag).each do |tag|
        Dir.mktmpdir('downloader') do |tmp_dir|

          encoded = zip_tag(kata_id, avatar_name, tag)
          tgz_filename = "#{tmp_dir}/#{kata_id}_#{avatar_name}_#{tag}.tgz"
          File.open(tgz_filename, 'wb') { |file| file.write(Base64.decode64(encoded)) }

          _,status = shell.cd_exec(tmp_dir, "cat #{tgz_filename} | tar xfz -")
          assert_equal 0, status
          tgz_dir = disk[[tmp_dir, kata_id, avatar_name, tag].join('/')]
          visible_files = storer.tag_visible_files(kata_id, avatar_name, tag)
          visible_files.delete('output')
          visible_files.each do |filename,expected|
            actual = tgz_dir.read(filename)
            assert_equal expected, actual, filename
          end

          start_point_manifest = tgz_dir.read_json('manifest.json')
          assert_equal visible_files.keys.sort, start_point_manifest['visible_filenames']

          kata_manifest = storer.kata_manifest(kata_id)
          required = [ 'display_name', 'image_name' ]
          required.each do |key|
            refute_nil start_point_manifest[key]
            assert_equal kata_manifest[key], start_point_manifest[key]
          end
          optional = [ 'filename_extension', 'tab_size' ]
          optional.each do |key|
            assert_equal kata_manifest[key], start_point_manifest[key]
          end
          patched = 'progress_regexs'
          unless kata_manifest[patched] == []
            assert_equal kata_manifest[patched], start_point_manifest[patched]
          end
        end
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Negative tests
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '885',
  'zip_tag with invalid argument raises' do
    ukid = unstarted_kata_id
    skid = started_kata_args[0][kata_id=0]
    skan = started_kata_args[0][avatar_name=1]
    args = [
      ['',   'salmon', 0,      'kata_id:malformed'    ],
      ['XX', 'salmon', 0,      'kata_id:malformed'    ],
      [ukid, '',       0,      'avatar_name:malformed'],
      [ukid, 'xxx',    0,      'avatar_name:malformed'],
      [skid, skan,    '',      'tag:malformed'        ],
      [skid, skan,  'xx',      'tag:malformed'        ],
      [ukid, 'salmon', 0,      'avatar_name:invalid'  ],
      [skid, skan,     1,      'tag:invalid'          ],
    ]
    args.each do |kata_id, avatar_name, tag, message|
      error = assert_raises {
        zip_tag(kata_id, avatar_name, tag)
      }
      assert_equal 'ServiceError', error.class.name
      assert_equal 'StorerService', error.service_name
      assert_equal 'tag_visible_files', error.method_name
      exception = JSON.parse(error.message)
      refute_nil exception
      assert_equal 'ArgumentError', exception['class']
      assert_equal message, exception['message']
      assert_equal 'Array', exception['backtrace'].class.name
    end
  end

end
