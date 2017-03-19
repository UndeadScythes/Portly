# Add all oyr sub folders to the Ruby load path.
Dir.foreach(".") do |entry|
    if File.directory?(entry)
    
        # Ignore "." and "..".
        if not entry[/\.{1,2}/]
            $LOAD_PATH << entry
        end
    end
end

require "HttpListener"

http = Thread.new { HttpListener.new(80).listen }

http.join