require 'proxy_machine'

describe Proxy do
                             
  it 'should create a proxy object from the given one' do
    array = [1, 2, 3]
    proxy = Proxy.new array
    proxy.should_not be_nil
    proxy.class.should == array.class
    
    proxy.reverse.should == array.reverse
    proxy.proxied_class?.should be_true
  end
  
  it 'should detect a proxy object with proxied_class? method' do
    array = [1, 2, 3]
    proxy = Proxy.new array
    (defined? proxy.proxied_class?).should_not be_nil
  end
  
  context 'for a certain method' do
  
    it 'should add a callbefore' do
      array = [1, 2, 3]
      proxy = Proxy.new array, :before => {
        :reverse => lambda {|obj| obj << 50 }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [50, 3, 2, 1]
    end
  
    it 'should add a callafter' do
      array = [1, 2, 3]
      proxy = Proxy.new array, :after => {
        :reverse => lambda {|obj, result| result.collect {|e| e*4} }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [12, 8, 4]
    end                                             
  
    it 'should add both, callbefore and callafter' do
      array = [1, 2, 3]
      proxy = Proxy.new array, 
      :before => {
        :reverse => lambda {|obj| obj.map! {|e| e*2} }
      },
      :after => {
        :reverse => lambda {|obj, result| result.collect {|e| e/2} }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [3, 2, 1]
    end
    
  end
  
  context 'for all methods' do
    class AllMethodsClass
      attr_accessor :method, :args
      def do_something; 50 end
    end             
    
    it 'should add a callbefore' do
      array = [3, 2, 1]
      proxy = Proxy.new array, :before_all => lambda {|obj, method, args| obj.sort!}
      proxy.should_not be_nil
      proxy.reverse.should == [3, 2, 1]
      proxy.max.should == 3
      proxy.first.should == 1
      proxy.to_s.should == "123"
    end
    
    it 'should provide method name and arguments for the block in callbefore' do
      obj = AllMethodsClass.new
      proxy = proxy_for obj, :before_all => lambda {|obj, method, args|
        obj.method = method
        obj.args = args
      }
      
      proxy.should_not be_nil
      proxy.do_something.should == 50
      proxy.original_object.method.should == :do_something
      proxy.original_object.args.should be_empty
    end

    it 'should add a callafter' do
      array = [1, 2, 3]
      
      proxy = Proxy.new array, :after_all => lambda {|obj, result, method, args|
        return result * 10 if result.class == Fixnum
        result
      }
      
      proxy.should_not be_nil
      proxy.reverse.should == [3, 2, 1]
      proxy.max.should == 30 # 3 * 10
      proxy.first.should == 10 # 1 * 10
      proxy.to_s.should == "123"
    end
    
    it 'should provide method name and arguments for the block in callafter' do
      obj = AllMethodsClass.new
      proxy = proxy_for obj, :after_all => lambda {|obj, result, method, args|
        obj.method = method
        obj.args = args
        nil
      }
      
      proxy.should_not be_nil
      proxy.do_something.should == 50
      proxy.original_object.method.should == :do_something
      proxy.original_object.args.should be_empty
    end
    
    it 'should add both, callbefore and callafter' do
      array = [3, 2, 1]
      proxy = Proxy.new array, 
      :before_all => lambda {|obj, method, args| obj.sort!},
      :after_all => lambda {|obj, result, method, args|
        return result * 10 if result.class == Fixnum
        result
      }
      proxy.should_not be_nil
      proxy.reverse.should == [3, 2, 1]
      proxy.max.should == 30 # 3 * 10
      proxy.first.should == 10 # 1 * 10
      proxy.to_s.should == "123"
    end
    
  end
  
  context 'for kernel method' do
    
    it 'should call proxy' do
      array = [1, 2, 3]
      proxy = proxy_for array
      proxy.should_not be_nil
      proxy.class.should == array.class

      proxy.reverse.should == array.reverse
      proxy.proxied_class?.should be_true
    end
    
    it 'should call proxy passing arguments' do
      array = [1, 2, 3]
      proxy = proxy_for array, :before => {
        :reverse => lambda {|obj| obj << 50 }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [50, 3, 2, 1]
    end
    
  end
   
  context 'for object method' do
    
    it 'should detect proxied objects' do
      array1 = [1, 2, 3]
      array1.proxied?.should be_false
      array2 = proxy_for [1, 2, 3]
      array2.proxied?.should be_true
    end
    
  end
  
  context 'when registering a class' do
    # Example of class
    class SortPerformer
      def initialize object, result = nil, method = nil, args = nil
        @object = object; @result = result; @method = method, @args = args
      end
      
      def call; @object.sort! end
    end
    
    it 'should use a instance of the registered class for a callafter' do
      array = [1, 2, 3]
      proxy = proxy_for array, :after => {
        :reverse => SortPerformer
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [1, 2, 3]
    end
    
    it 'should use a instance of the registered class for a callbefore' do
      array = [3, 2, 1]
      proxy = proxy_for array, :before => {
        :reverse => SortPerformer
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [3, 2, 1]
    end
    
    it 'should use a instance of the registered class for callbefore_all' do
      array = [3, 2, 1]
      proxy = proxy_for array, :before_all => SortPerformer

      proxy.should_not be_nil                  
      proxy.reverse.should == [3, 2, 1]
    end
    
    it 'should use a instance of the registered class for callafter_all' do
      array = [1, 2, 3]
      proxy = proxy_for array, :after_all => SortPerformer

      proxy.should_not be_nil                  
      proxy.reverse.should == [1, 2, 3]
    end
    
  end
  
  context 'with dinamic methods' do
    class MyClass
      attr_accessor :value
      def method_missing(symbol, *args); @value; end
    end
    
    it 'should allow dinamic methods' do
      obj = MyClass.new
      obj.value = "Crazy Value"
      
      proxy = proxy_for obj, :allow_dinamic => true, :before => {
        :crazy_method => lambda {|obj| obj.value = "proxied value!" }
      }
                    
      proxy.should_not be_nil                  
      proxy.crazy_method.should == "proxied value!"
    end
    
  end
  
  context 'avoiding original execution' do
    class AvoidOriginal
      attr_accessor :value
      def do_something; @value = "original" end
    end
    
    it 'should happen' do
      obj = AvoidOriginal.new
      proxy = proxy_for obj, :avoid_original_execution => true, :after_all => lambda {|obj, result, method, args|
        "avoided"
      }
      
      proxy.should_not be_nil
      proxy.do_something.should == "avoided"
      proxy.original_object.value.should be_nil
    end
  end
    
  context 'filtering methods by regex' do
    class MyRegexMethods                    
      attr_accessor :value
      def get_value1; @value ? @value : 'get' end
      def get_value2; @value ? @value : 'get' end
      def another_method; @value ? @value : 'another' end
      def crazy_one; @value ? @value : 'crazy' end
    end
    
    class Change1Performer
      def initialize object, result = nil, method = nil, args = nil
        @object = object; @result = result; @method = method, @args = args
      end
      
      def call; @object.value = 'gotcha!' end
    end
    
    class Change2Performer
      def initialize object, result = nil, method = nil, args = nil
        @object = object; @result = result; @method = method, @args = args
      end
      
      def call; @object.value = "#{@object.value}works" end
    end
    
    it 'should affect just the matched methods on callbefore' do
      obj = MyRegexMethods.new
      proxy = proxy_for obj, :before_all => {
        :call1 => [/^get_/, lambda {|obj, method, args| obj.value = 'gotcha!' }],
        :call2 => [/method$/, lambda {|obj, method, args| obj.value = 'another gotcha!' }]
      }
      
      proxy.should_not be_nil
      
      proxy.original_object.value = nil
      proxy.get_value1.should == 'gotcha!'
      
      proxy.original_object.value = nil
      proxy.get_value2.should == 'gotcha!'
      
      proxy.original_object.value = nil
      proxy.another_method.should == 'another gotcha!'
      
      proxy.original_object.value = nil
      proxy.crazy_one.should == 'crazy'
    end
    
    it 'should affect just the matched methods on callafter' do
      obj = MyRegexMethods.new
      proxy = proxy_for obj, :after_all => {
        :call1 => [/^get_/, lambda {|obj, result, method, args| obj.value = 'gotcha!' }],
        :call2 => [/method$/, lambda {|obj, result, method, args| obj.value = 'another gotcha!'}]
      }
      
      proxy.should_not be_nil
      
      proxy.original_object.value = nil
      proxy.get_value1.should == 'gotcha!'
      
      proxy.original_object.value = nil
      proxy.get_value2.should == 'gotcha!'
      
      proxy.original_object.value = nil
      proxy.another_method.should == 'another gotcha!'
      
      proxy.original_object.value = nil
      proxy.crazy_one.should == 'crazy'
    end
    
    it 'should execute the entire matched stack on callbefore sorted by the key name' do
      obj = MyRegexMethods.new
      proxy = proxy_for obj, :before_all => {
        :call2 => [/value/, lambda {|obj, method, args| obj.value = "#{obj.value}works"}],
        :call1 => [/get_/, lambda {|obj, method, args| obj.value = "it_"}]
      }
      
      proxy.should_not be_nil
      
      proxy.original_object.value = nil
      proxy.get_value1.should == 'it_works'
      
      proxy.original_object.value = nil
      proxy.get_value2.should == 'it_works'
      
      proxy.original_object.value = nil
      proxy.another_method.should == 'another'
      
      proxy.original_object.value = nil
      proxy.crazy_one.should == 'crazy'
    end
    
    it 'should ensure that the last value returned is the value of the last called method' do
      obj = MyRegexMethods.new
      proxy = proxy_for obj, :after_all => {
        :call2 => [/value/, lambda {|obj, result, method, args| 2}],
        :call1 => [/get_/, lambda {|obj, result, method, args| 1}]
      }
      
      proxy.should_not be_nil
      
      proxy.original_object.value = nil
      proxy.get_value1.should == 2
      
      proxy.original_object.value = nil
      proxy.get_value2.should == 2
      
      proxy.original_object.value = nil
      proxy.another_method.should == 'another'
      
      proxy.original_object.value = nil
      proxy.crazy_one.should == 'crazy'
    end
    
    it 'should affect just the matched methods using a registered class' do
      obj = MyRegexMethods.new
      proxy = proxy_for obj, :before_all => {
        :call1 => [/^get_/, Change1Performer],
        :call2 => [/method$/, lambda {|obj, method, args| obj.value = 'another gotcha!' }]
      }
      
      proxy.should_not be_nil
      
      proxy.original_object.value = nil
      proxy.get_value1.should == 'gotcha!'
      
      proxy.original_object.value = nil
      proxy.get_value2.should == 'gotcha!'
      
      proxy.original_object.value = nil
      proxy.another_method.should == 'another gotcha!'
      
      proxy.original_object.value = nil
      proxy.crazy_one.should == 'crazy'
    end
    
    it 'should execute the entire matched stack sorted by the key name using a registered class' do
      obj = MyRegexMethods.new
      proxy = proxy_for obj, :before_all => {
        :call2 => [/value/, Change2Performer],
        :call1 => [/get_/, lambda {|obj, method, args| obj.value = "it_"}]
      }
      
      proxy.should_not be_nil
      
      proxy.original_object.value = nil
      proxy.get_value1.should == 'it_works'
      
      proxy.original_object.value = nil
      proxy.get_value2.should == 'it_works'
      
      proxy.original_object.value = nil
      proxy.another_method.should == 'another'
      
      proxy.original_object.value = nil
      proxy.crazy_one.should == 'crazy'
    end
    
  end
  
end



























