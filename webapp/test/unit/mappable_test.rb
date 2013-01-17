require 'test_helper'

class MappableTest < ActiveSupport::TestCase

  def setup
    @sydney = mappables(:sydney)
    @brisbane = mappables(:brisbane)

    Rails.logger.info("Brisbane x: #{@brisbane.geometry.x}, y: #{@brisbane.geometry.y}")
    Rails.logger.info("Sydney x: #{@sydney.geometry.x}, y: #{@sydney.geometry.y}")
  end

  test "Brisbane is north of Sydney" do
    assert ( @brisbane.geometry.y > @sydney.geometry.y )
  end

end
