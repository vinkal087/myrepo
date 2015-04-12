module Api
	class HostapiController < ApplicationController
  		respond_to :json
		def showhosts
			hosts = DockerHosts.select(:id, :hostname, :ip, :cpu, :ram, :storage, :host_os)
			render json: hosts
		end
	end
end
