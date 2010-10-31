module DownloadsHelper
  
  def list_downloads
    html = list_directory(RAILS_ROOT + "/public/assets/documents/","Statistiken")
    return html
  end
  
  def list_directory(path,title = nil)
    dir = Dir.entries(path) - [".", "..",".DS_STORE",".DS_Store"]
    dir.sort!
    html = ""
    
    # List subdirectories
    dir.each { |entry|                                                           
      if File.directory?(path + entry)
        html += list_directory(path + entry + "/",entry)
      end
    }

    # List files
    if dir.size > 0 && has_files?(path)
      html += "<div class='content-box large'>"
      html += "<h5>#{title[3..title.length]}</h5>" unless title.nil?
      html += "<ul class='filelist'>"
      
      dir.each { |entry|
       if !File.directory?(path + entry)
         filename = File.basename(path+entry,"." + entry.gsub(/.*\./,""))
         filename = filename.gsub("_"," ")
         relative_path = path.gsub(RAILS_ROOT + "/public","")
         html += "<li><a href='#{relative_path}#{entry}'>#{filename}</a></li>"
       end
      }
      html += "</ul></div>"
    end
    
    html
  end
  
  def has_files?(path)
    files = 0
    dir = Dir.entries(path) - [".", "..",".DS_STORE",".DS_Store"]
    dir.each { |entry| 
      if !File.directory?(path + entry)
        files += 1
      end
    }
    
    files > 0
  end
  
end
