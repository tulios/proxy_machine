module ProxyMachine
  
  class BasicObject #:nodoc:
    instance_methods.each { |m| undef_method m unless m =~ /^__|instance_eval/ }
  end unless defined?(BasicObject)
  
end
                            
require 'proxy_machine/proxy'
include ProxyMachine

require 'kernel'
require 'object'