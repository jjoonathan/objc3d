require 'o3lib.rb'
require 'test/unit'

class TestStructArray < Test::Unit::TestCase
	def test_add_float
		eps = 1.0e-5
		aa = Array.new()
		a=O3StructArray.alloc.initWithTypeNamed 'f'
		assert(a,'Didn\'t init struct array')
		500.times{r = rand; a.addObject r; aa<<r;}
		500.times{|i| assert((a[i].to_f-aa[i]).abs<eps, 'Invalid storage.1!')}
	  #puts "Passed float tst"
	end
	
	def test_add_double
		eps = 1.0e-5
		aa = Array.new()
		a=O3StructArray.alloc.initWithTypeNamed 'd'
		assert(a,'Didn\'t init struct array')
		500.times{r = rand; a.addObject r; aa<<r;}
		500.times{|i| assert((a[i].to_f-aa[i]).abs<eps, 'Invalid storage.2!')}
	end
	
	def test_int_conv
		aa = Array.new()
		a=O3StructArray.alloc.initWithTypeNamed 'f'
		assert(a,'Didn\'t init struct array')
		500.times{r = rand*1000; a.addObject r; aa<< r.to_i;}
		a.setStructTypeName 'i32'
		500.times{|i| assert((a[i].to_i-aa[i]).abs<2, 'Invalid storage.3! '+a[i].to_s+"!="+aa[i].to_s)}
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
	  b=a.copy
	  a.setStructTypeName'd'
	  (ct*3).times {|i| assert((aa[i].to_f-a[i].to_f).abs<0.001, 'Didn\'t flatten correctly')}
	  a.setStructTypeName'vec3r'
	  ct.times {|i|
	    v1=a[i]
	    v2=b[i]
	    3.times {|i| assert((v1[i].to_f-v2[i].to_f).abs<0.001, 'Didn\'t unflatten correctly')}
	  }  
  end
  
  def sort_tst(ct)
	  a=O3StructArray.alloc.initWithTypeNamed'f'
	  aa=Array.new
	  ct.times {
      r=rand*1000
	    a.addObject r
	    aa<<r
	  }
	  aa.sort!
	  a.mergeSort
	  ct.times {|i| assert((a[i].to_f-aa[i]).abs<1e-2, 'Sort failed. idx='+i.to_s+' '+a[i].to_f.to_s + " !=  " + aa[i].to_s)}
  end
  
  def test_small_sort
 	 sort_tst 3
  end
  
  def test_med_sort
    sort_tst 18
  end
  
  def test_large_sort
    sort_tst 500
  end
  
  def arr_cmp_tst(arr,type)
    a = O3StructArray.alloc.initWithTypeNamed 'i64'
    a.addObjects arr
    #puts a.to_s+"l=#{a.lowestValue.to_i.to_s}, h=#{a.highestValue.to_i.to_s}"
    a.compressIntegerType
    assert(a.structType==type, "Type mismatch #{a.structType.to_s}!=#{type.to_s}, l=#{a.lowestValue.to_i.to_s}, h=#{a.highestValue.to_i.to_s} in "+a.to_s)
  end

  def test_int_comp
	  self.arr_cmp_tst([0,1,255], O3StructType.named('ui8'))
    self.arr_cmp_tst [256,128,64], O3StructType.named('ui16')
    self.arr_cmp_tst [65536,-1], O3StructType.named('i32')
    self.arr_cmp_tst [1,2,3,4,8589934592,1<<33], O3StructType.named('ui64')
  end
  
  def test_int64
    a = O3StructArray.alloc.initWithTypeNamed 'i64'
    a.addObjects [1,2,3,4,8589934592,1<<33]
    assert(a[5]==1<<33, 'Int64 storage failed')
  end
  
  def test_low_hi
    a=Array.new(25) {|x| (rand*(1<<35)).to_i}
    aa=O3StructArray.alloc.initWithTypeNamed 'i64'
    aa.addObjects a
    a.sort!
    assert(a[0]==aa.lowestValue, "Lowest value determination off. #{a[0]}!=#{aa.lowestValue}")
    assert(a[-1]==aa.highestValue, "Highest value determination off. #{a[-1]}!=#{aa.highestValue}")
  end
  
  def test_idx_compression
    ct=50
    a=Array.new(ct) {|i|rand(100)}
    ai=a.to_idxs
    assert(a==ai,'Int conv failed')
    b=ai.uniqueify
    bruby = a.sort.uniq
    assert(ai==bruby, "Uniqueification didn\'t catch right values. Was #{ai.join(', ')}, should have been #{bruby.to_a.join(', ')}")
    corridxs=Array.new(50) {|i| bruby.index(a[i])}
    assert(b==corridxs, "Uniqueification didn\'t get correct indexes: \n#{b.join(", ")}!=\n#{corridxs.to_a.join(", ")}")
  end
  
  def test_mat_struct_type
    assert(O3MatStructType.selfTest)
  end
  
  def test_vector_portabalization
    ct=rand(10)
	tnum=rand(20)
	type=rand(12)
	stype=rand(7)
	a=O3StructArray.alloc.initWithType(O3VecStructType.vecStructTypeWithElementType_specificType_count_name_comparator(type, stype, ct, 'test_vector_portabalization_type', nil)
	tnum.times {|t|
	  a.addObject(Array.new(ct) {|x|rand()*0xF000})
	}
	rdat=a.rawData
	pdat=a.portableData
	a.setPortableData(pdat)
	assert(rdat==a.rawData, "Vector portabalization died.")
  end
end
