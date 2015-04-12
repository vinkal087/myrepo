class AddUserDetails < ActiveRecord::SeedMigration
	USER_DETAILS = {
        1 => ["vinkal087","vinkal087@gmail.com","vinkal",1],
        2 => ["ritikavr","ritika88vr@gmail.com","ritika",1],
        3 => ["richas", "richasharma90@gmail.com","richa",0]
    }  
  def self.up
        USER_DETAILS.each do |index,data|
            user = DockerUsers.new
            user.username = data[0]
            user.email = data[1]
            user.password = data[2]
            user.isadmin = data[3]
            user.save
        end
  end
  
end
