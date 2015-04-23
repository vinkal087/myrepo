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
        cnt = DockerUsers.where(:username => params[:username] , :password => params[:password]).count
        puts "cnt"+cnt.to_s
        render json: cnt>0
      end
	end
end
