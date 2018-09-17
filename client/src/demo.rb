require_relative 'singler_service'
require_relative 'starter_service'

class Demo

  def call(_env)
    inner_call
  rescue => error
    [ 200, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  def inner_call
    @html = ''
    create
    manifest
    ran_tests
    visible_files
    increments
    [ 200, { 'Content-Type' => 'text/html' }, [ @html ] ]
  end

  private

  def create
    manifest = make_manifest
    manifest['created'] = [2016,12,2, 6,13,23]
    result,duration = *timed { @id = singler.create(manifest) }
    @html += pre(__method__, result, duration)
  end

  def manifest
    result,duration = *timed { singler.manifest(@id) }
    @html += pre(__method__, result, duration)
  end

  def ran_tests
    edited_files = starting_files
    c = edited_files['hiker.c']
    edited_files['hiker.c'] = c.sub('6 * 9', '6 * 7')
    now = [2016,12,2, 6,14,37]
    stdout = 'All tests passed'
    stderr = ''
    colour = 'green'
    result,duration = *timed {
      singler.ran_tests(@id, edited_files, now, stdout, stderr, colour)
    }
    @html += pre(__method__, result, duration)
  end

  def visible_files
    result,duration = *timed { singler.visible_files(@id) }
    @html += pre(__method__, result, duration)
  end

  def increments
    result,duration = *timed { singler.increments(@id) }
    @html += pre(__method__, result, duration)
  end

  # - - - - - - - - - - - - - - - - -

  def make_manifest
    starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
  end

  def starting_files
    make_manifest['visible_files'].dup
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

  def pre(name, result, duration)
    border = 'border: 1px solid black;'
    padding = 'padding: 10px;'
    margin = 'margin-left: 30px; margin-right: 30px;'
    background = "background: white;"
    whitespace = "white-space: pre-wrap;"

    html = "<pre>/#{name}(#{duration}s)</pre>"
    html += "<pre style='#{whitespace}#{margin}#{border}#{padding}#{background}'>" +
            "#{JSON.pretty_unparse(result)}" +
            '</pre>'
    html
  end

  # - - - - - - - - - - - - - - - - -

  def singler
    SinglerService.new
  end

  def starter
    StarterService.new
  end

end


