class Map < ActiveRecord::Base
  has_many :layers, dependent: :destroy
  belongs_to :user
  validates_presence_of :user

  attr_accessible :description, :name

end
