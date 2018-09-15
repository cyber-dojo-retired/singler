require_relative 'zipper_service'

class Demo

  def call(_env)
    tgz_filename = zipper.zip('7AF23949B7')

    colour = 'white'
    border = 'border:1px solid black'
    padding = 'padding:10px'
    background = "background:#{colour}"
    html = ''

    html += "<pre style='#{border};#{padding};#{background}'>"
    html += tgz_filename
    html += '</pre>'

    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

  private

  def zipper
    ZipperService.new
  end

end


