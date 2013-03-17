class AddCsvFileToLayers < ActiveRecord::Migration
  def change
    change_table :layers do |t|
      t.attachment :csv_file
      t.string :csv_file_fingerprint
    end
  end
end
