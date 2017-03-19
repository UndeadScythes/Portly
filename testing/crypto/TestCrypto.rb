require "test/unit"
require_relative "../../src/crypto/Crypto"

class TestCrypto < Test::Unit::TestCase

    def test_unique_id()
        
        unique_ids = []
        while unique_ids.length < 10 do
            unique_ids << Crypto.get_unique_id()
        end
        
        assert_equal(1, unique_ids.uniq.length)
    end
    
end