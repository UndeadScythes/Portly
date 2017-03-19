# ===========================================================
# This class allows us to log messages to file and to STDOUT.
# ===========================================================
class LogOutput

    def initialize(log_id)
        @log_id = log_id
    end
    
    def write(*args)
        STDOUT.write(*args)
    end
    
    def close()
        
    end

end