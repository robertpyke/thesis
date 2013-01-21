class Descriptor < ActiveRecord::Base
  attr_accessible :label, :value
  belongs_to :mappable
end
