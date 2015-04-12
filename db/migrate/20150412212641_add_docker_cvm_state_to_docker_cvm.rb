class AddDockerCvmStateToDockerCvm < ActiveRecord::Migration
  def change
    add_reference :docker_cvms, :docker_cvm_state, index: true
  end
end
