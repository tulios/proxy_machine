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
  
end



























