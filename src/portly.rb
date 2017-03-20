# Add all our sub folders to the Ruby load path.
Dir.foreach(".") do |entry|
    if File.directory?(entry)
    
        # Ignore "." and "..".
        if not entry[/^\.{1,2}$/]
            $LOAD_PATH << entry
        end
    end
end

# Build a function to load external libraries.
def require_external(library)

    # Get the current debug level so we can set it back again afterwards.
    debug_level = $DEBUG
    $DEBUG = false
    require(library)
    $DEBUG = debug_level
end

# Include the config and log managers.
require "ConfigManager"
require "LogManager"
require_external("logger")

# Build and parse the command line options.
require_external("optparse")
parser = OptionParser.new do |options|

    # Set the default output.
    options.banner = "Usage: portly.rb [options]"

    # Check for the Portly root directory.
    options.on("-r", "--root [ROOT_PATH]", "Specify the root directory") do |value|
        ConfigManager.set_portly_root(value)
    end

    # Check for the main Portly config file.
    options.on("-c", "--config [CONFIG_PATH]", "Specify a config file") do |value|
        ConfigManager.add_config_file(value)
    end
    
    # Check for the debug level.
    options.on("-d", "--debug", "Turn on debugging") do |value|
        LogManager.set_log_level(Logger::DEBUG)
    end
end
parser.parse!

# Set a logger for the main webserver.
logger = LogManager.get_logger("PortlyRoot")

# Read any config files that were passed in.
logger.debug("Trying to read config files")
ConfigManager.read_config_files()

# Check if we got a log directory.
log_directory = ConfigManager.get_file_path("log_path")
if log_directory != nil
    LogOutput.set_log_directory(log_directory)
end

# Create listeners.
logger.info("Creating listeners")
require "HttpListener"
http = Thread.new { HttpListener.new(80).listen }

# Join all the listeners to stop the main process from closing early.
http.join()