module Api
	class UserapiController < ApplicationController
  		respond_to :json
		def showusers
			users = DockerUsers.select(:id, :username, :email, :lastlogin)
			render json: users
		end

        def addusers
            newuser = DockerUsers.new
            newuser.username = params[:username]
            newuser.password = params[:password]
            newuser.isadmin = params[:isadmin].to_i
            newuser.email = params[:email]
            newuser.save
            render json: newuser
        end

	end
end
