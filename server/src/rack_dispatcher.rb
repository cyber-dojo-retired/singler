require_relative 'client_error'
require_relative 'well_formed_args'
require 'json'

# Rack calls singler.kata_create() in threads so in
# theory you could get a race condition with both
# threads attempting a create with the same id.
# Assuming id generation is reasonably well behaved
# (random and large alphabet) this is extremely unlikely.

class RackDispatcher

  def initialize(singler, request_class)
    @singler = singler
    @request_class = request_class
  end

  def call(env)
    request = @request_class.new(env)
    path = request.path_info[1..-1] # lose leading /
    body = request.body.read
    name, args = validated_name_args(path, body)
    result = @singler.public_send(name, *args)
    json_response(200, plain({ name => result }))
  rescue => error
    diagnostic = pretty({
      'exception' => {
        'path' => path,
        'body' => body,
        'class' => error.class.name,
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    })
    $stderr.puts(diagnostic)
    $stderr.flush
    json_response(code(error), diagnostic)
  end

  private # = = = = = = = = = = = = = = = = = = =

  def validated_name_args(name, body)
    @well_formed_args = WellFormedArgs.new(body)
    args = case name
      when /^sha$/       then []
      when /^kata_exists$/    then [id]
      when /^kata_create$/    then [manifest, files]
      when /^kata_manifest$/  then [id]
      when /^kata_ran_tests$/ then [id, n, files, now, stdout, stderr, status, colour]
      when /^kata_tags$/      then [id]
      when /^kata_tag$/       then [id,n]
      else
        raise ClientError, 'json:malformed'
    end
    name += '?' if query?(name)
    [name, args]
  end

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  def plain(body)
    JSON.generate(body)
  end

  def pretty(body)
    JSON.pretty_generate(body)
  end

  def code(error)
    if error.is_a?(ClientError)
      400 # client_error
    else
      500 # server_error
    end
  end

  def self.well_formed_args(*names)
    names.each do |name|
      define_method name, &lambda {
        @well_formed_args.send(name)
      }
    end
  end

  well_formed_args :manifest, :files
  well_formed_args :id, :n
  well_formed_args :now, :stdout, :stderr, :status, :colour

  # - - - - - - - - - - - - - - - -

  def query?(name)
    name == 'kata_exists'
  end

end
