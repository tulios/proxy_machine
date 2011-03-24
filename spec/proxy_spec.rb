require 'spec_helper'

describe "proxy_machine" do
                             
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
        :reverse => lambda {|obj, args| obj << 50}
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [50, 3, 2, 1]
    end
  
    it 'should add a callafter' do
      array = [1, 2, 3]
      proxy = Proxy.new array, :after => {
        :reverse => lambda {|obj, result, args| result.collect {|e| e*4} }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == [12, 8, 4]
    end                                             
  
    it 'should add both, callbefore and callafter' do
      array = [1, 2, 3]
      proxy = Proxy.new array, 
      :before => {
        :reverse => lambda {|obj, args| obj.map! {|e| e*2} }
      },
      :after => {
        :reverse => lambda {|obj, result, args| result.collect {|e| e/2} }
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
  
  context 'for kernel method proxy_for' do
    
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
        :reverse => lambda {|obj, args| obj << 50 }
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
        :crazy_method => lambda {|obj, args| obj.value = "proxied value!" }
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
      proxy = proxy_for obj, :before_all => [
        [/^get_/, lambda {|obj, method, args| obj.value = 'gotcha!' }],
        [/method$/, lambda {|obj, method, args| obj.value = 'another gotcha!' }]
      ]
      
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
      proxy = proxy_for obj, :after_all => [
        [/^get_/, lambda {|obj, result, method, args| obj.value = 'gotcha!' }],
        [/method$/, lambda {|obj, result, method, args| obj.value = 'another gotcha!'}]
      ]
      
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
    
    it 'should ensure that the last value returned is the value of the last called method' do
      obj = MyRegexMethods.new
      proxy = proxy_for obj, :after_all => [
        [/get_/, lambda {|obj, result, method, args| 1}],
        [/value/, lambda {|obj, result, method, args| 2}]
      ]
      
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
      proxy = proxy_for obj, :before_all => [
        [/^get_/, Change1Performer],
        [/method$/, lambda {|obj, method, args| obj.value = 'another gotcha!' }]
      ]
      
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
      proxy = proxy_for obj, :before_all => [
        [/get_/, lambda {|obj, method, args| obj.value = "it_"}],
        [/value/, Change2Performer]
      ]
      
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

  context 'creating an execution stack' do
    class StackClass
      attr_accessor :name
      def do_logic var
        @name = "#{@name}_#{var}"
      end
    end

    it 'should execute the entire stack over a single proxied method' do
      obj = StackClass.new
      obj.name = "important name"
                   
      make_upper = lambda {|obj, args| obj.name = obj.name.upcase }
      make_without_space = lambda {|obj, args| obj.name = obj.name.gsub /\s+/, '-'}
      make_round_brackets = lambda {|obj, args| obj.name = "(#{obj.name})" }

      make_lower = lambda {|obj, args| args[0].downcase! }
      make_round_brackets2 = lambda {|obj, args| args[0] = "[#{args[0]}]" }
      
      proxy = proxy_for obj, :before => {
        :name => [make_upper, make_without_space, make_round_brackets],
        :do_logic => [make_lower, make_round_brackets2]
      }                    
                                                                     
      proxy.should_not be_nil
      proxy.name.should == "(IMPORTANT-NAME)"
      
      proxy.do_logic "MY NAME"
      proxy.original_object.name.should == "(IMPORTANT-NAME)_[my name]"
    end

  end
  
  context 'for kernel method auto_proxy' do
    class ProxiedConstructor
      attr_accessor :name, :count
      def initialize; @count = 0 end
    end
    
    context 'when generate a object already proxied' do
      
      it 'should work even if the class have a parametrized initialize' do
        class ProxiedConstructorWithArgs
          attr_accessor :var1, :var2
          def initialize(v1, v2); @var1 = v1; @var2 = v2; end
          auto_proxy { before :var1 => lambda {|obj, args| obj.var1 = 'proxied' if obj.var1 == 1} }
        end
        
        obj = ProxiedConstructorWithArgs.new(1,2)
        obj.proxied?.should be_true
        obj.send(:var1).should eql(1) # by passing proxy_machine
        obj.var1.should eql('proxied')
        obj.var2.should eql(2)
        
        obj = ProxiedConstructorWithArgs.new('a', 'b')
        obj.proxied?.should be_true
        obj.var1.should eql('a')
        obj.var2.should eql('b')
      end
      
      context 'for a certain method' do
        
        it 'should add a callbefore' do
          class ProxiedConstructor
            auto_proxy { before :name => lambda {|obj, args| obj.name = "#{obj.name}-2"} }
          end  
          
          obj = ProxiedConstructor.new
          obj.proxied?.should be_true
          obj.name.should eql("-2")
          obj.name = "house"
          obj.name.should eql("house-2")
        end
      
        it 'should add a callafter' do
          class ProxiedConstructor
            auto_proxy { after :name => lambda {|obj, result, args| result.chars.to_a.sort.to_s} }
          end
          
          obj = ProxiedConstructor.new
          obj.proxied?.should be_true
          obj.name = "tulio"
          obj.name.should eql("ilotu")
          obj.name = "proxy"
          obj.name.should eql("oprxy")
        end
        
      end
      
      context 'for all methods' do
        
        it 'should add a callbefore' do
          class ProxiedConstructor
            auto_proxy { before_all {|obj, method, args| obj.count+=1} }
          end
          
          obj = ProxiedConstructor.new
          obj.proxied?.should be_true
          obj.count.should eql(1)
          obj.to_s
          obj.count.should eql(3)
          obj.display
          obj.count.should eql(5)
        end
        
        it 'should add a callafter' do
          class ProxiedConstructor
            auto_proxy { after_all {|obj, method, args| obj.count-=1} }
          end
          
          obj = ProxiedConstructor.new
          obj.proxied?.should be_true
          obj.count.should eql(-1)
          obj.to_s
          obj.count.should eql(-3)
          obj.display
          obj.count.should eql(-5)
        end
        
      end
      
      context 'filtering methods by regex' do
        class MyRegexMethodsProxiedConstructor                    
          attr_accessor :value
          def get_value1; @value ? @value : 'get' end
          def get_value2; @value ? @value : 'get' end
          def another_method; @value ? @value : 'another' end
          def crazy_one; @value ? @value : 'crazy' end
        end
        
        it 'should affect just the matched methods on callbefore' do
          class MyRegexMethodsProxiedConstructor
            auto_proxy do
              before_all [
                [/^get_/, lambda {|obj, method, args| obj.value = 'gotcha!' }],
                [/method$/, lambda {|obj, method, args| obj.value = 'another gotcha!' }]
              ]
            end
          end
          
          obj = MyRegexMethodsProxiedConstructor.new
          obj.proxied?.should be_true

          obj.original_object.value = nil
          obj.get_value1.should == 'gotcha!'

          obj.original_object.value = nil
          obj.get_value2.should == 'gotcha!'

          obj.original_object.value = nil
          obj.another_method.should == 'another gotcha!'

          obj.original_object.value = nil
          obj.crazy_one.should == 'crazy'
        end
        
        it 'should affect just the matched methods on callafter' do
          class MyRegexMethodsProxiedConstructor
            auto_proxy do
              after_all [
                [/^get_/, lambda {|obj, result, method, args| obj.value = 'gotcha!' }],
                [/method$/, lambda {|obj, result, method, args| obj.value = 'another gotcha!'}]
              ]
            end
          end
            
          obj = MyRegexMethodsProxiedConstructor.new
          obj.proxied?.should be_true

          obj.original_object.value = nil
          obj.get_value1.should == 'gotcha!'

          obj.original_object.value = nil
          obj.get_value2.should == 'gotcha!'

          obj.original_object.value = nil
          obj.another_method.should == 'another gotcha!'

          obj.original_object.value = nil
          obj.crazy_one.should == 'crazy'
        end
        
      end
      
    end
    
    context 'with dinamic methods' do
      class MyClassProxiedConstructed
        attr_accessor :value
        auto_proxy do
          allow_dinamic true
          before :crazy_method => lambda {|obj, args| obj.value = "proxied value!" }
        end
        def method_missing(symbol, *args); @value; end
      end

      it 'should allow dinamic methods' do
        obj = MyClassProxiedConstructed.new
        obj.proxied?.should be_true
        
        obj.value = "Crazy Value"
        obj.value.should == "Crazy Value"
        obj.crazy_method.should == "proxied value!"
        obj.value.should == "proxied value!"
      end
    end
    
    context 'avoiding original execution' do
      class AvoidOriginalProxiedConstructed
        attr_accessor :value
        auto_proxy do
          avoid_original_execution true
          after_all {|obj, result, method, args| "avoided"}
        end
        def do_something; @value = "original" end
      end

      it 'should happen' do
        obj = AvoidOriginalProxiedConstructed.new
        obj.proxied?.should be_true
        
        obj.do_something.should == "avoided"
        obj.original_object.value.should be_nil
      end
    end
    
    context 'when registering a class' do
      class CounterPerformer
        def initialize object, result = nil, method = nil, args = nil
          @object = object; @result = result; @method = method, @args = args
        end
      
        def call; @object.count = @object.count ? @object.count+1 : 0 end
      end
      class RegisteredProxiedConstructed; attr_accessor :count; end
      
      it 'should use a instance of the registered class for a callbefore' do
        class RegisteredProxiedConstructed
          auto_proxy {before :to_s => CounterPerformer}
        end
        
        obj = RegisteredProxiedConstructed.new
        obj.proxied?.should be_true
        obj.count.should eql(nil)
        obj.to_s
        obj.count.should eql(0)
        obj.to_s
        obj.count.should eql(1)
      end
  
      it 'should use a instance of the registered class for a callafter' do
        class RegisteredProxiedConstructed
          auto_proxy {after :to_s => CounterPerformer}
        end
        
        obj = RegisteredProxiedConstructed.new
        obj.proxied?.should be_true
        obj.count.should eql(nil)
        obj.to_s
        obj.count.should eql(0)
        obj.to_s
        obj.count.should eql(1)
      end
  
      it 'should use a instance of the registered class for callbefore_all' do
        class RegisteredProxiedConstructed
          auto_proxy {before_all CounterPerformer}
        end
        
        obj = RegisteredProxiedConstructed.new
        obj.proxied?.should be_true
        obj.count.should eql(0)
        obj.to_s
        obj.count.should eql(2)
        obj.display
        obj.count.should eql(4)
      end
  
      it 'should use a instance of the registered class for callafter_all' do
        class RegisteredProxiedConstructed
          auto_proxy {after_all CounterPerformer}
        end
        
        obj = RegisteredProxiedConstructed.new
        obj.proxied?.should be_true
        obj.count.should eql(0)
        obj.to_s
        obj.count.should eql(2)
        obj.display
        obj.count.should eql(4)
      end
  
    end
  end

end



























