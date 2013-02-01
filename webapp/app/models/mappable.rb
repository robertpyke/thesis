class Mappable < ActiveRecord::Base
  attr_accessible :geometry

  self.rgeo_factory_generator = RGeo::Geos.factory_generator
  set_rgeo_factory_for_column(:geometry, RGeo::Geographic.spherical_factory(srid: 4326))

  belongs_to :layer
  has_many :descriptors, dependent: :destroy

  # Get the mappables that fall inside the bbox
  # [+bbox] an Array of floats (lat/lng degrees decimal) [w, s, e, n]

  def self.in_rect(bbox)
    w, s, e, n = *bbox
    sw =  self.rgeo_factory_for_column(:geometry).point(w, s)
    ne =  self.rgeo_factory_for_column(:geometry).point(e, n)

    box = RGeo::Cartesian::BoundingBox.create_from_points(sw, ne)
    where{geometry.op('&&', box)}
  end

  # Given a bbox, determine the appropriate grid size
  # for clustering.
  # If bbox is nil, returns a grid_size of nil.

  def self.get_cluster_grid_size(bbox=nil)
    return nil if bbox.nil?
    bbox = bbox.split(',').map { |el| el.to_f }
    w, s, e, n = *bbox

    lat_range = w - e
    lng_range = n - s

    lat_lng_range_avg = (lat_range + lng_range) / 2
    lat_lng_range_avg = lat_lng_range_avg.abs

    grid_size = nil

    griddiness = 1
    if lat_lng_range_avg > (griddiness*200)
      grid_size = 8
    elsif lat_lng_range_avg > (griddiness*100)
      grid_size = 4
    elsif lat_lng_range_avg > (griddiness*50)
      grid_size = 2
    elsif lat_lng_range_avg > (griddiness*25)
      grid_size = 1
    elsif lat_lng_range_avg > (griddiness*12)
      grid_size = 0.5
    elsif lat_lng_range_avg > (griddiness*5)
      grid_size = 0.25
    elsif lat_lng_range_avg > (griddiness*2)
      grid_size = 0.125
    elsif lat_lng_range_avg > (griddiness*1)
      grid_size = 0.0625
=begin
    elsif lat_lng_range_avg > (griddiness*0.5)
      grid_size = nil
    elsif lat_lng_range_avg > (griddiness*0.25)
      grid_size = nil
    elsif lat_lng_range_avg > (griddiness*0.125)
      grid_size = nil
    elsif lat_lng_range_avg > (griddiness*0.05)
      grid_size = nil
=end
    end

    grid_size

  end


  # Use the ST_SnapToGrid PostGIS function to cluster the mappables.
  #
  # +options+ include:
  #
  # [+:grid_size+] a Float representing the size of the
  #                clusters (lat/lng degrees decimal)
  # [+:bbox+]      a String representing a bbox "#{w}, #{s}, #{e}, #{n}".
  #                Will be used to calculate a +grid_size+ if no +grid_size+
  #                option is provided.
  #
  # If grid_size is determined to be nil, clusters will simply be the result of a group by geometry.
  # i.e. Clusters of exact geometries (e.g. the same point)
  #
  # Returns an ActiveRecord::Relation which when executed will result in
  # rows. Each row will have the following instance variables:
  #
  # [+cluster_geometry_count+] the number of geometries in the cluster
  # [+cluster_centroid+] the middle point of the cluster
  #
  # The following is an example of the SQL that this will produce:
  #
  #   select
  #     count(geometry) as cluster_geometry_count,
  #     ST_AsText(ST_Centroid(ST_Collect( geometry ))) AS cluster_centroid
  #   from "mappables"
  #   group by
  #     ST_SnapToGrid(geometry, :grid_size)
  #   ;

  def self.cluster options
    grid_size = options[:grid_size]
    bbox      = options[:bbox]

    if grid_size.nil?
      grid_size = get_cluster_grid_size(bbox)
    end

    if grid_size.nil?
      select{count(geometry).as("cluster_geometry_count")}.
      select{st_astext(geometry).as("cluster_centroid")}.
      group{geometry}
    else
      select{count(geometry).as("cluster_geometry_count")}.
      select{st_astext(st_centroid(st_collect(geometry))).as("cluster_centroid")}.
#      select{st_astext(st_minimumboundingcircle(st_collect(geometry))).as("geometry_minimum_bounding_circle")}.
      group{st_snaptogrid(geometry, grid_size)}
    end

  end
end
