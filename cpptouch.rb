#!/usr/bin/env ruby
rfd = {'r' => "real", 'f' => "float", 'd' => "double"}
contents = IO.read(ARGV[0])
contents.gsub!(/_O3Vec(\d+)([rfd])/) {|m| "O3Vec&lt;"+rfd[$2]+","+$1.to_s+"&gt;"}
contents.gsub!(/_O3Mat(\d+)x(\d+)([rfd])/) {|m| "O3Mat&lt;"+rfd[$3]+","+$1.to_s+","+$2.to_s+"&gt;"}
puts contents