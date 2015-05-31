module Api
  class HostapiController < ApplicationController
  	respond_to :json
	def showhosts
      hosts = DockerHosts.all
	  render json: hosts
	end

    def showhosts_active
        hosts = DockerHosts.where(:active => 1)
      render json: hosts
    end

    def addhost
        newhost = DockerHosts.new
        newhost.username = params[:username]
        newhost.password = params[:password]
        newhost.ram = params[:ram].to_i
        newhost.cpu = params[:cpu].to_f
        newhost.hostname = params[:hostname]
        newhost.storage = params[:storage].to_i
        newhost.host_os = params[:host_os]
        newhost.ip = params[:ip]
        newhost.active = params[:active].to_i
        render json: newhost.save
    end

    def edithost
        host = DockerHosts.find_by(:id => params[:id])
        render json: host.update(edithost_params)
    end

    def hostdetails
        host = DockerHosts.find_by(:id => params[:id])
        render json: host
    end

    def get_latest_data_from_influx
        host_details = DockerHosts.find_by(:id => params[:id])
        data = host_details.get_latest_data_from_influx
        render json: data
    end

    private

    def edithost_params
        params[:values].permit(:username, :ram, :password, :host_os, :storage, :ip, :active, :cpu, :hostname)
    end



  end
end
