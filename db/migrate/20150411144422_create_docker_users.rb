class CreateDockerUsers < ActiveRecord::Migration
  def change
    create_table :docker_users do |t|
      t.string :username, unique: true
      t.string :email, unique: true
      t.string :password
      t.time :lastlogin
      t.string :oldpassword
      t.integer :isadmin
      t.integer :no_of_vm_running
      t.integer :max_vm_allowed
      t.integer :no_of_vm_hosted

      t.timestamps
    end
  end
end
