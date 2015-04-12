require 'rubygems'
require 'net/ssh'
module Api
	class CvmapiController < ApplicationController
  		respond_to :json
		def createcvm
			image_exist = DockerCvm.where(:docker_users_id => params[:userid], :container_name => params[:cvmname]).count
			render json: "A user cannot have two containers of same name" if image_exist ==1
			hostdetails = DockerHosts.find(params[:hostid])
            res = nil
            newcvm  = DockerCvm.new
            newcvm.container_name = params[:cvmname]
            newcvm.docker_users_id = params[:userid]
            newcvm.docker_hosts_id = params[:hostid]
            newcvm.docker_images_id = params[:imageid]
            newcvm.ispublic = params[:ispublic]
            newcvm.save

            imagedetails = DockerImages.find(params[:imageid])
            Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
               docker_name = params[:userid] + "_" + newcvm.id.to_s
               res = ssh.exec!("docker run -i -t -d --name #{docker_name} #{imagedetails.name} /bin/bash")
               ssh.close
            end          
            newcvm.container_long_id = res
            newcvm.save
			render json: res
		end

        def operatecvm
            operation = params[:operation]
            name = params[:cvmid]
            Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
                docker_name = params[:userid] + "_" + name
                res = ssh.exec!("docker #{operation} #{docker_name}")
                ssh.close
             end
            render json: res


        end

	end
end
