# Get the YAML parser and our log manager.
require_external("yaml")
require "LogManager"

# ===============================
# Handle the main configurations.
# ===============================
class ConfigManager
    
    @@CONFIG = {}
    
    @@CONFIG_FILES = []
    
    @@LOGGER = LogManager.get_logger("ConfigManager")
    
    # --------------------------
    # Add a value to the config.
    # --------------------------
    def self.add_value(parent, new_value)
        
        @@LOGGER.debug("Adding new entry #{new_value}")
        if new_value.kind_of?(Hash)
            new_value.each do |key, value|
                if parent.has_key?(key)
                    @@LOGGER.debug("Replacing key #{key}: #{parent[key]} -> #{new_value}")
                end
                parent[key] = value
            end
        end
        
    end
    
    # ---------------------
    # Load one config file.
    # ---------------------
    def self.load_file(file_path)
    
        @@LOGGER.debug("Reading config file #{file_path}")
        yaml = YAML.load_file(file_path)
        @@LOGGER.debug("File contents: #{yaml.inspect}")
        self.add_value(@@CONFIG, yaml)
    end
    
    # -----------------------------------------------------------
    # Read and load from all the config files we have been given.
    # -----------------------------------------------------------
    def self.read_config_files()
    
        @@LOGGER.debug("Reading all config files")
        @@CONFIG_FILES.each do |config_file|
            self.load_file(config_file)
        end
    end
    
    def self.set_portly_root(file_path)
        @@CONFIG[:portly_root] = file_path.gsub(/\\/, "/")
    end
    
    def self.get_portly_root()
        return @@CONFIG[:portly_root]
    end

    def self.add_config_file(file_path)
        if not @@CONFIG_FILES.include?(file_path)
            @@CONFIG_FILES << file_path
        end
    end
    
    def self.get_value(key_string)
        key_parts = key_string.split(".")
        value = @@CONFIG
        key_parts.each do |key_part|
            if value.has_key?(key_part)
                value = value[key_part]
            else
                value = nil
                break
            end
        end
        return value
    end
    
    def self.get_file_path(key_string)
        file_path = self.get_value(key_string)
        if file_path != nil
            file_path.gsub!(/\\/, "/")
            file_path.gsub!(/%PORTLY%/, self.get_portly_root)
        end
        return file_path
    end
    
end