#container for the proxied objects
require 'group_delegator/source_group'

#retrieves the method data from the source group
require 'group_delegator/source_helper'

#class to use if one is only interested in instance methods
require 'group_delegator/group_delegator_instances'

#class to use if one is interested in proxy a complete class
#- including class methods and instantiation
require 'group_delegator/group_delegator_klasses'

#for the lazy (like me) set a group delegator class to a default
#so people don't have to read docs
class GroupDelegator < GroupDelegatorKlasses
end

#Also, here's the basic version with a simple name
#This one only deals with instantiated objects (so
#no class variables)
class SimpleGroupDelegator < GroupDelegatorInstances
end
