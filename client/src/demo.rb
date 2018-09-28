require_relative 'singler_service'
require_relative 'starter_service'

class Demo

  def call(_env)
    inner_call
  rescue => error
    [ 200, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  def inner_call
    html = [
      create,
      manifest,
      ran_tests,
      visible_files,
      increments
    ].join
    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

  private

  def create
    pre {
      @id = singler.create(starter.manifest, starter.files)
    }
  end

  def manifest
    pre {
      singler.manifest(@id)
    }
  end

  def ran_tests
    pre {
      singler.ran_tests(@id, edited_files, now, stdout, stderr, colour)
    }
  end

  def visible_files
    pre {
      singler.visible_files(@id)
    }
  end

  def increments
    pre {
      singler.increments(@id)
    }
  end

  # - - - - - - - - - - - - - - - - -

  def edited_files
    files = starter.files
    edited = files['hiker.c']
    files['hiker.c'] = edited.sub('6 * 9', '6 * 7')
    files
  end

  def now
    [2016,12,2, 6,14,37]
  end

  def stdout
    'All tests passed'
  end

  def stderr
    ''
  end

  def colour
    'green'
  end

  # - - - - - - - - - - - - - - - - -

  def pre(&block)
    result,duration = *timed { block.call }
    [
      "<pre>/#{name_of(caller)}(#{duration}s)</pre>",
      "<pre style='#{style}'>",
        "#{JSON.pretty_unparse(result)}",
      '</pre>'
    ].join
  end

  def style
    [whitespace,margin,border,padding,background].join
  end

  def border
    'border: 1px solid black;'
  end

  def padding
    'padding: 10px;'
  end

  def margin
    'margin-left: 30px; margin-right: 30px;'
  end

  def background
    'background: white;'
  end

  def whitespace
    'white-space: pre-wrap;'
  end

  # - - - - - - - - - - - - - - - - -

  def name_of(caller)
    # eg caller[0] == "demo.rb:50:in `increments'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  # - - - - - - - - - - - - - - - - -

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = '%.4f' % (finished - started)
    return [result,duration]
  end

  # - - - - - - - - - - - - - - - - -

  def singler
    SinglerService.new
  end

  def starter
    StarterService.new
  end

end


