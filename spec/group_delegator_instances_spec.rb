require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'benchmark'

#classes for testing
class A
  def common_method
    :a
  end
  def some_method
    :aa
  end
  def a_method
    :aaa
  end
end

class B
  def common_method
    :b
  end
end

class C
  def common_method
    :c
  end
  def some_method
    :cc
  end
end

shared_examples_for "instance delegator - entire collection" do
  it "passes methods to the underlying instances of the group" do
    group_obj.common_method.should == {@a_obj => :a, @b_obj => :b, @c_obj => :c}
  end
end

shared_examples_for "instance delegator - first response" do
  it "passes methods to the first responing instance" do
        expected_result_set = {@a_obj=>:a, @b_obj=>:b, @c_obj=>:c}
        result = group_obj.common_method
        result_key = result.keys.first
        expected_result_set.keys.should include result_key
        result_value = result.values.first
        expected_result_set.values.should include result_value
  end
end

describe "delegating to a group of instance objects" do
  before(:each) do
    @a_obj = A.new; @b_obj = B.new; @c_obj = C.new
  end

  describe "default concurrency model (iterative)" do
    it_should_behave_like  "instance delegator - entire collection" do
      let(:group_obj) { GroupDelegatorInstances.new([@a_obj, @b_obj, @c_obj]) }
     end
  end

  describe "iterative concurrency model" do
    it_should_behave_like  "instance delegator - entire collection" do
      let(:group_obj) { GroupDelegatorInstances.new([@a_obj, @b_obj, @c_obj], :iterative) }
     end
  end

  describe "threaded concurrency model" do
    it_should_behave_like  "instance delegator - entire collection" do
      let(:group_obj) { GroupDelegatorInstances.new([@a_obj, @b_obj, @c_obj], :threaded) }
     end
  end

  describe "first response concurrency model" do
    it_should_behave_like "instance delegator - first response" do
      let(:group_obj) { GroupDelegatorInstances.new([@a_obj, @b_obj, @c_obj], :first_response) }
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
      @a_obj = BenchA.new; @b_obj = BenchB.new; @c_obj = BenchC.new
      @group_obj = GroupDelegatorInstances.new([@a_obj, @b_obj, @c_obj], :iterative)
    end

    it "executes" do
      @execution_times[:iterative] = Benchmark.realtime { @group_obj.common_method }
    end
  end

  describe "threaded" do
    before(:each) do
      @a_obj = BenchA.new; @b_obj = BenchB.new; @c_obj = BenchC.new
      @group_obj = GroupDelegatorInstances.new([@a_obj, @b_obj, @c_obj], :threaded)
    end

    it "executes" do
      @execution_times[:threaded] = Benchmark.realtime { @group_obj.common_method }
    end
  end

  describe "first response" do
    before(:each) do
      @a_obj = BenchA.new; @b_obj = BenchB.new; @c_obj = BenchC.new
      @group_obj = GroupDelegatorInstances.new([@a_obj, @b_obj, @c_obj], :first_response)
    end

    it "executes" do
      @execution_times[:first_response] = Benchmark.realtime { @group_obj.common_method }
    end
  end

  describe "results" do
    it "checks the order of results" do
      @execution_times[:first_response].should < @execution_times[:threaded]
      @execution_times[:threaded].should < @execution_times[:iterative]
    end
  end
end
