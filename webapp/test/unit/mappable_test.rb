require 'test_helper'

class MappableTest < ActiveSupport::TestCase

  def setup
    @sydney   = mappables(:sydney)
    @brisbane = mappables(:brisbane)
    @perth    = mappables(:perth)
    @adelaide = mappables(:adelaide)

#    Rails.logger.info("Brisbane x: #{@brisbane.geometry.x}, y: #{@brisbane.geometry.y}")
#    Rails.logger.info("Sydney x: #{@sydney.geometry.x}, y: #{@sydney.geometry.y}")
  end

  test "Brisbane is north of Sydney" do
    assert ( @brisbane.geometry.y > @sydney.geometry.y )
  end

  test "Clustering with a sufficiently large grid size reduces result count" do
    options = {}
    options[:grid_size] = 10.0
    results = Mappable.cluster(options)

    assert(
      ( results.length < Mappable.count ),
      "Clustering with a grid_size of 10.0 failed to result in a smaller set. " +
      "Clusters: #{results.length}. Mappables: #{Mappable.count}."
    )
  end

  test "Clustering with a sufficiently small grid size doesn't effect result count" do
    options = {}
    options[:grid_size] = 1.0
    results = Mappable.cluster(options)

    assert_equal(
      results.length,
      Mappable.count,
      "Clustering with a grid_size of 1.0 reduced the set size. This was unexpected. " +
      "If Mappable fixtures have been added that are closer than 1.0 degrees decimal, " +
      "then this test is no longed valid. Adjust the grid size for this test accordingly. " +
      "Clusters: #{results.length}. Mappables: #{Mappable.count}."
    )
  end

  test "Clustering produces rows with +cluster_geometry_count+ and +cluster_centroid+" do
    options = {}
    options[:grid_size] = 10.0
    results = Mappable.cluster(options)

    results.each do |el|
      assert(
        ( el.cluster_geometry_count.to_i > 0 ),
        "Clustering should have resulted in a cluster_geometry_count which is " +
        " a valid Integer greater than 0. Cluster geometry count " +
        "is: #{el.cluster_geometry_count.inspect}"
      )
      assert_not_nil(
        Mappable.rgeo_factory_for_column(:geometry).parse_wkt(el.cluster_centroid),
        "Clustering produced an invalud cluster_centroid. cluster_centroid isn't valid WKT"
      )
    end

  end

end
