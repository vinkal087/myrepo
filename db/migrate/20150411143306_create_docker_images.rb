class CreateDockerImages < ActiveRecord::Migration
  def change
    create_table :docker_images do |t|
      t.string :name
      t.string :description
      t.string :baseimageid
      t.string :userid
      t.integer :ispublic
      t.integer :isbaseimage

      t.timestamps
    end
  end
end
