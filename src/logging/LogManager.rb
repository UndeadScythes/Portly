# Import the native logger and our log IO class.
require "logger"
require "LogOutput"

# ==============================
# Handle various system logging.
# ==============================
class LogManager

    @@LOGGER_ID = "LogManager"

    @@LOGGER = Logger.new(LogOutput.new(@@LOGGER_ID))

    @@LOGGERS = {
        @@LOGGER_ID => @@LOGGER
    }
    
    @@DEFAULT_LOG_LEVEL = Logger::INFO
    
    @@current_log_level = @@DEFAULT_LOG_LEVEL
    
    # -------------------------------
    # Get a logger by its identifier.
    # -------------------------------
    def self.get_logger(log_id, log_level = @@current_log_level)
        
        # Check if we already have a logger by this name.
        if @@LOGGERS.has_key?(log_id)
            logger = @@LOGGERS[log_id]
            
        # If we don't then create one!
        else
        
            logger = Logger.new(LogOutput.new(log_id))
            
            logger.formatter = proc do |severity, datetime, progname, message|
                formatted_datetime = datetime.strftime("%Y/%m/%d %H:%M:%S")
                "#{formatted_datetime} [#{log_id}|#{severity}] #{message}\n"
            end
            
            logger.level = log_level
            
            @@LOGGERS[log_id] = logger
            
            logger.debug("New logger created")
            
        end
        
        return logger
        
    end
    
    # -----------------------------------------
    # Set the current log level on all loggers.
    # -----------------------------------------
    def self.set_log_level(log_level)
        
        @@LOGGER.debug("Updating all log levels to #{log_level}")
        @@current_log_level = log_level
        @@LOGGERS.each do |log_id, logger|
            @@LOGGER.debug("Updating #{log_id}")
            logger.level = log_level
        end
    end

end