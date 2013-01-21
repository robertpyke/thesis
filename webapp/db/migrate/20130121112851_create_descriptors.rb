class CreateDescriptors < ActiveRecord::Migration
  def change
    create_table :descriptors do |t|
      t.string :label
      t.text :value
      t.references :mappable

      t.timestamps
    end
  end
end
