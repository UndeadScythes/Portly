# Add all our sub folders to the Ruby load path.
Dir.foreach(".") do |entry|
    if File.directory?(entry)
    
        # Ignore "." and "..".
        if not entry[/^\.{1,2}$/]
            $LOAD_PATH << entry
        end
    end
end

require "optparse"
require "ConfigManager"

parser = OptionParser.new do |options|
    options.banner = "Usage: portly.rb [options]"
    options.on("-r", "--root [ROOT_PATH]", "Specify the root directory") do |value|
        ConfigManager.set_portly_root(value)
    end
    options.on("-c", "--config [CONFIG_PATH]", "Specify a config file") do |value|
        ConfigManager.add_config_file(value)
    end
end

parser.parse!

ConfigManager.read_config_files()

require "LogManager"
require "logger"

logger = LogManager.get_logger("PortlyRoot", Logger::INFO)

logger.info("Creating listeners")

require "HttpListener"

http = Thread.new { HttpListener.new(80).listen }

http.join