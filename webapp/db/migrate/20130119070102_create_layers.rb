class CreateLayers < ActiveRecord::Migration
  def change
    create_table :layers do |t|
      t.references :map
      t.string :name

      t.timestamps
    end
    add_index :layers, :map_id
  end
end
