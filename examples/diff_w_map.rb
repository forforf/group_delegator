    require 'group_delegator'
    #Note the last elements of the array
    proxy_numbers = ["1", "2", "3", :a, "b", "cat"]
    proxy_all = SimpleGroupDelegator.new(proxy_numbers)
    proxy_data = proxy_all.to_i
      #=> {"1"=>1, "2"=>2, "3"=>3}
    #or if you just wanted the integers
    proxy_integers = proxy_all.to_i
      #=> [1, 2, 3]
    puts "proxied to_i: #{proxy_integers.values.inspect}"

    #Why not just use map? i.e.:
    map_numbers =["1", "2", "3", :a, "b", "cat"]
    begin
      mapped_integers = map_numbers.map{|t| t.to_i}
    rescue NoMethodError
      puts "We just rescued a NoMehodError in a #map method call"
      #=> NoMethod Error
    end
    puts "mapped to_i: #{mapped_integers.inspect}"

