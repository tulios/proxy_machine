module ProxyMachine
  
  class BasicObject #:nodoc:
    instance_methods.each { |m| undef_method m unless m =~ /^__|instance_eval/ }
  end unless defined?(BasicObject)
  
end
                    
require 'kernel'
require 'object'
require 'symbol'                            
require 'proxy_machine/proxy'
require 'proxy_machine/config'
include ProxyMachine