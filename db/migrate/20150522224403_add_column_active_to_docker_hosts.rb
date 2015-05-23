class AddColumnActiveToDockerHosts < ActiveRecord::Migration
  def change
    add_column :docker_hosts, :active , :boolean
  end
end
