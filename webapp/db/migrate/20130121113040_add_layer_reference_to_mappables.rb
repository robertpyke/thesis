class AddLayerReferenceToMappables < ActiveRecord::Migration
  def change
    change_table :mappables do |t|
      t.references :layer
    end
  end
end
