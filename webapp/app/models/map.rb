class Map < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user

  attr_accessible :description, :name

end
