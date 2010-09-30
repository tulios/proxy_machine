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
    def initialize object, callbacks = nil
      @object = object                    
      @before = callbacks[:before] if callbacks
      @after = callbacks[:after] if callbacks
    end
                            
    def method_missing(symbol, *args)                               
      method = symbol.to_s
      raise NoMethodError.new(method) unless @object.methods.member?(method)
                                
      execute_callback(@before, symbol, *args)
      result = @object.send(method, *args)
      execute_callback(@after, symbol, result)
      result
    end
    
    def proxied_class?; true end
    
    private
    def execute_callback callback_container, method_symbol, *args
      if callback_container
        callback = callback_container[method_symbol]
        callback.call(@object, *args) if callback and callback.class == Proc
      end
    end
    
  end
  
end


































