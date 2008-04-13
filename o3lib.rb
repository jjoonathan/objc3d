OSX.require_framework 'ObjC3D' unless @ObjC3D_loaded
include OSX unless @ObjC3D_loaded
@ObjC3D_loaded = 1

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
module O3
  RIGHT=[1,0,0]
  LEFT=[-1,0,0]
  UP=[0,1,0]
  DOWN=[0,-1,0]
  FORWARD=[0,0,-1]
  BACKWARD=[0,0,1]
end

vec_regex = /O3Vec(\d)([rfd])/
vec_defs = lambda { |c,count,type_chr|
  c.class_eval do
	  @count = count
	  @type_chr = type_chr
	  class << self
	    attr_accessor :count, :type_chr
    end

		def count
			self.class.count
		end
		
		def cols
		  self.class.count
    end
    
    def rows
      1
    end
    
		def ele_type_chr
			self.class.type_chr
		end

		def to_a
		  self.v
	  end

  	def to_s
  	  "["+self.to_a.join(", ")+"]"
    end

    def [](idx)
      self.v[idx]
    end

    def to_a
      self.v
    end
	end

  Array.class_eval do
      mname = ("to_"+c.name[7..-1]).downcase.intern
      define_method(mname) do
        raise ArgumentError, "Given array with expected bounds #{count} but got #{self.size} instead", caller if count!=self.size
        c.new(self)
      end
    end
}

###### Add O3Rotation3 methods to Array
Array.class_eval do
  def dot(other)
    raise ArgumentError, "Dimensions must match for dot product", caller if other.size!=arr.size
    accum=0.0
    arr.size.times{|x| accum += arr[x]*other[x]}
    accum
  end
  
  def to_rot
    arr=self.flatten
    if arr.size==3 then
      half_x=arr[0]*0.5
      half_y=arr[1]*0.5
      half_z=arr[2]*0.5
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
    elsif arr.size==4 #[axis x, axis y, axis z, theta]
      nf = arr[0]**2 + arr[1]**2 + arr[2]**2
      arr[0] /= nf
      arr[1] /= nf
      arr[2] /= nf
      ht = arr[3] * 0.5;
    	sht = Math.sin(ht);
    	return O3Rotation3.new([[arr[0]*sht, arr[1]*sht, arr[2]*sht, Math.cos(ht)]])
    end
    nil
  end
end


###### Add O3Matrix methods
mat_regex = /O3Mat(\d)x(\d)([rfd])/
ObjectSpace.each_object(Class) {|c|
	if c.name =~ mat_regex then
		c.class_eval do
		  @rows = $1.to_i
		  @cols = $2.to_i
		  @ele_type_chr = $3
		  class << self
		    attr_accessor :rows, :cols, :ele_type_chr
	    end
	    
	    public
  		def rows
				self.class.rows
			end

			def cols
				self.class.cols
			end

			def ele_type_chr
				self.class.ele_type_chr
			end
			
			def [](i,j)
			  raile ArgumentError,"Out of bounds access of #{i},#{j} for #{rows}x#{cols} matrix",caller if i<0 || i>rows || j<0 || j>cols
        self.v[i*self.cols+j]
      end
      
      def []=(i,j,v)
			  raile ArgumentError,"Out of bounds access of #{i},#{j} for #{rows}x#{cols} matrix",caller if i<0 || i>rows || j<0 || j>cols
        self.v[i*self.cols+j]=v
      end

      def row(r)
        Array.new(self.cols) {|i| self[r,i]}
      end

      def col(c)
        Array.new(self.rows) {|i| self[i,c]}
      end
      
      def *(om)
        raise ArgumentError,"Can only multiply square matricies of the same size for now",caller unless om.rows==self.rows && om.cols==self.cols
        ret=self.class.new
        self.rows.times {|r|
          row=self.row(r)
          self.cols.times {|c|
            ret[r,c] = row.dot(om.col(c))
          }
        }
        ret
      end

      def to_s
        self.rows.times {|r|
          puts "["+self.row(r).join(', ')+"]"
        }
      end

      def inspect
        str=""
        self.rows.times {|r|
          slice_start = r*self.cols
          slice_end = slice_start + self.cols
          slice_range = slice_start...slice_end
          slice_arr = v.slice(slice_range)
          str+=(slice_arr.inspect||"")+"\n"
        }
        str
      end
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
  
  def roll
    euler_angles[0]
  end
  
  def pitch
    euler_angles[1]
  end
  
  def yaw
    euler_angles[2]
  end
  
  def to_s
    e = euler_angles
    "<O3Rotation3>{roll:#{roll} pitch:#{pitch} yaw:#{yaw}}"
  end
end

##############Convenience index array converter
class Array
    def to_idxs
      arr = O3StructArray.alloc.initWithTypeNamed('ui64')
      arr.addObjects self
      arr.compressIntegerType
      arr
  end
end


##########Perform vec defs
vec_defs.call O3Translation3,3,"d"
vec_defs.call O3Translation2,2,"d"
vec_defs.call O3Scale3,3,"d"
vec_defs.call O3Scale2,2,"d"

ObjectSpace.each_object(Class) {|c|
	if c.name =~ vec_regex then
	  vec_defs.call c,$1.to_i,$2
	end
}

#############GUI convenience
def O3WrapInScrollview(content) #Lifted from console.rb
  scrollview = OSX::NSScrollView.alloc.initWithFrame(content.frame)
  clipview = OSX::NSClipView.alloc.initWithFrame(scrollview.frame)
  scrollview.contentView = clipview
  scrollview.documentView = clipview.documentView = content
  content.frame = clipview.frame
  scrollview.hasVerticalScroller = scrollview.hasHorizontalScroller = 
    scrollview.autohidesScrollers = true
  resizingMask = OSX::NSViewWidthSizable + OSX::NSViewHeightSizable
  content.autoresizingMask = clipview.autoresizingMask = 
    scrollview.autoresizingMask = resizingMask
  scrollview
end

def O3MakeTextWindow()
  w=NSWindow.alloc.initWithContentRect_styleMask_backing_defer_(NSRect.new(0,0,500,500),NSTitledWindowMask+NSClosableWindowMask+NSMiniaturizableWindowMask+NSResizableWindowMask, NSBackingStoreBuffered, false)
  tv=NSTextView.alloc.initWithFrame(NSRect.new(0,0,500,500))
  tv.setAutoresizingMask(NSViewWidthSizable)
  sv=O3WrapInScrollview(tv)
  w.contentView.addSubview(sv)
  w.makeKeyAndOrderFront(1)
  return w,tv
end