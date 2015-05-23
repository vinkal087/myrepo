class AddColumnCount < ActiveRecord::Migration
  def change
    add_column :docker_cvms, :count , :integer
  end
end
