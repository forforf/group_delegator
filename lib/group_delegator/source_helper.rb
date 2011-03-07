module SourceHelper
  def self.set_sources_data(proxied_objs)
    source_obj_methods = {} #map of all methods to the objects that use them
    proxied_objs.each do |proxied_obj|
      proxied_obj.methods.each do |proxy_method|
        source_obj_methods[proxy_method] ||= [proxied_obj]
        source_obj_methods[proxy_method] << proxied_obj
      end
    end
    {:source_methods => source_obj_methods, :source_objs => proxied_objs}
  end
  
  def __set_sources_data(proxied_objs)
    raise "No source instances set" unless proxied_objs.size > 0
    SourceHelper.set_sources_data(proxied_objs)
  end
end
