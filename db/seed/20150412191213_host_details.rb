class HostDetails < ActiveRecord::SeedMigration

	HOST_DETAILS ={
		1 => ["hostname1","172.27.30.101","ritika","ritika",4,4096, 200],
		2 => ["hostname2","172.27.22.15","ritika","ritika",4,4096,200]
}  
  def self.up
  	HOST_DETAILS.each do |index,data|
		host = DockerHosts.new
		host.hostname = data[0]
		host.ip = data[1]
		host.username = data[2]
		host.password = data[3]
		host.cpu = data[4]
		host.ram = data[5]
		host.storage = data[6]
		host.save
	end
  end
  
end
