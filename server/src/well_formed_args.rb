require_relative 'base58'
require 'json'

# Checks for arguments synactic correctness

class WellFormedArgs

  def initialize(s)
    @args = JSON.parse(s)
  rescue
    raise ArgumentError.new('json:malformed')
  end

  # - - - - - - - - - - - - - - - -

=begin
  def tag
    @arg_name = __method__.to_s
    malformed unless arg.is_a?(Integer)
    arg
  end

  # - - - - - - - - - - - - - - - -

  def malformed
    raise ArgumentError.new("#{arg_name}:malformed")
  end
=end

end