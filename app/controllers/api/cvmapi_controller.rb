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
    
    def checkvalidlongid(str)
      hexpattern = /^[[:xdigit:]]+$/
      flag = true
      if (hexpattern === str)
        flag = true
      else
        flag = false
      end
      return flag
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

            Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh,success|
               docker_name = params[:userid] + "_" + newcvm.id.to_s
               port =  25000 + newcvm.id
               port = port.to_s
               puts ssh.exec!("pwd")
               puts ssh.exec!("docker build -t #{userdetails.username}_#{newcvm.id} . ")
               shellinabox_port = (25000 + newcvm.id + 1).to_s
               if(params[:memory] == "" && params[:cpu])
                 memory = 16000  
                 cpu = 8
               else
                 memory = params[:memory]
                 cpu = 8
               end

               res = ssh.exec!("docker run -i -t -d --name #{docker_name} -p #{port}:22  -p #{shellinabox_port}:4200 -c #{cpu}  #{userdetails.username}_#{newcvm.id}  /bin/bash ")
               puts res
               #ssh.exec!("docker exec  #{docker_name} service shellinabox start")
              # puts "shell"
               ssh.close
            end          
            res = res.chomp!
            flag = checkvalidlongid(res)
            puts flag
            if flag
               newcvm.container_long_id = res
               newcvm.save
               userdetails.no_of_vm_hosted = userdetails.no_of_vm_hosted.to_i + 1
               userdetails.no_of_vm_hosted = userdetails.no_of_vm_hosted.to_i + 1
            else
              newcvm.delete
            end
            json = {}
            json[:CONTAINER_ID] = res
            json[:SSH_PORT] = port
            json[:SHELLINABOX_PORT] = shellinabox_port
            json[:HOST_IP] = hostdetails.port
            json[:USERNAME] = userdetails.username
            json[:PASSWORD] = userdetails.username
			render json: json
		end

    def writedockerfile(imagename,username)
      content = "FROM ubuntu_shellinabox\n"
      content += "RUN adduser --disabled-password --gecos \"\" #{username}\n"
      content += "RUN echo \'root:#{username}\'| chpasswd\n RUN echo \'#{username}:#{username}\'|chpasswd\n"
      content += "EXPOSE 22\nCMD [\"/usr/sbin/sshd\", \"-D\"]\n"
      File.open("/tmp/Dockerfile", "w+") do |f|
        f.write(content)
      end
    end

    def cvmdetails
         cvmdetail = DockerCvm.find(params[:cvmid])
         hostdetails = DockerHosts.find(cvmdetail.docker_hosts_id)


        Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
           docker_name = cvmdetail.docker_users_id.to_s + "_" + params[:cvmid].to_s
           puts docker_name 
           res = ssh.exec!("docker inspect #{docker_name} ")
           puts res
          ssh.close
          render json: res
        end
    end
   
    def operatecvm
            operation_name =DockerCvmState.find(params[:operation]).command
            res=nil
            cvmdetails = DockerCvm.find(params[:cvmid])
            hostdetails= DockerHosts.find(cvmdetails.docker_hosts_id)
            Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
                docker_name = cvmdetails.docker_users_id.to_s + "_" + params[:cvmid].to_s
               puts "docker #{operation_name} #{docker_name}"
                res = ssh.exec!("docker #{operation_name} #{docker_name}")
                puts res 
                ssh.close
             end
            cvmdetails.docker_cvm_state_id = params[:operation].to_i
            cvmdetails.save
            render json: res
	  end
    

    def commitcvm
        res = nil
        cvmdetails = DockerCvm.find(params[:cvmid])
        hostdetails= DockerHosts.find(cvmdetails.docker_hosts_id)
        Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
          docker_name = cvmdetails.docker_users_id.to_s + "_" + params[:cvmid].to_s
          image_name = cvm_details.docker_users_id.to_s + "_" + params[:imagename]
          res = ssh.exec!("docker #{docker_name} #{imagename}")
          ssh.close
        end
    end   
  end
end
