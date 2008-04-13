#!/usr/bin/env ruby
rfd = {'r' => "real", 'f' => "float", 'd' => "double"}
contents = IO.read(ARGV[0])
contents.gsub!(/_O3Vec(\d+)([rfd])/) {|m| "O3Vec&lt;"+rfd[$2]+","+$1.to_s+"&gt;"}
contents.gsub!(/_O3Translation(\d+)([rfd])/) {|m| "O3Translation&lt;"+rfd[$2]+","+$1.to_s+"&gt;"}
contents.gsub!(/_O3Mat(\d+)x(\d+)([rfd])/) {|m| "O3Mat&lt;"+rfd[$3]+","+$1.to_s+","+$2.to_s+"&gt;"}
contents.gsub!(/_O3Quaternion/) {|m| "O3Quaternion"}
contents.gsub!(/'\{_O3Rotation3.*?'/, "'{O3Rotation3=&quot;q&quot;{O3Quaternion=&quot;v&quot;[4d]}}'")
#contents.gsub!("_O3Scale2", "O3Scale&lt;double,2&gt;")
#contents.gsub!("_O3Scale3", "O3Scale&lt;double,3&gt;")
#contents.gsub!("_O3Translation2", "O3Translation&lt;double,2&gt;")
#contents.gsub!("_O3Translation3", "O3Translation&lt;double,3&gt;")
puts contents