module ProxyMachine
  
  class Proxy < BasicObject

    def initialize object, calls = nil
      @object = object                    
      @before = @before_all = @after = @after_all = nil
      
      if calls                  
        @before = calls[:before]
        @before_all = calls[:before_all]
        @after = calls[:after]
        @after_all = calls[:after_all]
      end
    end
                            
    def method_missing(symbol, *args)
      @symbol = symbol        
      method = symbol.to_s
      raise NoMethodError.new(method) unless @object.methods.member?(method)
                                       
      execute_call(@before_all, @object)
      execute_call(@before, @object)

      @result = @object.send(method, *args)

      result_after = execute_call(@after, @object, @result)
      result_after_all = execute_call(@after_all, @object, @result)
         
      return result_after_all if result_after_all
      return result_after if result_after
      @result
    end
    
    def proxied_class?; true end
    
    private               
    def execute_call container, *args
      executor = get_executor(container)
      
      return executor.send :call, *args if proc?(executor)
      return executor.send(:new, *args).send :call if class?(executor) 
    end
    
    def get_executor container
      if container
        return container if proc?(container) or class?(container)
        return container[@symbol]
      end
    end
                
    def proc? block
      block and block.class == Proc
    end
    
    def class? param
      param and param.class == Class
    end
    
  end
  
end


































