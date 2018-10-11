require_relative 'test_base'
require_relative '../../src/well_formed_args'

class WellFormedArgsTest < TestBase

  def self.hex_prefix
    '0A0'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # c'tor
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A49',
  'ctor raises when its string arg is not valid json' do
    expected = 'json:malformed'
    # abc is not a valid top-level json element
    error = assert_raises { WellFormedArgs.new('abc') }
    assert_equal expected, error.message
    # nil is null in json
    error = assert_raises { WellFormedArgs.new('{"x":nil}') }
    assert_equal expected, error.message
    # keys have to be strings in json
    error = assert_raises { WellFormedArgs.new('{42:"answer"}') }
    assert_equal expected, error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '591',
  'manifest does not raise when well-formed' do
    manifest = starter.manifest
    manifest['files'] = starter.files
    json = { manifest:manifest }.to_json
    assert_equal manifest, WellFormedArgs.new(json).manifest
    manifest['filename_extension'] = '.c'
    json = { manifest:manifest }.to_json
    assert_equal manifest, WellFormedArgs.new(json).manifest
  end

  test '592',
  'manifest raises when malformed' do
    malformed_manifests.each do |malformed|
      json = { manifest:malformed }.to_json
      error = assert_raises {
        WellFormedArgs.new(json).manifest
      }
      assert_equal 'manifest:malformed', error.message, malformed
    end
  end

  def malformed_manifests
    bad_time = [2018,-3,28, 11,33,13]
    [
      [],                                                 # ! Hash
      {},                                                 # required key missing
      starter_manifest.merge({x:'unknown'}),              # unknown key
      starter_manifest.merge({files:[]}),                 # ! Hash
      starter_manifest.merge({files:{'s' => [4]}}),       # ! Hash{s->s}
      starter_manifest.merge({id:42}),                    # ! String
      starter_manifest.merge({group:42}),                 # ! String
      starter_manifest.merge({display_name:42}),          # ! String
      starter_manifest.merge({image_name:42}),            # ! String
      starter_manifest.merge({runner_choice:42}),         # ! String
      starter_manifest.merge({filename_extension:true}),  # ! String && ! Array
      starter_manifest.merge({filename_extension:{}}),    # ! String && ! Array
      starter_manifest.merge({filename_extension:[1]}),   # ! Array[String]
      starter_manifest.merge({exercise:true}),            # ! String
      starter_manifest.merge({highlight_filenames:1}),    # ! Array of Strings
      starter_manifest.merge({highlight_filenames:[1]}),  # ! Array of Strings
      starter_manifest.merge({progress_regexs:{}}),       # ! Array of Strings
      starter_manifest.merge({progress_regexs:[1]}),      # ! Array of Strings
      starter_manifest.merge({tab_size:true}),       # ! Integer
      starter_manifest.merge({max_seconds:nil}),     # ! Integer
      starter_manifest.merge({created:nil}),         # ! Array of 6 Integers
      starter_manifest.merge({created:['s']}),       # ! Array of 6 Integers
      starter_manifest.merge({created:bad_time}),    # ! Time
    ]
  end

  def starter_manifest
    manifest = starter.manifest
    manifest[:files] = starter.files
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # files
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '846',
  'files does not raise when well-formed' do
    files = { 'cyber-dojo.sh' => 'make' }
    json = { files:files }.to_json
    assert_equal files, WellFormedArgs.new(json).files
  end

  test '847',
  'files raises when malformed' do
    expected = 'files:malformed'
    malformed_files.each do |malformed|
      json = { files:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.files }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_files
    [
      [],              # ! Hash
      { "x" => 42 },   # content ! String
      { "y" => true }, # content ! String
      { "z" => nil },  # content ! String
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '61A',
  'id does not raise when well-formed' do
    id = 'A1B2F3'
    json = { id:id }.to_json
    assert_equal id, WellFormedArgs.new(json).id
  end

  test '61B',
  'id raises when malformed' do
    expected = 'id:malformed'
    malformed_ids.each do |malformed|
      json = { id:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.id }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_ids
    [
      nil,          # ! String
      [],           # ! string
      '',           # ! 6 chars
      '1234',       # ! 6 chars
      '12345',      # ! 6 chars
      '1234567',    # ! 6 chars
      '12345='      # ! Base58 chars
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # now
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FF4',
  'now does not raise when well-formed' do
    now = [2018,3,28, 19,18,45]
    json = { now:now }.to_json
    assert_equal now, WellFormedArgs.new(json).now
  end

  test 'FF5',
  'now raises when malformed' do
    expected = 'now:malformed'
    malformed_nows.each do |malformed|
      json = { now:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.now }
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_nows
    [
      [], {}, nil, true, 42,    # ! Arrays
      ["2018",3,28, 19,18,45],  # ! Array[String]
      [2018,3,28, 19,18],       # ! Array.length == 6
      [2018,-3,28,  19,18,45]   # ! Time
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # stdout
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E35',
  'stdout does not raise when well-formed' do
    stdout = 'gsdfg'
    json = { stdout:stdout }.to_json
    assert_equal stdout, WellFormedArgs.new(json).stdout
  end

  test 'E36',
  'stdout raises when malformed' do
    expected = 'stdout:malformed'
    malformed_stdouts.each do |malformed|
      json = { stdout:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.stdout }
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_stdouts
    [ nil, true, [1], {} ] # ! String
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # stderr
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8DB',
  'stderr does not raise when well-formed' do
    stderr = 'ponoi'
    json = { stderr:stderr }.to_json
    assert_equal stderr, WellFormedArgs.new(json).stderr
  end

  test '8DC',
  'stderr raises when malformed' do
    expected = 'stderr:malformed'
    malformed_stderrs.each do |malformed|
      json = { stderr:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.stderr }
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_stderrs
    [ nil, true, [1], {} ] # ! String
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # status
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CD3',
  'status does not raise when well-formed' do
    oks = [ 0, 24, 255 ]
    oks.each do |status|
      json = { status:status }.to_json
      assert_equal status, WellFormedArgs.new(json).status
    end
  end

  test 'CD4',
  'status raises when malformed' do
    expected = 'status:malformed'
    malformeds = [ nil, true, [1], {}, '', '23', -1, 256 ]
    malformeds.each do |malformed|
      json = { status:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      diagnostic = ":#{malformed.to_s}:"
      error = assert_raises(diagnostic) { wfa.status }
      assert_equal expected, error.message, diagnostic
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # n
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '237',
  'n does not raise when well-formed' do
    oks = [ -1, 0, 104 ]
    oks.each do |n|
      json = { n:n }.to_json
      assert_equal n, WellFormedArgs.new(json).n
    end
  end

  test '238',
  'n raises when malformed' do
    expected = 'n:malformed'
    malformeds = [ nil, true, [1], {}, '', '23', -2 ]
    malformeds.each do |malformed|
      json = { n:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      diagnostic = ":#{malformed.to_s}:"
      error = assert_raises(diagnostic) { wfa.n }
      assert_equal expected, error.message, diagnostic
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '041',
  'colour does not raise when well-formed' do
    colours = [ 'red', 'amber', 'green', 'timed_out' ]
    colours.each do |colour|
      json = { colour:colour }.to_json
      assert_equal colour, WellFormedArgs.new(json).colour
    end
  end

  test '042',
  'colour raises when malformed' do
    expected = 'colour:malformed'
    malformed_colours.each do |malformed|
      json = { colour:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.colour }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_colours
    [ nil, true, {}, [], 'RED' ]
  end

end