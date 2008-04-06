require 'o3lib.rb'
require 'test/unit'

class TestStructArray < Test::Unit::TestCase
	def test_simple_case
		tdict = {'someDate'=>NSDate.date,
			'iNumber'=>5,
			'fNumber'=>1.203, 
			'bigNumber'=>0xFFFFFFFF, 
			'bigNegNumber'=>-0xFFFFFFFF, 
			'string'=>'TESTing StRiNg', 
			'anArray'=>[1,2,23,0xFFFFFFFF], 
		'complexArray'=>['str',1,NSDate.date]}
		tdat = O3KeyedArchiver.archivedDataWithRootObject(tdict)
		o=O3KeyedUnarchiver.unarchiveObjectWithData(tdat)
		assert(o.description==tdict.description, 'Unequal descriptions before and after archiving')
		end
	end
