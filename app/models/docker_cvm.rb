 require 'httparty'
 require 'json'
 require 'influxdb'
class DockerCvm < ActiveRecord::Base
  #belongs_to :docker_user, :docker_image, :docker_host, :docker_cvm_state
 
  def shellinabox_port
    x = self.id + 25000 +1
    x.to_s
  end

  def ssh_port
    x = self.id + 25000
    x.to_s
  end

  def connect_to_influx
    username = 'ritika'
    password = 'ritika'
    database = 'stats'
    influxdb = InfluxDB::Client.new database, :username => username, :password => password
  end
  
  def format_mem(memory)
    x = memory
    value = x[0..-4].to_f
      if memory[-3]=='K'
         value = 1.0*value/1024
      elsif memory[-3]=='G'
         value = 1.0*value*1024
      end
    return value*1.0
  end  

  def cvm_stats_collect(sleeptime,iteration)
    while true
      cvms = DockerCvm.all
      count = cvms.count
       
      threads = (1..count).map do |i|
          Thread.new(i) do |i|
              
                #cvm = cvms[i]
                cvmid = cvms[i-1].id
                cvmname = "#{cvms[i-1].docker_users_id}_#{cvmid}"
                host = DockerHosts.find_by(cvmid)
                #cvmname = "#{cvm.docker_users_id}_#{cvm.id}"
                
                res = HTTParty.get("http://#{host.ip}:3000/api/stats/#{iteration}/#{cvmname}")  
                stats = JSON.parse(res.body)
                

                memused_in_mb = 0
                memtotal_in_mb = 0
                stats['memvalues'].each  do |str|
                   values = str.split('/')
                   memused_in_mb += format_mem(values[0]).to_f
                   memtotal_in_mb += format_mem(values[1]).to_f 
                 end
               
                puts "after data" 
                c = stats['count'].to_i
                cpu = stats['cpupercent']
                mem = stats['mempercent']
                
                data = {}
                data[:time] = Time.now.to_i
                
                data[:memused_in_mb] =1.0*(memused_in_mb/c).to_f
                data[:memtotal_in_mb] = 1.0*(memtotal_in_mb/c).to_f
                data[:cpu] = cpu.max.to_f
                data[:mem] = mem.max.to_f
                #puts data
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
  def connect
    username = 'ritika'
    password = 'ritika'
    database = 'stats'
    influxdb = InfluxDB::Client.new database, :username => username, :password => password
  end
  

  def host_stats_collect(sleeptime,interval,iteration)
   
    while true
    hosts = DockerHosts.all
    puts hosts
    count = hosts.count
        threads = (1..count).map do |i|
          Thread.new(i) do |i|
            
                hostip = hosts[i-1].ip
                hostname = hosts[i-1].hostname
                puts hostip
                mem_res = HTTParty.get("http://#{hostip}:3000/api/memory/#{interval}/#{iteration}") 
                cpu_res = HTTParty.get("http://#{hostip}:3000/api/cpu/#{interval}/#{iteration}") 
                x = JSON.parse(mem_res.body)
                y = JSON.parse(cpu_res.body)
                cpu_data = y['sysstat']['hosts'][0]['statistics']
                mem_data = x['sysstat']['hosts'][0]['statistics']
                cores = y['sysstat']['hosts'][0]['number-of-cpus']
                cpu_stats={}
                cpu_all=[]
                cpu_cores_temp={}
                for i in 0..cores-1
                    cpu_cores_temp["core_#{i}"]=[]
                    cpu_stats["core_#{i}"]=0
                end
                cpu_data.each do |data|
                  a = data['cpu-load'][0]['user'].to_f + data['cpu-load'][0]['nice'].to_f
                      + data['cpu-load'][0]['system'].to_f + data['cpu-load'][0]['iowait'].to_f 
                      + data['cpu-load'][0]['steal'].to_f
                  cpu_all.push(a)
                  t=0
                  for i in 1..cores
                    t = data['cpu-load'][i]['user'].to_f + data['cpu-load'][i]['nice'].to_f
                      + data['cpu-load'][i]['system'].to_f + data['cpu-load'][i]['iowait'].to_f 
                      + data['cpu-load'][i]['steal'].to_f
                    
                    cpu_cores_temp["core_#{i-1}"].push(t)
                  end
                   #puts cpu_cores_temp
                end
                for i in 0..cores-1
                    cpu_stats["core_#{i}"]= 1.0 * (cpu_cores_temp["core_#{i}"].sum.to_f/iteration)
                    
                end
                cpu_stats['cpu_all'] = 1.0 * (cpu_all.sum.to_f/iteration)
                puts cpu_stats
                connect.write_point("#{hostname}_cpu_#{hostip}",cpu_stats)
                mem_stats = {}
                free =[]
                used =[]
                percent =[]
                
                mem_data.each do |data|
                   free.push(data['memory']['memfree'].to_f)
                   used.push(data['memory']['memused'].to_f)
                   percent.push(data['memory']['memused-percent'].to_f)
                end
                mem_stats['memused']=1.0*(used.sum.to_f/iteration)
                mem_stats['memfree']=1.0*(free.sum.to_f/iteration)
                mem_stats['memused_percent']=1.0*(percent.sum.to_f/iteration)
                puts mem_stats
                connect.write_point("#{hostname}_mem_#{hostip}",mem_stats)
              end
              
            end
    threads.each {|t| t.join}
    threads.each {|t| t.kill}
    sleep sleeptime
    end

  end

  belongs_to :docker_cvm_state
  belongs_to :docker_users
  belongs_to :docker_hosts
  belongs_to :docker_images
end
