#!/usr/bin/env ruby -w
require 'FileUtils'

if ARGV[0].nil?
  puts "You must pass a revision range ie: 1556:1557 or 1556:HEAD"
else
  diff_out = %x{svn diff --summarize -r #{ARGV[0]}}
  
  if diff_out.length > 0
    store_in = ARGV[0].split(':').join('_')
    
    FileUtils.mkdir_p store_in
  
    diff_out.each_line do |line|

      if line[0,1] != 'D'  
        file_path = line.gsub(/[AM]+\s+/, '').strip
        puts "Copying #{file_path}"
        src =  "#{File.expand_path('.')}/#{file_path}"
        dest = "#{File.expand_path('.')}/#{store_in}/#{file_path}"
        FileUtils.mkdir_p(File.dirname(dest))
        if File.file?(src)
          FileUtils.copy_file src, dest
        end
      end
    end
  
    #zip up the files
    %x{zip -r #{store_in}.zip #{store_in}}
  
    #remove the old directory
    FileUtils.rm_r "#{store_in}"
  else
    puts 'No changes to export in this directory. Move to the root of your branch/trunk and try again.'
  end
  
end
