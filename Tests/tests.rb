require 'test/unit'
require 'osx/cocoa'
OSX.require_framework Dir.pwd+'/build/ObjC3D.framework'
@ObjC3D_loaded = 1
include OSX

rseed=rand(2**32-1)
srand rseed
puts "Random seed: #{srand.to_s}"
require 'Tests/test_struct_array'