require 'proxy_machine'

module Kernel
  
  def proxy_for object, callbacks = nil
    ProxyMachine::Proxy.new object, callbacks
  end
  
  def auto_proxy &block
    @proxy_machine_config = ProxyMachine::Config.new
    @proxy_machine_config.apply!(&block)
    
    def self.new(*args)
      obj = allocate
      obj.send(:initialize, *args)
      proxy_for obj, @proxy_machine_config.callbacks
    end
  end
  
end