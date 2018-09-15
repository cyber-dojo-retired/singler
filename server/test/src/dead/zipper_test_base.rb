require_relative 'hex_mini_test'
require_relative '../../src/externals'
require_relative '../../src/zipper'

class ZipperTestBase < HexMiniTest

  include Externals

  def zipper
    Zipper.new(self)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def sha
    zipper.sha
  end

  def zip(kata_id)
    zipper.zip(kata_id)
  end

  def zip_tag(kata_id, avatar_name, tag)
    zipper.zip_tag(kata_id, avatar_name, tag)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def unstarted_kata_id
    'DADD67B4EF' # C (gcc), assert [no progress_regexs]
  end

  def started_kata_args
    [
      # C (gcc), assert [no progress_regexs]
      ['F6986222F0', 'spider',    0],
      ['697C14EDF4', 'turtle',    3],
      ['7AF23949B7', 'alligator', 3],
      ['7AF23949B7', 'heron',     3],
      ['7AF23949B7', 'squid',     3],
      # C (gcc), CppUTest [has progress_regexs]
      ['9EEBD21136', 'turtle',    3],
      ['3FAFDE61E4', 'lion',      7]
    ]
  end

end
