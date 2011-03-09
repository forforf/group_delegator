require 'group_delegator'
require 'open-uri'
require 'benchmark'
class Bing
  QueryString = "http://www.bing.com/search?q="
  def search(search_string)
    url = QueryString + URI.escape(search_string)
    open(url){|f| f.meta} 
  end
end

class Google
  QueryString = "http://www.google.com/search?q="
  def search(search_string)
    url = QueryString + URI.escape(search_string)
    open(url){|f| f.meta}
  end
end

class Yahoo
  QueryString = "http://search.yahoo.com/search?p="
  def search(search_string)
    url = QueryString + URI.escape(search_string)
    open(url){|f| f.meta}
  end
end

#default is iterative searchclass IterativeSearch < SimpleDel
searchers = [Bing.new, Google.new, Yahoo.new]
search_iteratively = SimpleGroupDelegator.new(searchers)
search_threaded = SimpleGroupDelegator.new(searchers, :threaded)
search_first_response = SimpleGroupDelegator.new(searchers, :first_response)

iterative = Benchmark.realtime { search_iteratively.search('stuff') }
threaded = Benchmark.realtime { search_threaded.search('stuff') }
first_resp = Benchmark.realtime { search_first_response.search('stuff') }

puts "Iterative Search Time: #{iterative}"
puts "Threaded Search Time : #{threaded}"
puts "First Response Time  : #{first_resp}"
