module Api
	class ImagesapiController < ApplicationController
  		respond_to :json
  		def show
			base_images = DockerImages.where(:isbaseimage => 1).select(:name,:description,:id)
			render json: base_images
  		end
	end
end
