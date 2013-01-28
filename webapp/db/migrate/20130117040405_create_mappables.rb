class CreateMappables < ActiveRecord::Migration
  def change
    create_table :mappables do |t|
      t.geometry :geometry, srid: 4326
      t.text :description

      t.timestamps
    end

    change_table :mappables do |t|
      t.index :geometry, spatial: true
    end
  end
end
