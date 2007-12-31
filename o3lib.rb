OSX.require_framework 'ObjC3D'
include OSX

def O3StructArray.facesFromRawFile(file)
	ret = O3StructArray.alloc.initWithTypeNamed 'tri3x3f'
	File.new(file).each_line { |l|
		f = []
		floats = l.scan(/([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)/).map{|x|x[0].to_f}
		ret.addStruct floats.pack('fffffffff')
	}
	ret
end

def class_named(name)
  Kernel.const_get(name)
end

###### Add O3Vector methods
mat_regex = /O3Vec(\d)([rfd])/
ObjectSpace.each_object(Class) {|c|
	if c.name =~ mat_regex then
		c.class_eval do
		  @@mCount = $1.to_i
		  @@mEleTypeChr = $2
		  
			def count
				@@mCount
			end
			
			def ele_type_chr
				@@mEleTypeChr
			end
			
			def to_a
			  self.v
		  end
		end
		
		def to_s
		  self.to_a.to_s
	  end
		
    Array.class_eval do
        define_method(("to_"+c.name[7..-1]).downcase.intern) do
          c.new(self)
        end
      end
	end
}

###### Add O3Rotation3 methods
def O3Rotation3
  def euler_angles
    qx=v[0]
    qy=v[1]
    qz=v[2]
    qw=v[3]
  	zz2 = 2*qz*qz
  	qxqy2_qzqw2 = 2.0 * (qx*qy + qz*qw)
  	z = asin(qxqy2_qzqw2)
  	if abs(qxqy2_qzqw2-1.0) < 00001 then
  		y = 2*atan2(qx,qw)
  		x = 0.0
  		return x,y,z
  	end
  	if abs(qxqy2_qzqw2+1.0) < 00001 then
  		y = -2*atan2(qx,qw)
  		x = 0.0
  		return x,y,z
  	end
  	x = atan2(2.0*(qx*qw-qy*qz) , 1.0 - 2.0*qx*qx - qzqz2)
  	y = atan2(2.0*(qy*qw-qx*qz) , 1.0 - 2.0*qy*qy - qzqz2)
  	return x,y,z
  end
end


###### Add O3Matrix methods
mat_regex = /O3Mat(\d)x(\d)([rfd])/
ObjectSpace.each_object(Class) {|c|
	if c.name =~ mat_regex then
		c.class_eval do
		  @@mRows = $1.to_i
		  @@mCols = $2.to_i
		  @@mEleTypeChr = $3
			def rows
				@@mRows
			end
			
			def cols
				@@mCols
			end
			
			def ele_type_chr
				@@mEleTypeChr
			end
		end
		
		def [](i,j)
      self.v[i+@@mRows*j]
    end
    
    def []=(i,j,val)
      self.v[i+@@mRows*j]=val
    end
    
    def row(r)
      Array.new(@@mCols) {|i| self[r,i]}
    end
    
    def col(c)
      Array.new(@@mRows) {|i| self[i,r]}
    end
    
    def to_s
      @@mRows.times {|r|
        puts "["+self.row(r).join(', ')+"]"
      }
    end
		
    Array.class_eval do
        define_method(("to_"+c.name[7..-1]).downcase.intern) do
          c.new(self)
        end
      end
	end
}
