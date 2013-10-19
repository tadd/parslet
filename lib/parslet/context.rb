# Provides a context for tree transformations to run in. The context allows
# accessing each of the bindings in the bindings hash as local method.
#
# Example: 
#
#   ctx = Context.new(:a => :b)
#   ctx.instance_eval do 
#     a # => :b
#   end
#
# @api private
class Parslet::Context
  RESERVED =
    (%w(methods respond_to? inspect to_s instance_variable_set object_id) +
     BasicObject.instance_methods).map(&:to_sym)
  private_constant :RESERVED
  instance_methods.each { |m| undef_method m unless RESERVED.include?(m) }
  
  def meta_def(name, &body)
    metaclass = class <<self; self; end

    metaclass.send(:define_method, name, &body)
  end
  
  def initialize(bindings)
    bindings.each do |key, value|
      meta_def(key.to_sym) { value }
      instance_variable_set("@#{key}", value)
    end
  end
end
