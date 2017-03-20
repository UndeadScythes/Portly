# ===========================================================
# This class allows us to log messages to file and to STDOUT.
# ===========================================================
class LogOutput

    @@log_directory = nil
    
    @@LOG_FILES = []

    def initialize(log_id)
        @log_id = log_id
    end
    
    def get_log_file()
        if @log_file == nil and @@log_directory != nil
            @log_file = File.open(File.join(@@log_directory,"#{@log_id}.log"), "a")
            @@LOG_FILES << @log_file
        end
        return @log_file
    end
    
    def write(*args)
        STDOUT.write(*args)
        log_file = get_log_file()
        if log_file != nil
            log_file.write(*args)
        end
    end
    
    def close()
        if @log_file != nil
            @log_file.close()
        end
    end
    
    def self.set_log_directory(log_directory)
        @@log_directory = log_directory
    end
    
    def self.close_all_log_files()
        @@LOG_FILES.each do |log_file|
            log_file.close()
            log_file = nil
        end
    end
    
end