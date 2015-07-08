require 'httparty'
require 'json'
require 'influxdb'
class DockerHosts < ActiveRecord::Base
  def self.connect
    username = 'ritika'
    password = 'ritika'
    database = 'stats'
    influxdb = InfluxDB::Client.new database, :username => username, :password => password
  end
  def connect2
    username = 'ritika'
    password = 'ritika'
    database = 'stats'
    influxdb = InfluxDB::Client.new database, :username => username, :password => password
  end

  def get_latest_data_from_influx
    influx_table = "#{self.hostname}_cpu_#{self.ip}"
    x = connect2.query "select * from #{influx_table} where time > now() -2m"
    x = x[influx_table]
    puts x
    return x[x.count-1]
  end
  def get_latest_data_from_influx_mem
    influx_table = "#{self.hostname}_mem_#{self.ip}"
    x = connect2.query "select * from #{influx_table} where time > now() -2m"
    x = x[influx_table]
    puts x
    return x[x.count-1]
  end
  

  def self.host_stats_collect(sleeptime,interval,iteration)
   
    while true
    hosts = DockerHosts.where(:active => 1)
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

  has_many :docker_cvms
end
