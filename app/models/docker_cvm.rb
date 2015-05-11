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
  belongs_to :docker_cvm_state
  belongs_to :docker_users
  belongs_to :docker_hosts
  belongs_to :docker_images
end
