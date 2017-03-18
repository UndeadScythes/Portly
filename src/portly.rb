Dir.foreach(".") do |entry|
    puts("adding #{entry} to the load path")
    $LOAD_PATH << entry
end

require "HttpListener"

http = HttpListener.new(80)

http.wait