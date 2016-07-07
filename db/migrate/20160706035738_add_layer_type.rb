class AddLayerType < ActiveRecord::Migration
  def change
    add_column :layers, :endpoint, :string
  end
end
