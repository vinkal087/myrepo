 require 'httparty'
 require 'json'
 require 'influxdb'
class DockerCvm < ActiveRecord::Base
  attr_accessor :shellinabox_portval, :ssh_portval
  #belongs_to :docker_user, :docker_image, :docker_host, :docker_cvm_state
 
  def shellinabox_port
    x = 2*self.id + 25000 +1
    x.to_s
  end

  def ssh_port
    x = 2*self.id + 25000
    x.to_s
  end

  def connect_to_influx
    username = 'ritika'
    password = 'ritika'
    database = 'stats'
    influxdb = InfluxDB::Client.new database, :username => username, :password => password
  end

  def get_latest_cvm_data_from_influx
    influx_table = "#{self.docker_users_id}_#{self.id}"
    x = connect_to_influx.query "select * from #{influx_table} where time > now() -2m"
    x = x[influx_table]
    puts x
    return x[x.count-1]
  end

  
  
  def self.format_mem(memory)
    x = memory
    value = x[0..-4].to_f
      if memory[-3]=='K'
         value = 1.0*value/1024
      elsif memory[-3]=='G'
         value = 1.0*value*1024
      end
    return value*1.0
  end  

  def self.cvm_stats_collect(sleeptime,iteration)
    while true
      runnint_state = DockerCvmState.find_by(:state => "RUNNING")
      cvms = DockerCvm.where(:docker_cvm_state_id =>  runnint_state.id)
      count = cvms.count
      ip=[]
      for i in 0..count-1
         
         puts cvms[i].id.to_s + " " + cvms[i].docker_hosts_id.to_s
         host = DockerHosts.find_by(cvms[i].docker_hosts_id)
         
         ip.push(host.ip)
      end
      puts cvms 
      puts ip
      threads = (1..count).map do |i|
          Thread.new(i) do |i|
                cvmid = cvms[i-1].id
                cvmname = "#{cvms[i-1].docker_users_id}_#{cvmid}"  
                puts ip[i-1]
                
                

                res = HTTParty.get("http://#{ip[i-1]}:3000/api/stats/#{iteration}/#{cvmname}") 

                stats = JSON.parse(res.body)
                puts stats
                memused_in_mb = 0
                memtotal_in_mb = 0
                stats['memvalues'].each  do |str|
                   values = str.split('/')
                   memused_in_mb += format_mem(values[0]).to_f
                   memtotal_in_mb += format_mem(values[1]).to_f 
                 end
                c = stats['count'].to_i
                cpu = stats['cpupercent']
                mem = stats['mempercent']
                
                data = {}
                data[:time] = Time.now.to_i
                
                data[:memused_in_mb] =1.0*(memused_in_mb/c).to_f
                data[:memtotal_in_mb] = 1.0*(memtotal_in_mb/c).to_f
                data[:cpu] = cpu.max.to_f
                data[:mem] = mem.max.to_f
                connect.write_point(cvmname, data)   
              end
            
          end

        threads.each {|t| t.join}
        threads.each {|t| t.kill}
        
      sleep sleeptime
    end

  end

  def self.exp_data(time,cvmname)
    x = 0
    while true
      res = HTTParty.get("http://172.27.20.163:3000/api/stats/3/#{cvmname}")  
      stats = JSON.parse(res.body)
      memused_in_mb = 0
      memtotal_in_mb = 0
      stats['memvalues'].each  do |str|
         values = str.split('/')
         memused_in_mb += format_mem(values[0]).to_f
         memtotal_in_mb += format_mem(values[1]).to_f 
        end
      x +=1
      puts x 
      c = stats['count'].to_i
      cpu = stats['cpupercent']
      mem = stats['mempercent']
      
      data = {}
      data[:time] = Time.now.to_i
      
      data[:memused_in_mb] =1.0*(memused_in_mb/c).to_f
      data[:memtotal_in_mb] = 1.0*(memtotal_in_mb/c).to_f
      data[:cpu] = cpu.max.to_f
      data[:mem] = mem.max.to_f
      connect_to_influx.write_point(cvmname, data)
      sleep time
    end
  end


  def show_data(cvmname)
    puts cvmname
     connect_to_influx.query "select * from #{cvmname}" do |name, points|
        puts "#{name} => #{points}"
     end


  end

  def cal_sd(column,cvmname,starttime,endtime)
     mean = 0
     x = connect.query "select MEAN(#{column}), COUNT(#{column}) from #{cvmname}" 
     y= x['cpu_80']
     mean = y[0]['mean']
     count = y[0]['count']
     #puts count 
     
     temp = 0
     data = connect.query "select #{column} from #{cvmname} where time < #{endtime}s and time > #{starttime}s" 
     data[cvmname].each do |i|
        temp += (i['cpu'] * i['cpu'])/count
     end  
     var2 = temp - (mean*mean)
     puts var2   

  end
  def self.connect
    username = 'ritika'
    password = 'ritika'
    database = 'stats'
    influxdb = InfluxDB::Client.new database, :username => username, :password => password
  end

  

  belongs_to :docker_cvm_state
  belongs_to :docker_users
  belongs_to :docker_hosts
  belongs_to :docker_images
end
