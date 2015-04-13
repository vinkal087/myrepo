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
            operation_name =DockerCvmState.find(params[:operation]).command
            res=nil
            cvmdetails = DockerCvm.find(params[:cvmid])
            hostdetails= DockerHosts.find(cvmdetails.docker_hosts_id)
            Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
                docker_name = params[:userid] + "_" + params[:cvmid].to_s
                res = ssh.exec!("docker #{operation_name} #{docker_name}")
                ssh.close
             end
            cvmdetails.docker_cvm_state_id = params[:operation].to_i
            cvmdetails.save
            render json: res
	    end
     end
end
