module Api
	class UserapiController < ApplicationController
  		respond_to :json
		def showusers
			users = DockerUsers.select(:id, :username, :email, :lastlogin)
			render json: users
		end
	end
end
