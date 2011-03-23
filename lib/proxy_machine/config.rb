module ProxyMachine
  class Config
    
    attr_reader :callbacks
    def initialize
      @callbacks = {}
    end
    
    def apply! &block
      instance_exec(&block)
    end
    
    def before hash
      @callbacks[:before] = hash
    end
    
    def before_all &block
      @callbacks[:before_all] = block
    end
    
    def after hash
      @callbacks[:after] = hash
    end
    
    def after_all &block
      @callbacks[:after_all] = block
    end
    
  end
end