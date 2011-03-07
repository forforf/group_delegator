#Takes a set of instantiated objects as arguments and will concurently delegate
#method calls to each instance in the set. Built in concurrency models include:
# - iterative (iterates the method calls on each object in the set)
# - threaded (all method calls are done in parallel until all conclude
# - first response (continues once any in the set complete the method)
class GroupDelegatorInstances
  include SourceHelper
  #unload these methods so the proxy object will handle them
  [:to_s,:inspect,:=~,:!~,:===].each do |m|
    undef_method m
  end
  
    #object methods, only
  def initialize(proxied_objs, concurrency_model = :iterative)
    @source_objects = [] #contains the delegated objects
    @source_obj_methods = {} #map of all methods to the objects that use them
    raise "No source instances set" unless proxied_objs.size > 0
    sources_data = __set_sources_data(proxied_objs)
    @source_obj_methods = sources_data[:source_methods]
    @source_objects = sources_data[:source_objs]
    @instance_source_group = SourceGroup.new(@source_objects, concurrency_model)
    self
  end
  
  def method_missing(m, *args, &block)
    if @source_obj_methods.include? m
      resp = @instance_source_group.forward(m, *args, &block)
    else
      raise NoMethodError, "GroupDelegatorKlasses object can't find the method #{m} in any of its sources"
    end
  end
end
