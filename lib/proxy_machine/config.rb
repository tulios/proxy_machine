module ProxyMachine
  class Config
    
    attr_reader :callbacks
    def initialize
      @callbacks = {}
    end
    
    def apply! &block
      instance_exec(&block)
    end
    
    def allow_dinamic boolean
      @callbacks[:allow_dinamic] = boolean
    end
    
    def avoid_original_execution boolean
      @callbacks[:avoid_original_execution] = boolean
    end
    
    def before hash
      @callbacks[:before] = hash
    end
    
    def before_all params = nil, &block
      @callbacks[:before_all] = params ? params : block
    end
    
    def after hash
      @callbacks[:after] = hash
    end
    
    def after_all params = nil, &block
      @callbacks[:after_all] = params ? params : block
    end
    
  end
end