class RemoveDataFileFromLayers < ActiveRecord::Migration
  def change
    remove_attachment  :layers, :data_file
    remove_column :layers, :data_file_fingerprint
  end
end
