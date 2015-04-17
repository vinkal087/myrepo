class DockerImages < ActiveRecord::Base
  has_many :docker_cvms
end
