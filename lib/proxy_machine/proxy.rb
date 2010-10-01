module ProxyMachine
  
  class Proxy < BasicObject
    
    # Examples:
    # 1º - Creates a proxy for the informed object
    #
    # p = Proxy.new [1,2,3]
    # p.size => 3
    #
    # 2º - A proxy with a before callback.
    #
    # p = Proxy.new [1,2,3], :before => {
    #   :size => lambda {|obj| puts "before: #{obj.inspect}"}
    # }
    # p.size => before: [1, 2, 3]
    #           3
    #                   
    # 3º - A proxy with a after callback
    #
    # p = Proxy.new [1,2,3], :after => {
    #   :size => lambda {|obj, result| puts "after: #{obj.inspect}: result => #{result}"}
    # }
    # p.size => after: [1, 2, 3]: result => 3
    #           3
    #                  
    # 4º - Both
    #
    # p = Proxy.new [1,2,3], 
    #               :before => {
    #                 :size => lambda {|obj| puts "before: #{obj.inspect}"}
    #               }, :after => {
    #                 :size => lambda {|obj, result| puts "after: #{obj.inspect}: result => #{result}"}
    #               }
    #
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
      method = symbol.to_s
      raise NoMethodError.new(method) unless @object.methods.member?(method)
                                       
      execute_call(@before_all, symbol)
      execute_call(@before, symbol)

      result = @object.send(method, *args)

      result_after = execute_call_with_result(@after, symbol, result)
      result_after_all = execute_call_with_result(@after_all, symbol, result)
         
      return result_after_all if result_after_all
      return result_after if result_after
      result
    end
    
    def proxied_class?; true end
    
    private               
    def execute_call container, method_symbol
      if block = get_block(container, method_symbol) and proc?(block)
        block.call(@object)
      end
    end
                      
    def execute_call_with_result container, method_symbol, result
      if block = get_block(container, method_symbol) and proc?(block)
        block.call(@object, result)
      end
    end
    
    def get_block container, method_symbol
      if container
        return container if container.class == Proc
        return container[method_symbol]
      end
    end
                
    def proc? block
      block and block.class == Proc
    end
    
  end
  
end


































