class CreateDockerHosts < ActiveRecord::Migration
  def change
    create_table :docker_hosts do |t|
      t.string :hostname
      t.string :ip
      t.string :username
      t.string :password
      t.float :cpu
      t.integer :ram
      t.integer :storage
      t.string :host_os

      t.timestamps
    end
  end
end
