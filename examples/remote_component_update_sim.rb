require 'group_delegator'


#Imagine we have many objects
class MyRemoteComponent
  attr_accessor :status, :version

  def remote_update(version)
    sleep 0.1  #they're slow to update
    @version = version
  end

  def 
end

components = []
100.times do
  stat = [:ok, :minor, :major, :fail][rand(4)]
  mycomp = MyRemoteComponent.new
  mycomp.status = [:ok, :minor, :major, :fail][rand(4)]
  components << mycomp
end

#let's get the status from each component

#this proxyies all components' methods into a single wrapper
all_as_one = SimpleGroupDelegator.new(components)

#so we can check the status of all of them in a single line
all_status = all_as_one.status

#the return result is a hash of the {obj1 => result1, obj2 => result2, etc}
#if we don't care about the obj we can just grab the values
p all_status.values

all_as_one.remote_update("v1.0.0")

p all_as_one.version.values.uniq
#=> ["v1.0.0"]   but that was kinda slow

#lets do them all in parallel then
all_as_one_v2 = SimpleGroupDelegator.new(components, :threaded)

all_as_one_v2.remote_update("v2.0.0")

p all_as_one_v2.version.values.uniq

