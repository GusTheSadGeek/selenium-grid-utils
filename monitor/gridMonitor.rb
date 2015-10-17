module GridMonitor

#require '../../watir/features/support/remoteControl.rb'
require 'thread'
#include RemoteControl
require 'json'
require 'open-uri'



# Thread safe printing
$print_mutex = Mutex.new
def prt(s)
  $print_mutex.synchronize{
    puts(s)
  }
end


class Node
  def initialize(name, ip, port, rdp=nil)
    @name = name
    @ip = ip
    @port = port
    @thread = nil
    @stop = false
    rdp # not used
    @status={
        :status=>'NOK',
        :lastseen=>'Never',
        :grid_ref=>'?'
    }
    @jobs={
    }
    @info={}
  end

  def fudge(browser)
    browser.each do |key,b|
      begin
       if b.include? 'DOCKER'
         matches = /branch=(\S+).*output_([A-Za-z0-9]+)_.*/.match(b)
         if matches.length == 3
           browser[key] = "D #{matches[1]} #{matches[2]}"
         end
       end
      rescue
        #
      end
    end
  end

  def query_status
    url = "http://#{@ip}:#{@port}/info_json"
    begin
      rawinfo = URI.parse(url).read()
      new_info = JSON.parse(rawinfo)
#      puts new_info
      @info = new_info
      @status[:status] = 'OK'
      @status[:grid_ref] = @info[:grid_ref]
      @status[:lastseen] = Time.now.to_s()
    rescue => e
      puts e.message
      @info[:vm_name] = @name
      @info[:host_name] = @ip
      @status[:status] = 'NOK'
    end
  end

  def get_info(grid_ref)
    i=@info
    i[:lastseen] = @status[:lastseen]
    i[:status] = @status[:status]
    i[:jobs] = @jobs
    if i[:grid_ref] == nil
      i[:grid_ref] = grid_ref
    end
    i
  end

  def grid_ref
    @status[:grid_ref]
  end

  def monitor_node
    while @run do
      query_status
      now = Time.now
      @jobs.each do |ref,job|
        if (now - job[:time]) > 15
           @jobs.delete(ref)
        end
      end
      sleep(10)
    end
  end

  def setinfo(sender, test, br, info)
    ref = sender+test
    if info=='X'
      if @jobs[ref]
        @jobs.delete(ref)
      end
    else
      job={
          :time => Time.now ,
          :info => info,
          :ref => sender+test,
          :br => br
      }
      @jobs[ref]=job
    end
  end

  def start
    @run = true
    _ = Thread.new do
      begin
        monitor_node
      rescue  => e
        prt "Exception running job #{@name} #{e.message}"
        prt($!)
        prt($@)
      end
    end
  end

  def stop
    @run = true
  end
end

@nodes = {}

def GridMonitor.get_nodes
  node_info=[]
  @nodes.each do |ref, node|
    ref
    node_info.push( node.get_info(ref) )
  end
  node_info.to_json
end

def GridMonitor.setinfo(ref, sender, test, br, info)
  if @nodes[ref]
    @nodes[ref].setinfo(sender,test, br, info.sub('_',' '))
  else
    puts "Node Ref:#{ref} - unknown"
  end
end


def GridMonitor.monitor

#Linux
#  @nodes.push(Node.new('pod_VM','podalirius', 17000))
#  @nodes.push(Node.new('podalirius_VM','podalirius.we7.local', 17000))

#  @nodes.push(Node.new('aiakos_VM',    'aiakos', 17000))
  @nodes['Linux_1'] = Node.new('aiakos_VM', 'aiakos', 17000)

#nodes.push(Node.new('aiakos2_VM',    'aiakos.we7.local', 17000))
# Windows

  @nodes['W7IE9_1']   = Node.new('Win7IE9_VM',   'phocus', 17003)#,'rdesktop -a 16 -z -xm -P -N phocus:5004 -u det -p det -g 1680x1024 -r sound:remote')
  @nodes['W7IE10_1']  = Node.new('Win7IE10_VM',  'phocus', 17004)#,'rdesktop -a 16 -z -xm -P -N phocus:5004 -u det -p det -g 1680x1024 -r sound:remote'))
  @nodes['W7IE11_1']  =Node.new('Win7IE11_VM',  'protesilaus', 17005)#,'rdesktop -a 16 -z -xm -P -N protesilaus:5005 -u det -p det -g 1680x1024 -r sound:remote'))
  @nodes['W8IE10_1']  =Node.new('Win8IE10_VM',  'protesilaus', 17006)#,'rdesktop -a 16 -z -xm -P -N protesilaus:5006 -u det -p det -g 1680x1024 -r sound:remote'))
  @nodes['W81IE11_1'] =Node.new('Win81IE11_VM', 'protesilaus', 17007)#,'rdesktop -a 16 -z -xm -P -N protesilaus:5007 -u det -p det -g 1680x1024 -r sound:remote'))

# QA machines
  @nodes['W7IE9_2'] = Node.new('Win7IE9_QA',   'phrastor', 17000)#,'rdesktop -a 16 -z -xm -P -N phrastor:3389 -u det -p detdetdet -g 1680x1024 -r sound:remote'))
  @nodes['W7IE10_2'] = Node.new('Win7IE10_QA',  'saon', 17000)#,'rdesktop -a 16 -z -xm -P -N saon:3389 -u det -p detdetdet -g 1680x1024 -r sound:remote'))
  @nodes['W7IE11_2'] = Node.new('Win7IE11_QA',  'prothoenor', 17000)#,'rdesktop -a 16 -z -xm -P -N prothoenor:3389 -u det -p detdetdet -g 1680x1024 -r sound:remote'))
  @nodes['W8IE10_2'] = Node.new('Win8IE10_VM',  'oenone', 17006)#,'rdesktop -a 16 -z -xm -P -N oenone:5006 -u det -p det -g 1680x1024 -r sound:remote'))    # temp standin for proclia
  @nodes['W81IE11_2'] = Node.new('Win81IE11_QA',  'procrustes.blinkbox.local', 17000)#,'rdesktop -a 16 -z -xm -P -N procrustes.blinkbox.local:3389 -u det -p detdetdet -g 1680x1024 -r sound:remote'))

  begin
    @nodes.each do |ref, node|
      ref
      node.start
    end

  #   while true do
  #     prt '==================================='
  #     nodes.each do |node|
  #       info = node.info_line
  #       if info.length > 0
  #         prt info
  #       end
  #     end
  #     sleep(10)
  #   end
  # rescue
  #
  # end
  #
  # nodes.each do |node|
  #   node.stop
   end
end




end
