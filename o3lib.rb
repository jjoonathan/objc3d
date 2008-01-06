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
vec_regex = /O3Vec(\d)([rfd])/
vec_defs = lambda { |c,count,type_chr|
  c.class_eval do
	  @@mCount = count
	  @@mEleTypeChr = type_chr

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
	  "["+self.to_a.join(", ")+"]"
  end
  
  public
  def [](idx)
    self.v[idx]
  end

  def to_a
    self.v
  end

  Array.class_eval do
      mname = ("to_"+c.name[7..-1]).downcase.intern
      define_method(mname) do
        c.new(self)
      end
    end
}

###### Add O3Rotation3 methods to Array
Array.class_eval do
  def to_rot
    if self.size==3 then
      half_x=self[0]*0.5
      half_y=self[1]*0.5
      half_z=self[2]*0.5
      c1 = Math.cos(half_y);
      s1 = Math.sin(half_y);
      c2 = Math.cos(half_z);
      s2 = Math.sin(half_z);
      c3 = Math.cos(half_x);
      s3 = Math.sin(half_x);
      c1c2 = c1*c2;
      s1s2 = s1*s2;
      x = c1c2*s3  + s1s2*c3;
      y = s1*c2*c3 + c1*s2*s3;
      z = c1*s2*c3 - s1*c2*s3;
      w = c1c2*c3  - s1s2*s3;
      return O3Rotation3.new([[x,y,z,w]])
    elsif self.size==4 #[axis x, axis y, axis z, theta]
      nf = self[0]**2 + self[1]**2 + self[2]**2
      self[0] /= nf
      self[1] /= nf
      self[2] /= nf
      ht = self[3] * 0.5;
    	sht = Math.sin(ht);
    	return O3Rotation3.new([[self[0]*sht, self[1]*sht, self[2]*sht, cos(ht)]])
    end
    nil
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

########## Define O3Rotation3 methods
class O3Rotation3
  include Math
  def euler_angles
    qx=q.v[0]
    qy=q.v[1]
    qz=q.v[2]
    qw=q.v[3]
  	qzqz2 = 2*qz*qz
  	qxqy2_qzqw2 = 2.0 * (qx*qy + qz*qw)
  	z = Math.asin(qxqy2_qzqw2)
  	if (qxqy2_qzqw2-1.0).abs < 00001 then
  		y = 2*Math.atan2(qx,qw)
  		x = 0.0
  		return x,y,z
  	end
  	if (qxqy2_qzqw2+1.0).abs < 00001 then
  		y = -2*atan2(qx,qw)
  		x = 0.0
  		return x,y,z
  	end
  	x = atan2(2.0*(qx*qw-qy*qz) , 1.0 - 2.0*qx*qx - qzqz2)
  	y = atan2(2.0*(qy*qw-qx*qz) , 1.0 - 2.0*qy*qy - qzqz2)
  	return x,y,z
  end
  
  def to_s
    e = euler_angles
    "<O3Rotation3>{roll:"+e[0].to_s+", pitch:"+e[1].to_s+", yaw:"+e[2].to_s+"}"
  end
end

##########Perform vec defs
#vec_defs.call O3Translation3,3,"d"
#vec_defs.call O3Translation2,2,"d"
#vec_defs.call O3Scale3,3,"d"
#vec_defs.call O3Scale2,2,"d"

ObjectSpace.each_object(Class) {|c|
	if c.name =~ vec_regex then
	  vec_defs.call c,$1.to_i,$2
	end
}