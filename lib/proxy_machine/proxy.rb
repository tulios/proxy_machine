module ProxyMachine
  
  class Proxy < BasicObject

    def initialize object, params = nil
      @object = object                    
      @before = @before_all = @after = @after_all = nil
      @allow_dinamic = false
      @avoid_original_execution = false
      
      if params
        @allow_dinamic = params[:allow_dinamic]
        @avoid_original_execution = params[:avoid_original_execution]
        @before = params[:before]
        @before_all = params[:before_all]
        @after = params[:after]
        @after_all = params[:after_all]
      end
    end
                            
    def method_missing(symbol, *args)
      @symbol = symbol        
      method = symbol.to_s
      
      unless @allow_dinamic
        raise NoMethodError.new(method) unless @object.methods.member?(method)
      end
                                       
      execute_call(@before_all, @object, symbol, args)
      execute_call(@before, @object)
                              
      @result = @avoid_original_execution ? nil : @object.send(method, *args)

      result_after = execute_call(@after, @object, @result)
      result_after_all = execute_call(@after_all, @object, @result, symbol, args)
         
      return result_after_all if result_after_all
      return result_after if result_after
      @result
    end
    
    def proxied_class?; true end
    def original_object; @object end
    
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


































