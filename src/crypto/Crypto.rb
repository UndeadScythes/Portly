# Include the date class.
require "date"

# ========================================================
# This class will handle all of our cryptographic methods.
# ========================================================
class Crypto

    # ---------------------------------------------------
    # Get a new unique identifier based on the timestamp.
    # ---------------------------------------------------
    def self.get_unique_id()
        
        current_timestamp = DateTime.now.strftime("%Q").to_i(10).to_s(36)
        
        return current_timestamp
        
    end

end