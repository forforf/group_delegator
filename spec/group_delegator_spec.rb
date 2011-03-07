require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GroupDelegator Set Up" do
  it "loads all requires" do
    expect { SourceGroup }.to_not raise_error
    expect { SourceHelper }.to_not raise_error
    expect { GroupDelegatorInstances }.to_not raise_error
    expect { GroupDelegatorKlasses }.to_not raise_error
    expect { GroupDelegator }.to_not raise_error
  end
end

#Source Classes for Testing
class Base
  class<<self; attr_accessor :my_class_instance_var; end
  @@my_val = nil

  def self.set_class_method(set_val)
    @@my_val = set_val
  end

  def self.get_class_method
    @@my_val
  end

  attr_accessor :my_instance_var, :params, :my_val

  def initialize(params)
    @params = params
  end

  def set_instance_method(set_val)
    @my_val = set_val
  end

  def get_instance_method
    @my_val
  end
end

class A < Base
  def A.unique_result
    :A
  end

  def a_method_only
    :a
  end
end

class B < Base
  def B.unique_result
    :B
  end

  def b_method_only
    :b
  end
end

class C < Base
  def C.unique_result
    :C
  end

  def c_method_only
    :c
  end
end

#Testing SourceGroup
shared_examples_for "a source group of class level objects" do
  describe "forwarding to source class level objects" do
      it "can set and retrieve class instance variables using forward" do
        expected_result = {A=>:class_iv_var, B=>:class_iv_var, C=>:class_iv_var}
        source_class_group.forward(:my_class_instance_var=, :class_iv_var).should == expected_result
        source_class_group.forward(:my_class_instance_var).should == expected_result
      end

      it "can send parameters to class methods" do
        expected_result = {A=>"some val", B=>"some val", C=>"some val"}
        source_class_group.forward(:set_class_method, "some val").should == expected_result
        source_class_group.forward(:get_class_method).should == expected_result
      end

      it "handles different return values " do
        expected_result = {A=>:A, B=>:B, C=>:C}
        source_class_group.forward(:unique_result).should == expected_result
      end

      it "returns error if no sources have that method" do
        case source_class_group.concurrency_model
          when :iterative
            source_class_group.forward(:foo).should == {}
          when :threaded
            source_class_group.forward(:foo).should == nil
        end
        #expect { source_class_group.forward(:foo) }.to raise_error
      end
  end
end

shared_examples_for "a source group of instance objects" do
  describe "forwarding to source instance objects" do
      it "can set and retrieve instance variables using forward" do
        expected_result = {@a=>:iv_val, @b=>:iv_val, @c=>:iv_val}
        source_class_group.forward(:my_instance_var=, :iv_val).should == expected_result
        source_class_group.forward(:my_instance_var).should == expected_result
      end

      it "can send parameters to instance methods" do
        expected_result = {@a=>"some inst val", @b=>"some inst val", @c=>"some inst val"}
        source_class_group.forward(:set_instance_method, "some inst val").should == expected_result
        source_class_group.forward(:get_instance_method).should == expected_result
      end

      it "will return result as long as at least one object has that method" do
        source_class_group.forward(:a_method_only).should == {@a=>:a}
        source_class_group.forward(:c_method_only).should == {@c=>:c}
      end

  end
end

shared_examples_for "a source group of class level objects; first_response concurrency model" do
  describe "forwarding to source class level objects" do
      it "can set and retrieve class instance variables using forward" do
        expected_result_set = {A=>:class_iv_var, B=>:class_iv_var, C=>:class_iv_var}
        result = source_class_group.forward(:my_class_instance_var=, :class_iv_var)
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result.should == {result_key => :class_iv_var}
      end

      it "can send parameters to class methods" do
        expected_result_set = {A=>"some val", B=>"some val", C=>"some val"}
        result = source_class_group.forward(:set_class_method, "some val")
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result.should == {result_key => "some val"}
      end

      it "can get parameters from class methods" do
        expected_result_set = {A=>"some val", B=>"some val", C=>"some val"}
        result = source_class_group.forward(:get_class_method)
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result.should == {result_key => "some val"}
      end
  end
end

shared_examples_for "a source group of instance objects; first_response concurrency model" do
  describe "forwarding to source instance objects" do
      it "can set and retrieve instance variables using forward" do
        expected_result_set = {@a=>:iv_val, @b=>:iv_val, @c=>:iv_val}
        result = source_class_group.forward(:my_instance_var=, :iv_val)
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result.should == {result_key => :iv_val}
      end

      it "can send parameters to instance methods" do
        expected_result_set = {@a=>"some inst val", @b=>"some inst val", @c=>"some inst val"}
        result = source_class_group.forward(:set_instance_method, "some inst val")
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result.should == {result_key => "some inst val"}

      end

      it "can get parameters to instance methods" do
        expected_result_set = {@a=>"some inst val", @b=>"some inst val", @c=>"some inst val"}
        source_class_group.forward(:set_instance_method, "some inst val")
        result = source_class_group.forward(:get_instance_method)
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result.should == {result_key => "some inst val"}
      end

      it "will return result as long as at least one object has that method" do
        source_class_group.forward(:a_method_only).should == {@a=>:a}
        source_class_group.forward(:c_method_only).should == {@c=>:c}
      end

  end
end



describe "SourceGroup" do

  describe "initializing class objects as targets" do
    before(:each) do
      @source_class_group = SourceGroup.new([A,B,C])
    end

    it "should exist" do
      @source_class_group.class.should == SourceGroup
    end
  end

  describe "source group default concurrency" do

    before(:each) do
      @a = A.new(:a_param); @b = B.new(:b_param); @c = C.new(:c_param)
    end


    it_should_behave_like "a source group of class level objects" do
      let(:source_class_group) { SourceGroup.new([A,B,C]) }
    end
    
    it_should_behave_like "a source group of instance objects" do
      let(:source_class_group) { SourceGroup.new([@a,@b,@c]) }
    end
  end

  describe "source group iterative concurrency" do

    before(:each) do
      @a = A.new(:a_param); @b = B.new(:b_param); @c = C.new(:c_param)
    end

    it_should_behave_like "a source group of class level objects" do
      let(:source_class_group) { SourceGroup.new([A,B,C], :iterative) }
    end

    it_should_behave_like "a source group of instance objects" do
      let(:source_class_group) { SourceGroup.new([@a,@b,@c], :iterative) }
    end
  end

  describe "source group threaded concurrency" do

    before(:each) do
      @a = A.new(:a_param); @b = B.new(:b_param); @c = C.new(:c_param)
    end

    it_should_behave_like "a source group of class level objects" do
      let(:source_class_group) { SourceGroup.new([A,B,C], :threaded) }
    end

    it_should_behave_like "a source group of instance objects" do
      let(:source_class_group) { SourceGroup.new([@a,@b,@c], :threaded) }
    end
  end

  describe "source group first response concurrency" do

    before(:each) do
      @a = A.new(:a_param); @b = B.new(:b_param); @c = C.new(:c_param)
    end

    it_should_behave_like "a source group of class level objects; first_response concurrency model" do
      let(:source_class_group) { SourceGroup.new([A,B,C], :first_response) }
    end

    it_should_behave_like "a source group of instance objects; first_response concurrency model" do
      let(:source_class_group) { SourceGroup.new([@a,@b,@c], :first_response) }
    end
  end

  #TODO Build some timing tests to show benefits of threaded and first response models
end


#TODO Build Test Classes for the Delegator wrappers

