class RemoveDescriptionFromMappable < ActiveRecord::Migration
  def change
    remove_column :mappables, :description
  end
end
