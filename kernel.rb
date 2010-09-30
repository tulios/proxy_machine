require 'proxy_machine'
module Kernel
  
  def proxy_for object, callbacks = nil
    Proxy.new object, callbacks
  end
  
end