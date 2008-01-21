require 'test/unit'
require 'osx/cocoa'
OSX.require_framework Dir.pwd+'/build/ObjC3D.framework'
include OSX


class TestStructArray < Test::Unit::TestCase
	def test_add_float
		eps = 1.0e-5
		aa = Array.new()
		a=O3StructArray.alloc.initWithTypeNamed 'f'
		assert(a,'Didn\'t init struct array')
		500.times{r = rand; a.addObject r; aa<<r;}
		500.times{|i| assert((a[i].to_f-aa[i]).abs<eps, 'Invalid storage!')}
	end
	
	def test_add_double
		eps = 1.0e-5
		aa = Array.new()
		a=O3StructArray.alloc.initWithTypeNamed 'd'
		assert(a,'Didn\'t init struct array')
		500.times{r = rand; a.addObject r; aa<<r;}
		500.times{|i| assert((a[i].to_f-aa[i]).abs<eps, 'Invalid storage!')}
	end
	
	def test_int_conv
		aa = Array.new()
		a=O3StructArray.alloc.initWithTypeNamed 'f'
		assert(a,'Didn\'t init struct array')
		500.times{r = rand*1000; a.addObject r; aa<< r.to_i;}
		a.setStructTypeName 'i32'
		puts a
		500.times{|i| assert(a[i].to_i==aa[i], 'Invalid storage! '+a[i].to_s+"!="+aa[i].to_s)}
	end
	
	def test_vec_flattening
	  ct=20
	  a=O3StructArray.alloc.initWithTypeNamed'vec3r'
	  aa=Array.new
	  ct.times {
	    r1,r2,r3 = rand,rand,rand
	    a.addObject [r1,r2,r3]
	    aa<<r1<<r2<<r3
	  }
  end
end
