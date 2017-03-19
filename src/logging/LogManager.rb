# Import the native logger and our log IO class.
require "logger"
require "LogOutput"

# ==============================
# Handle various system logging.
# ==============================
class LogManager

    @@LOGGERS = {}
    
    @@DEFAULT_LOG_LEVEL = Logger::INFO
    
    # -------------------------------
    # Get a logger by its identifier.
    # -------------------------------
    def self.get_logger(log_id, log_level = @@DEFAULT_LOG_LEVEL)
        
        if @@LOGGERS.has_key?(log_id)
            logger = @@LOGGERS[log_id]
        else
        
            logger = Logger.new(LogOutput.new(log_id))
            
            logger.formatter = proc do |severity, datetime, progname, message|
                formatted_datetime = datetime.strftime("%Y/%m/%d %H:%M:%S")
                "#{formatted_datetime} [#{log_id}|#{severity}] #{message}\n"
            end
            
            logger.level = log_level
            
            logger.debug("New logger created")
            
        end
        
        return logger
        
    end

end