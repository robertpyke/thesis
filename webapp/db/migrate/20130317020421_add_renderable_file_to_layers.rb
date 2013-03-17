class AddRenderableFileToLayers < ActiveRecord::Migration
  def change
    change_table :layers do |t|
      t.attachment :renderable_file
      t.string :renderable_file_fingerprint
    end
  end
end
