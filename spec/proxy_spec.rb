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
    
    it 'should add a callbefore' do
      array = [3, 2, 1]
      proxy = Proxy.new array, :before_all => lambda {|obj| obj.sort!}
      proxy.should_not be_nil
      proxy.reverse.should == [3, 2, 1]
      proxy.max.should == 3
      proxy.first.should == 1
      proxy.to_s.should == "123"
    end

    it 'should add a callafter' do
      array = [1, 2, 3]
      
      proxy = Proxy.new array, :after_all => lambda {|obj, result|
        return result * 10 if result.class == Fixnum
        result
      }
      
      proxy.should_not be_nil
      proxy.reverse.should == [3, 2, 1]
      proxy.max.should == 30 # 3 * 10
      proxy.first.should == 10 # 1 * 10
      proxy.to_s.should == "123"
    end
    
    it 'should add both, callbefore and callafter' do
      array = [3, 2, 1]
      proxy = Proxy.new array, 
      :before_all => lambda {|obj| obj.sort!},
      :after_all => lambda {|obj, result|
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
      def initialize object, result = nil
        @object = object; @result = result
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
    
  end
  
end



























