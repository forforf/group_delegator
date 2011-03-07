class GroupDelegatorKlasses
  include SourceHelper
  #unload these methods so the proxy object will handle them
  [:to_s,:inspect,:=~,:!~,:===].each do |m|
    undef_method m
  end
  
  #source_classes is the container the holds the classes that will be proxied
  class << self
    #unload these methods so the proxy class will handle them
    [:to_s,:inspect,:=~,:!~,:===].each do |m|
      undef_method m
    end
    
    attr_accessor :__class_source_group , :__all_class_methods, :__concurrency_model
    
    #sets the classes that will be proxied
    def __set_source_classes(classes_to_proxy, concurrency_model = :iterative)
      @__concurrency_model = concurrency_model
      sources_data = SourceHelper.set_sources_data(classes_to_proxy)
      @source_obj_methods = sources_data[:source_methods]
      @sources = sources_data[:source_objs]
      @__all_class_methods = @source_obj_methods.keys
      @__class_source_group = SourceGroup.new(@sources, concurrency_model) if @sources.size > 0
    end
    
    def __source_classes
      @sources
    end
    
  end #class<<self
  
  #initializing class instance variables
  self.__set_source_classes([])
  
  def self.method_missing(m, *args, &block)
    if self.__all_class_methods.include? m
      resp = self.__class_source_group.forward(m, *args, &block)
      else
      raise NoMethodError, "#{self.class} can't find the class method #{m} in any of its sources"
    end
  end
  
  def initialize(*args)
    concurrency_model = self.__concurrency_model
    raise "No Source Classes set" unless self.__source_classes.size > 0
    proxied_objs = self.__source_classes.map {|klass| klass.new(*args) }
    sources_data = SourceHelper.set_sources_data(proxied_objs)
    @source_obj_methods = sources_data[:source_methods]
    @source_objects = sources_data[:source_objs]
    @instance_source_group = SourceGroup.new(@source_objects, concurrency_model)
  end

  def method_missing(m, *args, &block)
    if @source_obj_methods.include? m
      resp = @instance_source_group.forward(m, *args, &block)
    else
      raise NoMethodError, "#{self.class} object can't find the method #{m} in any of its sources"
    end
  end
end 
