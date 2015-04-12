class InsertBaseImages < ActiveRecord::SeedMigration
  BASE_IMAGES = {
        1 => ["ubuntu" , "Ubuntu 14.04 Base Image" , 1,1],
        2 => ["centos","Centos", 1,1],
        3 => ["fedora", "Fedore", 1,1],
        4 => ["redis", "Redis" , 1,1]
}
  def self.up
	 BASE_IMAGES.each do |index,array|
                d = DockerImages.new
                d.name = array[0]
                d.description = array[1]
                d.ispublic = array[2]
                d.isbaseimage = array[3]
		d.save
        end
  
  end
  
end
