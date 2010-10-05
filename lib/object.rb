require 'proxy_machine'
require 'kernel'

class Object
  
  def proxied?
    not (defined? self.proxied_class?).nil?
  end
  
end