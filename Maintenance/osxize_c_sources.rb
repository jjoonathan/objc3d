#!/usr/bin/env ruby
ARGV.each { |x|
  str=IO.read(x)
  if x.include?"Makefile" then
    str.gsub!(/-lGL\b/i,"-framework OpenGL")
    str.gsub!(/-lGLU\b/i,"")
    str.gsub!(/-lGLUT\b/i,"-framework GLUT")
  else
    str.gsub!(/#include\s+<GL\/glut.h>/i, '#include <GLUT/glut.h>')
    str.gsub!(/#include\s+<GL\/(\w+).h>/i, '#include <OpenGL/\1.h>')
  end
  f=File.new(x,"w")
  f.puts(str)
  f.close
}