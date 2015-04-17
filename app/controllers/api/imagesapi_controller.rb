require 'rubygems'
require 'net/ssh'

module Api
	class ImagesapiController < ApplicationController
  		respond_to :json
  		def show
			base_images = DockerImages.where(:isbaseimage => 1).select(:name,:description,:id)
			render json: base_images
  		end
		
		def showderived
			images = DockerImages.where(:ispublic => 1, :isbaseimage => 0, :docker_images_id => params[:id]).select(:name, :description, :id,:docker_images_id)

			render json: images
		end

    def showall
      allimages = DockerImages.select(:name,:description,:id,:docker_images_id)
      render json: allimages 
     
    end

        def commitnew
             newimage = DockerImages.new
             newimage.name = params[:imagename]
             newimage.description = params[:description]
             newimage.isbaseimage = 0
             newimage.ispublic = params[:ispublic]

              res=nil
              cvmdetails = DockerCvm.find(params[:cvmid])
              newimage.docker_users_id = cvmdetails.docker_users_id
              newimage.docker_images_id = cvmdetails.docker_images_id

              hostdetails= DockerHosts.find(cvmdetails.docker_hosts_id)
              Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
              image_name = params[:imagename]
              cvm_name = cvmdetails.docker_users_id.to_s + "_" + params[:cvmid].to_s
              puts "docker commit  #{cvm_name}  #{image_name}"
              res = ssh.exec!("docker commit #{cvm_name} #{image_name}")
              ssh.close
               end
              newimage.save
              render json: res

        end
	end
end
