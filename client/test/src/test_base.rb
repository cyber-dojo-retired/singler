require_relative 'external_disk'
require_relative 'external_sheller'
require_relative 'hex_mini_test'
require_relative 'storer_service'
require_relative '../../src/zipper_service'

class TestBase < HexMiniTest

  def zipper
    @zipper ||= ZipperService.new
  end

  def storer
    @storer ||= StorerService.new(self)
  end

  def shell
    @shell ||= ExternalSheller.new(self)
  end

  def disk
    @disk ||= ExternalDisk.new(self)
  end

  # - - - - - - - - - - - - - - - - - - -

  def zip(kata_id)
    zipper.zip(kata_id)
  end

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
