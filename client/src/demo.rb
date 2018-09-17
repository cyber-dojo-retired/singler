require_relative 'singler_service'

class Demo

  def call(_env)

    colour = 'white'
    border = 'border:1px solid black'
    padding = 'padding:10px'
    background = "background:#{colour}"
    html = ''

    html += "<pre style='#{border};#{padding};#{background}'>"
    html += ''
    html += '</pre>'

    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

  private

  def singler
    SinglerService.new
  end

end


