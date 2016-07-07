class ChangeLayerName < ActiveRecord::Migration
  def change
    rename_column :layers, :geoserver_layername, :layername
  end
end
