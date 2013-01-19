class Layer < ActiveRecord::Base
  belongs_to :map
  attr_accessible :name
end
