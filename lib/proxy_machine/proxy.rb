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
      @method = symbol.to_s
                                             
      raise NoMethodError.new(@method) unless @allow_dinamic or @object.methods.member?(@method)
      
      execute_call(@before_all, @object, symbol, args)
      execute_call(@before, @object)
                              
      @result = @avoid_original_execution ? nil : @object.send(@method, *args)

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
      
      result = nil
      if executor.class == Array
        executor.each do |e|
          result = e.send :call, *args if proc?(e)
          result = e.send(:new, *args).send :call if class?(e) 
        end
        return result
      end                    
      
      return executor.send :call, *args if proc?(executor)
      return executor.send(:new, *args).send :call if class?(executor) 
    end
    
    def get_executor container
      return nil unless container                              
      
      # The content is a proc or a class
      return container if proc?(container) or class?(container)
      
      # The content is a hash with an array filled with a regex and a proc or a class
      if hash?(container) and regexp?(container)
        matched = regexp_elements(container).select {|array| get_regexp(array) =~ @method}
        return matched.collect {|array| get_proc_or_class(array)} unless matched.empty?
      end
      
      # Lets assume that the content of the key is a proc
      container[@symbol]
    end
                
    def regexp_elements hash
      elements = hash.keys.sort.collect {|key| array_with_regex?(hash[key]) ? hash[key] : nil}
      compacted_array = elements.compact
      compacted_array.nil? ? [] : compacted_array
    end
    
    def get_regexp array
      array.detect {|element| element.class == Regexp}
    end
    
    def get_proc_or_class array
      array.detect {|element| proc?(element) or class?(element)}
    end  
    
    def array_with_regex? array
      array.class == Array and array.size == 2 and not get_regexp(array).nil?
    end
    
    def proc? block; block and block.class == Proc end
    def class? param; param and param.class == Class end
    def hash? param; param and param.class == Hash end
    def regexp? hash; hash and not regexp_elements(hash).empty? end

  end
  
end


































