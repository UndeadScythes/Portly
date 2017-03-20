require "test/unit"

require "LogManager"
require "LogOutput"
require "logger"

class TestLogger < Test::Unit::TestCase

    def test_log_levels()
        
    	LogOutput.set_log_directory(Dir.getwd())
        logger = LogManager.get_logger("test_logger", Logger::DEBUG)
        logger.fatal("fatal_test")
        logger.error("error_test")
        logger.warn("warn_test")
        logger.info("info_test")
        logger.debug("warning_test")

        LogOutput.close_all_log_files()
        
        log_output = File.read(File.join(Dir.getwd(), "test_logger.log"))

        assert(true, log_output[/\[test_logger|FATAL\] fatal_test/])
        assert(true, log_output[/\[test_logger|ERROR\] error_test/])
        assert(true, log_output[/\[test_logger|WARN\] warn_test/])
        assert(true, log_output[/\[test_logger|INFO\] info_test/])
        assert(true, log_output[/\[test_logger|FATAL\] debug_test/])
        
        File.delete(File.join(Dir.getwd(), "test_logger.log"))
        
    end
    
end