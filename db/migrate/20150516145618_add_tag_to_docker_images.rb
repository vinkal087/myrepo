class AddTagToDockerImages < ActiveRecord::Migration
  def change
    add_column :docker_images, :tag, :string
  end
end
