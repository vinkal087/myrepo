module Api
	class ImagesapiController < ApplicationController
  		respond_to :json
  		def show
			base_images = DockerImages.where(:isbaseimage => 1).select(:name,:description,:id)
			render json: base_images
  		end
		
		def showderived
			images = DockerImages.where(:ispublic => 1, :isbaseimage => 0, :docker_images_id => params[:id]).select(:name, :description, :id)

			render json: images
		end
	end
end
