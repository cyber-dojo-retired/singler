require_relative 'client_error'
require_relative 'well_formed_args'
require 'json'

class RackDispatcher

  def initialize(singler, request)
    @singler = singler
    @request = request
  end

  def call(env)
    request = @request.new(env)
    name, args = validated_name_args(request)
    result = singler.public_send(name, *args)
    json_response(200, { name => result })
  rescue => error
    info = {
      'exception' => {
        'class' => error.class.name,
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    }
    $stderr.puts pretty(info)
    $stderr.flush
    json_response(status(error), info)
  end

  private # = = = = = = = = = = = = = = = = = = =

  def validated_name_args(request)
    name = request.path_info[1..-1] # lose leading /
    @well_formed_args = WellFormedArgs.new(request.body.read)
    args = case name
      when /^iid$/,
           /^sha$/                  then []
      else
        raise ClientError, 'json:malformed'
    end
    name += '?' if query?(name)
    [name, args]
  end

  def json_response(status, body)
    [ status, { 'Content-Type' => 'application/json' }, [ pretty(body) ] ]
  end

  def pretty(o)
    JSON.pretty_generate(o)
  end

  def status(error)
    error.is_a?(ClientError) ? 400 : 500
  end

  def self.well_formed_args(*names)
    names.each do |name|
      define_method name, &lambda { @well_formed_args.send(name) }
    end
  end

  #well_formed_args :manifest
  #well_formed_args :kata_id, :partial_id, :outer_id
  #well_formed_args :avatars_names, :avatar_name
  #well_formed_args :files, :now, :stdout, :stderr, :colour
  #well_formed_args :tag, :was_tag, :now_tag

  # - - - - - - - - - - - - - - - -

  def query?(name)
    name == 'exists'
  end

end
