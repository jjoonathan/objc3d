require 'o3lib.rb'
require 'test/unit'

class TestSpace < Test::Unit::TestCase
  def test_transf
    a=O3TRSSpace.new
    b=O3TRSSpace.new
    c=O3TRSSpace.new
    a.moveTo_inPOVOf_([1,0,0].to_vec3d, nil)
    
    a.release
  end
end
