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
         newuser.password = params[:pwd]
         newuser.isadmin = params[:isadmin].nil? ? 0 : params[:isadmin]
         newuser.email = params[:email]
         newuser.save
         render json: newuser
      end

      def authenticate
        puts params
        docker_user = DockerUsers.where(:username => params[:username] , :password => params[:password])
        hash = {}
        if docker_user.count>0
          hash[:AUTHENTICATION] = "SUCCESS"
          hash[:ROLE] = docker_user.first.isadmin == 1 ? "ADMIN" : "USER"
          hash[:USER_ID] = docker_user.first.id
        else
          hash[:AUTHENTICATION] = "ERROR"
        end
        render json: hash
      end
	end
end
