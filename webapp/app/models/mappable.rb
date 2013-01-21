class Mappable < ActiveRecord::Base
  attr_accessible :geometry

  belongs_to :layer
  has_many :descriptors, dependent: :destroy
end
