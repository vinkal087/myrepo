require 'rubygems'
require 'net/ssh'
require 'net/scp'
module Api
	class CvmapiController < ApplicationController
  		respond_to :json
        def showcvmall
          cvm_all = DockerCvm.joins(:docker_cvm_state,:docker_users,:docker_hosts,:docker_images).select("docker_cvms.id,docker_cvms.container_long_id,docker_cvms.docker_users_id,docker_cvms.docker_hosts_id,docker_cvms.container_name,docker_cvms.ispublic,docker_cvms.cpu,docker_cvms.ram,docker_cvm_states.state,docker_users.username,docker_hosts.hostname,docker_images.name")
          render json: cvm_all

        end

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
            newcvm.docker_cvm_state_id = 1
            newcvm.save
            imagedetails = DockerImages.find(params[:imageid])
            userdetails = DockerUsers.find(params[:userid])
            writedockerfile(imagedetails.name, userdetails.username)
            
            Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |session|
              session.scp.upload!("/tmp/Dockerfile", "/home/ritika")
            end

            Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
               docker_name = params[:userid] + "_" + newcvm.id.to_s
               port =  25000 + newcvm.id
               port = port.to_s
               puts ssh.exec!("pwd")
               puts ssh.exec!("docker build -t #{userdetails.username}_#{newcvm.id} . ")
               res = ssh.exec!("docker run -i -t -d --name #{docker_name} -p #{port}:22 #{userdetails.username}_#{newcvm.id} /bin/bash ")
               puts res
               ssh.close
            end          
            newcvm.container_long_id = res
            newcvm.save
			render json: res
		end

    def writedockerfile(imagename,username)
      content = "FROM #{imagename}\n"
      content += "RUN apt-get -y update\nRUN apt-get update && apt-get install -y openssh-server \n "
      content += "RUN adduser --disabled-password --gecos \"\" #{username}\n"
      content += "RUN echo \'root:#{username}\'| chpasswd\n RUN echo \'#{username}:#{username}\'|chpasswd\n"
      content += "EXPOSE 22\nCMD [\"/usr/sbin/sshd\", \"-D\"]\n"
      File.open("/tmp/Dockerfile", "w+") do |f|
        f.write(content)
      end
    end

    def cvmdetails
        Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
               docker_name = params[:userid] + "_" + newcvm.id.to_s
               port =  25000 + newcvm.id
               port = port.to_s
               puts ssh.exec!("pwd")
               puts ssh.exec!("docker build -t #{userdetails.username}_#{newcvm.id} . ")
               res = ssh.exec!("docker run -i -t -d --name #{docker_name} -p #{port}:22 #{userdetails.username}_#{newcvm.id} /bin/bash ")
               puts res
               ssh.close
            end   



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
