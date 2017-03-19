# Get the YAML parser.
require "yaml"

# ===============================
# Handle the main configurations.
# ===============================
class ConfigManager
    
    @@CONFIG = {}
    
    @@CONFIG_FILES = []
    
    def self.load_file(file_path)
        file_contents = File.read(file_path)
        puts(YAML.load(file_contents))
        
    end
    
    def self.read_config_files()
        @@CONFIG_FILES.each do |config_file|
            self.load_file(config_file)
        end
    end
    
    def self.set_portly_root(file_path)
        @@CONFIG[:portly_root] = file_path.gsub(/\\/, "/")
    end
    
    def self.add_config_file(file_path)
        if not @@CONFIG_FILES.include?(file_path)
            @@CONFIG_FILES << file_path
        end
    end
    
end