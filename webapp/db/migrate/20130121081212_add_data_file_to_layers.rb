class AddDataFileToLayers < ActiveRecord::Migration
  def change
    change_table :layers do |t|
      t.attachment :data_file
      t.string :data_file_fingerprint
    end
  end
end
