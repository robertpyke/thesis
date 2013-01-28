class Mappable < ActiveRecord::Base
  attr_accessible :geometry

  self.rgeo_factory_generator = RGeo::Geos.factory_generator
  set_rgeo_factory_for_column(:geometry, RGeo::Geographic.spherical_factory(srid: 4326))

  belongs_to :layer
  has_many :descriptors, dependent: :destroy

  def self.in_rect(bbox)
    w, s, e, n = *bbox
    sw =  self.rgeo_factory_for_column(:geometry).point(w, s)
    ne =  self.rgeo_factory_for_column(:geometry).point(e, n)

    box = RGeo::Cartesian::BoundingBox.create_from_points(sw, ne)
    where{geometry.op('&&', box)}

  end
end
