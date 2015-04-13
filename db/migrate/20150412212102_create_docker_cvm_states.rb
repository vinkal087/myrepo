class CreateDockerCvmStates < ActiveRecord::Migration
  def change
    create_table :docker_cvm_states do |t|
      t.string :state
      t.string :command
      t.timestamps
    end
  end
end
