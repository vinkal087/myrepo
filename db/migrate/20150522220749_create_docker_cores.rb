class CreateDockerCores < ActiveRecord::Migration
  def change
    create_table :docker_cores do |t|
      t.integer :core_enum

      t.timestamps
      t.belongs_to :docker_cvms
    end
  end
end
