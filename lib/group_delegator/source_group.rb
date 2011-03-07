require 'thread'

#This class is the container for the objects that will receive common method calls
# It also manages the concurrency model to be used when performing the method calls
class SourceGroup
  attr_accessor :concurrency_model #:sources, :valid_response_trace, :invalid_response_list
  
  #Built-in concurrency models for delegating methods
  ##execute forwarding in an iterative fashion
  IterativeBlock = lambda{ |sources, m, *args, &block|
    all_resps = {}
    sources.each do |source|
      this_resp = {}
      begin
        #collect valid responses
        all_resps[:valid] ||= {}
        all_resps[:valid][source] = source.__send__(m, *args, &block)
      rescue NoMethodError
        #oops we have some invalid responses, collect those too
        all_resps[:invalid] ||= []
        all_resps[:invalid] << source 
      end
    end
    all_resps
  }
  
  ##If we like speed (with a dash of danger) we can thread the requests rather than iterate
  ThreadedBlock= lambda{ |sources, m, *args, &block|
    all_resps = {}
    threads = []
    sources.each do |source|
      threads << Thread.new(source) do |src|
        Thread.current[:src] = src
        begin
          Thread.current[:resp] = src.__send__(m, *args, &block)
        rescue
          Thread.current[:err] =  src
        end
      end
    end
    
    threads.each do |t|
      t.join
      src = t[:src]  #proxied object
      if t[:resp]
        #valid response
        all_resps[:valid] ||= {}
        all_resps[:valid][src] = t[:resp]
      elsif t[:err]
        #oops error
        all_resps[:invalid] ||= []
        all_resps[:invalid] << t[:err]
      else
        raise "source returned an invalid responseto its thread."\
             "Response thread: #{t} source: #{source.inspect}"
      end
    end
    all_resps
  }
  
   ##More speed (with more danger) we can use the first valid response (note the change in t.join)
   ##How to react to the first response, maybe fibers?
  ThreadedFirstResponseBlock= lambda{ |sources, m, *args, &block|
    t0 = Time.now
    first_resp = {}
    source_threads = []
    queue = Queue.new
    sources.each do |source|
      source_threads << Thread.new do
        begin
          queue << { source => source.__send__(m, *args, &block)}
        rescue
          Thread.current[:err] =  source #these errored out before a valid entry in queue
        end
      end
    end

    valid_response = nil
    #limit the time for responses
    check_queue = Thread.new do
      until valid_response do
        sleep 0.01 #don't consume all available resources on a silly event loop
        valid_response = queue.shift   #shift not pop in case more than one response in queue
      end
      Thread.current[:q_response] = valid_response
    end
  
    #Continue if all source_threads finish,  but if check_queue finishes first, continue regardless of source_threads status
    any_thread_running = true
    while any_thread_running do
      sleep 0.01
      any_src_thr_alive = source_threads.inject(false) {|alive, thr| alive || thr.status}
      any_thread_running = check_queue.status && any_src_thr_alive
    end
    
    t1 = Time.now
    
    if (t1-t0) < 0.1
      sleep 0.05  #give time fot things to stabilize
    end
    #puts "Response from queue: #{check_queue[:q_response].inspect}"
    

    invalid_resps = []
    source_threads.each do |t|
      invalid_resps << t[:err] if t[:err]
    end
    #returning source_threads so that the caller can join them if needed (i.e. ending in a know state)
    #invalid_responses only contains responsed from threads that completed prior to the first valid response
    first_resp = { :valid => valid_response, :invalid => invalid_resps, :threads => source_threads }
  }
  
  #  
  def initialize(sources, concurrency_model = :iterative)
    @sources = sources
    @concurrency_model = concurrency_model
  end
  
  def forward(m, *args, &block)
    forward_custom(@concurrency_model, m, *args, &block)
  end
  
  def forward_custom(forward_method, m, *args, &block)
    forward_block = case forward_method
      when :iterative
        IterativeBlock
      when :threaded
        ThreadedBlock
      when :first_response
        ThreadedFirstResponseBlock
      when Proc
        forward_method
      else
        raise "Invalid parameter: #{forward_method.inspect}"
      end
      
    @valid_response_trace = {}
    @invalid_response_list = []
    sources = @sources
    if sources.size > 0
      resp = forward_block.call(sources, m, *args, &block)
      @valid_response_trace = resp[:valid]
    else
      raise "No sources assigned"
    end
    @valid_response_trace
  end

  #just some sugar
  def forward_iterative(m, *args, &block)
    forward_custom(:iterative, m, *args, & block)
  end

  def forward_threaded(m, *args, &block)
    forward_custom(:threaded, m, *args, & block)
  end

  def forward_first_resp(m, *args, &block)
    forward_custom(:first_response, m, *args, &block)
  end
end
