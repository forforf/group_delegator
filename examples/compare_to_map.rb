    require 'group_delegator'
    proxy_numbers = ["1", "2", "3"]
    proxy_all = SimpleGroupDelegator.new(proxy_numbers)
    proxy_data = proxy_all.to_i
      #=> {"1"=>1, "2"=>2, "3"=>3}
    #or if you just wanted the integers
    proxy_integers = proxy_all.to_i
      #=> [1, 2, 3]
    puts "proxied to_i: #{proxy_integers.values.inspect}"

    #Why not just use map? i.e.:
    map_numbers =["1", "2", "3"]
    mapped_integers = map_numbers.map{|t| t.to_i}
    puts "mapped to_i: #{mapped_integers.inspect}"

    #Let's compare
    #Group Delegator proxying
    proxy_numbers = ["1", "2", "3"]
    proxy_all = SimpleGroupDelegator.new(proxy_numbers)
    proxy_integers = proxy_all.to_i
    #lets add the string "times" to each number
    proxy_string = proxy_all<< " times"
    #then make it uppercase
    proxy_upcase = proxy_all.upcase

    #map
    map_numbers =["1", "2", "3"]
    map_integers = map_numbers.map{|t| t.to_i}
    #lets add the string "times" to each number
    map_string = map_numbers.map{|t| t << " times"}
    #then make it uppercase
    map_upcase = map_string.map{|t| t.upcase}


    #proxy output
    puts "Proxy: #{proxy_integers.values.inspect}"
    puts "Proxy: #{proxy_string.values.inspect}"
    puts "Proxy: #{proxy_upcase.values.inspect}"
    #=> Proxy: [1, 2, 3]
    #=> Proxy: ["1 times", "2 times", "3 times"]
    #=> Proxy: ["1 TIMES", "2 TIMES", "3 TIMES"]

    #map output
    puts "Map: #{map_integers.inspect}"
    puts "Map: #{map_string.inspect}"
    puts "Map: #{map_upcase.inspect}"
    #=> Map: [1, 2, 3]
    #=> Map: ["1 times", "2 times", "3 times"]
    #=> Map: ["1 TIMES", "2 TIMES", "3 TIMES"]
 
