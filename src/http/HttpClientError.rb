class HttpClientError < StandardError

    attr_reader :error_code

    def initialize(error_code, error_message)
        @error_code = error_code
        super(error_message)
    end
    
end