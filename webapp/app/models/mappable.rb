class Mappable < ActiveRecord::Base
  attr_accessible :description, :geometry
end
