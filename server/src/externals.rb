require_relative 'iid_generator'
require_relative 'singler'

module Externals # mix-in

  def singler
    @singler ||= Singler.new(self)
  end

  def iid_generator
    @generator ||= IidGenerator.new(self)
  end

end
