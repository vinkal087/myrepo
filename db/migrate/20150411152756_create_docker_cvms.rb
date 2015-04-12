class CreateDockerCvms < ActiveRecord::Migration
  def change
    create_table :docker_cvms do |t|
      t.string :container_name
      t.integer :ispublic
      t.float :cpu
      t.integer :ram
      t.string :open_folder_path
      t.integer :storage_required
      t.string :container_long_id

      t.timestamps
      t.belongs_to :docker_users, :docker_images, :docker_hosts
    end
  end
end
