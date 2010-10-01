require 'proxy_machine'

describe Proxy do
                             
  it 'should create a proxy object from the given one' do
    string = "My string"
    proxy = Proxy.new string
    proxy.should_not be_nil
    proxy.class.should == string.class
    
    proxy.reverse.should == string.reverse
    proxy.proxied_class?.should be_true
  end
  
  context 'for a certain method' do
  
    it 'should add a callbefore' do
      string = "My string"
      proxy = Proxy.new string, :before => {
        :reverse => lambda {|obj| ")#{obj}(" }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == "(#{string.reverse})"
    end
  
    it 'should add a callafter' do
      string = "My string"
      proxy = Proxy.new string, :after => {
        :reverse => lambda {|obj, result| "(#{result})" }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == "(#{string.reverse})"
    end                                             
  
    it 'should add both, callbefore and callafter' do
      string = "My string"
      proxy = Proxy.new string, 
      :before => {
        :reverse => lambda {|obj| obj.upcase }
      },
      :after => {
        :reverse => lambda {|obj, result| "(#{result})" }
      }
      proxy.should_not be_nil                  
      proxy.reverse.should == "(#{string.upcase.reverse})"
    end
    
  end
  
  context 'for all methods' do
    
    it 'should add a callbefore' do
      string = "My string"
      proxy = Proxy.new string, :before_all => lambda {|obj| obj.upcase}
      proxy.should_not be_nil
      proxy.reverse.should == string.upcase.reverse
      proxy.size.should == string.size              
      proxy.downcase.should == string.downcase
      proxy.to_s.should == string.upcase
    end

    it 'should add a callafter' do
      string = "My string"
      
      proxy = Proxy.new string, :after_all => lambda {|obj, result|
        return result if result.class == Fixnum
        return obj = result.upcase if result.class == String
        obj   
      }
      
      proxy.should_not be_nil
      proxy.reverse.should == string.upcase.reverse
      proxy.size.should == string.size              
      proxy.downcase.should == string.upcase
      proxy.to_s.should == string.upcase
    end
    
  end
  
end



























