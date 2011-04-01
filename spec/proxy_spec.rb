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
  
  it 'should detect proxied objects' do
    array1 = [1, 2, 3]
    array1.proxied?.should be_false
    array2 = proxy_for [1, 2, 3]
    array2.proxied?.should be_true
  end
    
end



























