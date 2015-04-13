module Api
	class HostapiController < ApplicationController
  		respond_to :json
		def showhosts
			hosts = DockerHosts.select(:id, :hostname, :ip, :cpu, :ram, :storage, :host_os)
			render json: hosts
		end
        def addhost
            newhost = DockerHosts.new
            newhost.username = params[:username]
            newhost.password = params[:password]
            newhost.ram = params[:ram].to_i
            newhost.cpu = params[:cpu].to_f
            newhost.hostname = params[:name]
            newhost.storage = params[:storage].to_i
            newhost.host_os = params[:hostos]
            newhost.ip = params[:ip]
            newhost.save
            render json: newhost
        end

	end
end
