class CreateMappables < ActiveRecord::Migration
  def change
    create_table :mappables do |t|
      t.geometry :geometry
      t.text :description

      t.timestamps
    end
  end
end
