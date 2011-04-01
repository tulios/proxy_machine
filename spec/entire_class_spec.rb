require 'spec_helper'

describe "proxy_machine proxing the entire class" do
  
  class ProxiedConstructor
    attr_accessor :name, :count
    def initialize; @count = 0 end
  end
  
    
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