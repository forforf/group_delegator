require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'benchmark'

#classes for testing
class A
  attr_accessor :iv
  def self.klass_method
    :A
  end
  def self.a_klass_method
    :AAA
  end
  def initialize(params)
    @iv = params
  end
  def common_method
    :a
  end
  def a_method
    :aaa
  end
end

class B
  attr_accessor :iv
  def self.klass_method
    :B
  end
  def initialize(params)
    @iv = params
  end
  def common_method
    :b
  end
end

class C
  attr_accessor :iv
  def self.klass_method
    :C
  end
  def initialize(params)
    @iv = params
  end
  def common_method
    :c
  end
end


shared_examples_for "class delegator - entire collection" do
  it "passes methods to the source classes in the group" do
    group_klass.klass_method.should == {A=>:A, B=>:B, C=>:C}
  end
end

shared_examples_for "class delegator - first response" do
  it "passes methods to the source classes in the group" do
        expected_result_set = {A=>:A, B=>:B, C=>:C} 
        result = group_klass.klass_method
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result_value = result.values.first
        expected_result_set.values.should include result_value
  end
end

shared_examples_for "class delegator - initializing objects" do
  it "should initialize a group of objects based on the group of classes" do
    source_classes = [ A, B, C ]
    objs_iv = group_obj.iv
    objs_iv.each_with_index do |obj_inst_var, i|
      obj = obj_inst_var[0]
      inst_var = obj_inst_var[1]
      obj.class.should == source_classes[i]
      inst_var.should == :some_init_params
    end
  end
end

shared_examples_for "instance delegator - entire collection" do
  it "passes methods to the underlying instances of the group" do
    group_obj.common_method.values == [:a, :b, :c]
  end
end

shared_examples_for "instance delegator - first response" do
  it "passes methods to the first responing instance" do
        expected_result_set = [:a, :b, :c]
        result = group_obj.common_method
        result_value = result.values.first
        expected_result_set.should include result_value
  end
end

describe "delegating to a group of classes" do
  before(:each) do
    
  end

  describe "default concurrency model (iterative)" do
    it_should_behave_like "class delegator - entire collection" do
      #One line inheritance to prevent clobbering GroupDelegatorKlasses class inst var
      DefaultGDK = Class.new(GroupDelegatorKlasses)
      DefaultGDK.__set_source_classes( [A, B, C] )
      let(:group_klass) { DefaultGDK }
    end
  end

  describe "iterative concurrency model" do
    it_should_behave_like "class delegator - entire collection" do
      IterGDK = Class.new(GroupDelegatorKlasses)
      IterGDK.__set_source_classes( [A, B, C], :iterative )
      let(:group_klass) { IterGDK }
    end
  end

  describe "threaded concurrency model" do
    it_should_behave_like "class delegator - entire collection" do
      ThreadGDK = Class.new(GroupDelegatorKlasses)
      ThreadGDK.__set_source_classes( [A, B, C], :threaded )
      let(:group_klass) { ThreadGDK }
    end
  end

  describe "first response concurrency model" do
    it_should_behave_like "class delegator - first response" do
      FirstRespGDK = Class.new(GroupDelegatorKlasses)
      FirstRespGDK.__set_source_classes( [A, B, C], :first_response )
      let(:group_klass) { FirstRespGDK }
    end
  end

  describe "default group initialization" do
    it_should_behave_like "class delegator - initializing objects" do
      DefObjGDK = Class.new(GroupDelegatorKlasses)
      DefObjGDK.__set_source_classes( [A, B, C] )
      let(:group_obj) { DefObjGDK.new(:some_init_params) }
    end
  end

  describe "group initialization, iterative" do
    it_should_behave_like "class delegator - initializing objects" do
      IterObjGDK = Class.new(GroupDelegatorKlasses)
      IterObjGDK.__set_source_classes( [A, B, C], :iterative )
      let(:group_obj) { IterObjGDK.new(:some_init_params) }
    end
  end

  describe "group initialization, threaded" do
    it_should_behave_like "class delegator - initializing objects" do
      ThreadObjGDK = Class.new(GroupDelegatorKlasses)
      ThreadObjGDK.__set_source_classes( [A, B, C], :iterative )
      let(:group_obj) { ThreadObjGDK.new(:some_init_params) }
    end
  end

  describe "group initialization, first response" do
    it_should_behave_like "instance delegator - first response" do
      FirstRespObjGDK = Class.new(GroupDelegatorKlasses)
      FirstRespObjGDK.__set_source_classes( [A, B, C], :first_response )
      let(:group_obj) { FirstRespObjGDK.new(:some_init_params) }
    end
  end
end

describe "newly created instances should behave as grouped delegates" do
  describe "default concurrency model (iterative)" do
    it_should_behave_like  "instance delegator - entire collection" do
      let(:group_obj) { DefObjGDK.new(:some_other_params) }
     end
  end

  describe "iterative concurrency model" do
    it_should_behave_like  "instance delegator - entire collection" do
      let(:group_obj) { IterObjGDK.new(:some_other_params) }
     end
  end

  describe "threaded concurrency model" do
    it_should_behave_like  "instance delegator - entire collection" do
      let(:group_obj) { ThreadObjGDK.new(:some_other_params) }
     end
  end

  describe "first response concurrency model" do
    it_should_behave_like  "instance delegator - first response" do
      let(:group_obj) { FirstRespObjGDK.new(:some_other_params) }
     end
  end

end

class BenchA
  def common_method
    sleep 0.3
    :a
  end
end

class BenchB
  def common_method
    sleep 0.2
    :b
  end
end

class BenchC
  def common_method
    sleep 0.1
    :c
  end
end

describe "benchmarks" do
  before(:all) do
    @execution_times = {}
  end

  after(:all) do
    p @execution_times
  end

  describe "iterative" do
    before(:each) do
      #@a_obj = BenchA.new; @b_obj = BenchB.new; @c_obj = BenchC.new
      BenchObjGDK = Class.new(GroupDelegatorKlasses)
      BenchObjGDK.__set_source_classes( [BenchA, BenchB, BenchC], :iterative )
      @bench_obj = BenchObjGDK.new
    end

    it "executes" do
      @execution_times[:iterative] = Benchmark.realtime { @bench_obj.common_method }
    end
  end

  describe "threaded" do
    before(:each) do
      #@a_obj = BenchA.new; @b_obj = BenchB.new; @c_obj = BenchC.new
      BenchObjGDK = Class.new(GroupDelegatorKlasses)
      BenchObjGDK.__set_source_classes( [BenchA, BenchB, BenchC], :threaded )
      @bench_obj = BenchObjGDK.new
    end

    it "executes" do
      @execution_times[:threaded] = Benchmark.realtime { @bench_obj.common_method }
    end
  end

  describe "first response" do
    before(:each) do
      #@a_obj = BenchA.new; @b_obj = BenchB.new; @c_obj = BenchC.new
      BenchObjGDK = Class.new(GroupDelegatorKlasses)
      BenchObjGDK.__set_source_classes( [BenchA, BenchB, BenchC], :first_response )
      @bench_obj = BenchObjGDK.new
    end

    it "executes" do
      @execution_times[:first_response] = Benchmark.realtime { @bench_obj.common_method }
    end
  end


  describe "results" do
    it "checks the order of results" do
      @execution_times[:first_response].should < @execution_times[:threaded]
      @execution_times[:threaded].should < @execution_times[:iterative]
    end
  end
end
