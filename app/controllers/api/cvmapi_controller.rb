require 'rubygems'
require 'net/ssh'
require 'net/scp'
module Api
	class CvmapiController < ApplicationController
  		respond_to :json
    

    def showcvmall
      user_details = DockerUsers.find_by(id: params[:user_id])
      cvm_all = nil
      if user_details.isadmin ==1
        cvm_all = DockerCvm.joins(:docker_cvm_state,:docker_users,:docker_hosts,:docker_images).select("docker_cvms.id,docker_cvms.container_long_id,docker_cvms.docker_users_id,docker_cvms.docker_hosts_id,docker_cvms.container_name,docker_cvms.ispublic,docker_cvms.cpu,docker_cvms.ram,docker_cvm_states.state,docker_users.username,docker_hosts.hostname,docker_hosts.ip,docker_images.name")
      else
        cvm_all = DockerCvm.joins(:docker_cvm_state,:docker_users,:docker_hosts,:docker_images).select("docker_cvms.id,docker_cvms.container_long_id,docker_cvms.docker_users_id,docker_cvms.docker_hosts_id,docker_cvms.container_name,docker_cvms.ispublic,docker_cvms.cpu,docker_cvms.ram,docker_cvm_states.state,docker_users.username,docker_hosts.hostname,docker_hosts.ip,docker_images.name").where(:docker_users_id => user_details.id)
      end
      cvm_all.each do |cvm_details|
        cvm_details.shellinabox_portval = cvm_details.shellinabox_port
        cvm_details.ssh_portval = cvm_details.ssh_port
      end
      render json: cvm_all
    end
    
    def checkvalidlongid(str)
      hexpattern = /^[[:xdigit:]]+$/
      flag = false
      if str == nil
        flag = false
      end

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
      writedockerfile(imagedetails.name, userdetails.username,params[:imageid])
      Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |session|
        session.scp.upload!("/tmp/Dockerfile", "/home/ritika")
      end

      Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh,success|
         docker_name = params[:userid] + "_" + newcvm.id.to_s
         port =  newcvm.ssh_port

         puts ssh.exec!("docker build -t #{userdetails.username}_#{newcvm.id} . ")
         shellinabox_port = newcvm.shellinabox_port
         
         if(params[:memory] == "" && params[:cpu])
           memory = 16000  
           cpu = 8
         else
           memory = params[:memory]
           cpu = 8
         end
        command = "docker run -itd --name #{docker_name} -p #{port}:22 --restart=on-failure:5  -p #{shellinabox_port}:4200 -c #{cpu}  #{userdetails.username}_#{newcvm.id}  /bin/bash "
         res = ssh.exec!(command)
         ssh.exec!("timeout 2 docker exec  #{docker_name} service shellinabox start")
         ssh.exec!("timeout 2 docker exec  #{docker_name} service ssh start")
         ssh.close
      end          
      res = res.chomp!
      flag = checkvalidlongid(res)
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

    def writedockerfile(imagename,username,imageid)
      registry = APP_CONFIG['DOCKER_REGISTRY']
      image = DockerImages.find(imageid)
      imagetag = image.tag.split('/')
      if imagetag[0]!=registry
          image.tag = registry + "/" + imagetag[1]
          image.save
      end
      content = "FROM #{registry}/#{imagename}\n"
      content += "RUN adduser --disabled-password --gecos \"\" #{username}\n"
      content += "RUN echo \'root:#{username}\'| chpasswd\n RUN echo \'#{username}:#{username}\'|chpasswd\n"
      content += "EXPOSE 22\nCMD [\"/usr/sbin/sshd\", \"-D\"]\n"
      File.open("/tmp/Dockerfile", "w+") do |f|
        f.write(content)
      end
    end

    def cvmdetails  
        
    end
   
    def operatecvm
      operation_name =DockerCvmState.find(params[:operation]).command
      res=nil
      cvmdetails = DockerCvm.find(params[:cvmid])
      hostdetails= DockerHosts.find(cvmdetails.docker_hosts_id)
      Net::SSH.start(hostdetails.ip, hostdetails.username, :password => hostdetails.password) do |ssh|
        docker_name = cvmdetails.docker_users_id.to_s + "_" + params[:cvmid].to_s

        if operation_name == 'kill' || operation_name == 'stop'
          res = ssh.exec!("docker commit #{cvmdetails.container_long_id} #{cvmdetails.container_name}")
          res = ssh.exec!("docker tag #{cvmdetails.container_name} #{APP_CONFIG['DOCKER_REGISTRY']}/#{cvmdetails.container_name}")
          res = ssh.exec!("docker push #{APP_CONFIG['DOCKER_REGISTRY']}/#{cvmdetails.container_name}")
          res = ssh.exec!("docker #{operation_name} #{docker_name}")
          newimg = DockerImages.new
          newimg.name = cvmdetails.container_name
          newimg.description = cvmdetails.container_name
          newimg.ispublic = cvmdetails.ispublic
          newimg.isbaseimage = 0
          newimg.docker_images_id = cvmdetails.docker_images_id 
          newimg.docker_users_id = cvmdetails.docker_users_id
          newimg.tag = "#{APP_CONFIG['DOCKER_REGISTRY']}/#{cvmdetails.container_name}"
          newimg.save
        else
          res = ssh.exec!("docker #{operation_name} #{docker_name}")
          ssh.close
        end
      end
      cvmdetails.docker_cvm_state_id = params[:operation].to_i
      cvmdetails.save
      render json: res
	  end
    
    
  end
end
