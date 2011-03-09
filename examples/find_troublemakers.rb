    require 'group_delegator'

    #Group Delegator proxying
    proxy_numbers = ["1", "2", "3", :a, "b", "cat"]
    proxy_all = SimpleGroupDelegator.new(proxy_numbers)
    proxy_integers = proxy_all.to_i
    
    #find trouble makers
    trouble_makers = proxy_numbers - proxy_integers.keys
    #=> [:a]

 
