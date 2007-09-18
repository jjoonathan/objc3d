#!/usr/bin/env ruby -wKU
require "pathname"

def main
  files = `find ../Engine ../Classes ../Math ../Tests ../Utilities -name *.h -or -name *.mm -or -name *.hpp`.split("\n")
  files += ["../main.m","../O3Accelerate.h","../O3Global.h","../ObjC3D_Prefix.pch","../ObjC3D.h"]
  files.collect {|p| Pathname.new(p)}
  files.each { |path|
    contents = IO.readlines(path)
    r, keys = old_header_range_and_keys(contents)
    toprint = File.basename(path)+": "
    keys||={}
    keys.delete("file")
    #keys["file"]=[File.basename(path)]
    keys["author"]||=["Jonathan deWerd"]
    keys["license"]||=["MIT License (see LICENSE.txt)"]
    if !keys["copyright"] || keys["copyright"].empty? || keys["copyright"][0]=~/__MyCompanyName__/ then
      keys["copyright"]=["Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt."]
    end
    keys["note"].reject! {|o| o=~/Copyright 2007/} if keys["note"]
    
    lines=[]
    lines<<"/**\n"
    lines<<" *  @file "+File.basename(path)+"\n"
    keys.each_pair {|k,val|
      val.each {|v|
        lines<<" *  @"+k+" "+v+"\n"
      }
    }
    lines<<" */\n"
    
    vrfy = nil
    if r then
      before = contents[0...r.first]
      during = contents[r.first...r.last]
      after = contents[(r.last)..(r.last+10)] || []
      vrfy = before+["===== New Header\n"]+lines+["===== Old Header\n"]+during+["=====\n"]+after
      contents = before+lines+contents[r.last,contents.length-r.last]
    else
      contents = lines+contents
    end

    if vrfy then
      puts "\n"*50
      puts vrfy.join("")
      puts "Carry out replacement (y/n)[n]? "
      a=STDIN.gets.strip
      if a=="y" || a=="" then
        f=File.new(path,"w")
        f.puts(contents.join)
        f.close
        puts "File modified"
      else
        puts "File not modified"
      end
    else
      f=File.new(path,"w")
      f.puts(contents.join)
      f.close
      puts "Adding header to: "+File.basename(path)
    end
  }
end

def old_header_range_and_keys(lines) #[range, keys] or nil
  startline = -1
  endline = -1
  keys = {}
  0.upto(3) {|i|
    line_regex = false
    line_regex = /^(\s*\/?\**\s*)(.*)/ if lines[i] =~ /^\/\*\*?/
    line_regex = /^(\/{2,}\s*)(.*)/    if lines[i] =~ /^\/{2,}/
    if line_regex then
      startline=i
      j=i
      loop {
        break unless lines[j]
        if lines[j]=~/^\s*\*\// then
          j+=1
          break
        end
        break unless lines[j]=~line_regex
        info = $2
        if info =~ /@(\w+)\s*(.*)/ then
          if   keys[$1] then keys[$1]<<$2
          else keys[$1] = [$2] end
        elsif info =~ /(\w+):\s*(.*)/ then
          if   keys[$1.downcase] then keys[$1.downcase]<<$2
          else keys[$1.downcase] = [$2] end
        elsif info =~ /\\(\w+)\s*(.*)/ then
          if   keys[$1] then keys[$1]<<$2
          else keys[$1] = [$2] end
        elsif info =~ /Created by ((\w+\s*)+) on ([^\s]+)/ then
          if   keys["author"] then keys["author"]<<$1
          else keys["author"] = [$1] end
          if   keys["date"] then keys["date"]<<$3
          else keys["date"] = [$3] end
        elsif info =~ /(Copyright .*)/ then
          if   keys["copyright"] then keys["copyright"]<<$1
          else keys["copyright"] = [$1] end
        elsif info =~ /(ObjC3D|\s*)/ then
        else
          if   keys["note"] then keys["description"]<<info
          else keys["note"] = [info] end          
        end
        j+=1
      }
      while (lines[j]||"oeui").strip==""
        j+=1
      end
      endline=j
      break  
    end
  }
  
  return [startline..endline, keys] if startline!=-1
  false
end

main