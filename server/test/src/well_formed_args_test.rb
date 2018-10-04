require_relative 'test_base'
require_relative '../../src/well_formed_args'

class WellFormedArgsTest < TestBase

  def self.hex_prefix
    '0A0C4'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # c'tor
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A04',
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
      [],                                                # ! Hash
      {},                                                # required key missing
      starter.manifest.merge({x:'unknown'}),              # unknown key
      starter.manifest.merge({display_name:42}),          # ! String
      starter.manifest.merge({image_name:42}),            # ! String
      starter.manifest.merge({runner_choice:42}),         # ! String
      starter.manifest.merge({filename_extension:true}),  # ! String && ! Array
      starter.manifest.merge({filename_extension:{}}),    # ! String && ! Array
      starter.manifest.merge({exercise:true}),            # ! String
      starter.manifest.merge({highlight_filenames:1}),    # ! Array of Strings
      starter.manifest.merge({highlight_filenames:[1]}),  # ! Array of Strings
      starter.manifest.merge({progress_regexs:{}}),       # ! Array of Strings
      starter.manifest.merge({progress_regexs:[1]}),      # ! Array of Strings
      starter.manifest.merge({tab_size:true}),       # ! Integer
      starter.manifest.merge({max_seconds:nil}),     # ! Integer
      starter.manifest.merge({created:nil}),         # ! Array of 6 Integers
      starter.manifest.merge({created:['s']}),       # ! Array of 6 Integers
      starter.manifest.merge({created:bad_time}),    # ! Time
    ]
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
    id = 'A1B2F345kn'
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
      '',           # ! 10 chars
      '34',         # ! 10 chars
      '345',        # ! 10 chars
      '123456789',  # ! 10 chars
      'ABCDEF123='  # ! Base58 chars
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # outer_id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C6B',
  'outer_id does not raise when well-formed' do
    outer_id = '12'
    json = { outer_id:outer_id }.to_json
    assert_equal outer_id, WellFormedArgs.new(json).outer_id
  end

  test 'CB7',
  'outer_id raises when malformed' do
    expected = 'outer_id:malformed'
    malformed_outer_ids.each do |malformed|
      json = { outer_id:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.outer_id }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_outer_ids
    [
      true,  # ! String
      '=',   # ! Base58 String
      '123', # ! length 2
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # partial_id
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'FC1',
  'partial_id does not raise when well-formed' do
    partial_id = '1a34Z6'
    json = { partial_id:partial_id }.to_json
    assert_equal partial_id, WellFormedArgs.new(json).partial_id
  end

  test 'FC2',
  'partial_id raises when malformed' do
    expected = 'partial_id:malformed'
    malformed_partial_ids.each do |malformed|
      json = { partial_id:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.partial_id }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_partial_ids
    [
      false,    # ! String
      '=',      # ! Base58 String
      'abc'     # ! length 6..10
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
      [], {}, nil, true, 42,
      [2018,-3,28, 19,18,45],
      [2018,3,28, 19,18]
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
    status = '24'
    json = { status:status }.to_json
    assert_equal status, WellFormedArgs.new(json).status
  end

  test 'CD4',
  'status raises when malformed' do
    expected = 'status:malformed'
    malformed_statuses.each do |malformed|
      json = { status:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.status }
      assert_equal expected, error.message, malformed.to_s
    end
  end

  def malformed_statuses
    [ nil, true, [1], {}, # ! String
      '',     # empty
      'asd',  # ! Integer
      '-23',  # negative
      '23x',  # trailing chars
      'x23'   # leading chars
    ]
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

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # tag
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4A4',
  'tag does not raise when well-formed' do
    tag = 42
    json = { tag:tag }.to_json
    assert_equal tag, WellFormedArgs.new(json).tag
  end

  test '4A5',
  'tag raises when malformed' do
    expected = 'tag:malformed'
    malformed_tags.each do |malformed|
      json = { tag:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.tag }
      assert_equal expected, error.message, malformed
    end
  end

  def malformed_tags
    [
      nil,          # ! Integer
      [],           # ! Integer
      'sunglasses', # ! Integer
      '42'          # ! Integer
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # was_tag
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B43',
  'was_tag does not raise when well-formed' do
    was_tag = 2
    json = { was_tag:was_tag }.to_json
    assert_equal was_tag, WellFormedArgs.new(json).was_tag
  end

  test 'B44',
  'was_tag raises when malformed' do
    expected = 'was_tag:malformed'
    malformed_tags.each do |malformed|
      json = { was_tag:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.was_tag }
      assert_equal expected, error.message, malformed
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # now_tag
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C28',
  'now_tag does not raise when well-formed' do
    now_tag = 5
    json = { now_tag:now_tag }.to_json
    assert_equal now_tag, WellFormedArgs.new(json).now_tag
  end

  test 'C29',
  'now_tag raises when malformed' do
    expected = 'now_tag:malformed'
    malformed_tags.each do |malformed|
      json = { now_tag:malformed }.to_json
      wfa = WellFormedArgs.new(json)
      error = assert_raises { wfa.now_tag }
      assert_equal expected, error.message, malformed
    end
  end

end