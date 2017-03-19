# Include the exception classes for the HTTP errors.
require "HttpClientError"
require "HttpConnectionClosed"

# =======================================================================================
# This class allows us to perform operations with various parts of HTTP request messages.
# =======================================================================================
class Http

    # -----------------------------
    # Parse a HTTP message request.
    # -----------------------------
    def self.parse_http_message(client)
        
        puts("Starting HTTP message parsing")
        
        request_line = client.gets

        if request_line == nil
            raise HttpConnectionClosed.new
        end
        
        puts("Request line was #{request_line}")
            
        method, request_target, http_version = request_line.split(" ", 3)
        
        # This HTTP version number format is as specified in RFC7230 Section 2.6.
        if (http_version_number = http_version[/HTTP\/(\d\.\d)/, 1]) == nil
            raise HttpClientError.new(400, "Bad HTTP version in request line")
        end
        
        puts("Start line received: #{request_line}")
        
        header_fields = {}
        while line = client.gets do
            if line.eql?("\r\n") 
                break
            end
            
            puts("Header line received: #{line}")
            
            field_name, field_value = self.parse_header_field(line)
            
            if header_fields.has_key?(field_name)
                
                # According to RFC7230 Section 5.4 no request message should have more than one header field.
                if field_name.eql?("host")
                    raise HttpClientError.new(400, "Too many host header fields")
                end
                
                if header_fields[field_name].respond_to?(:push)
                    header_fields[field_name] << field_value
                else
                    header_fields[field_name] = [header_fields[field_name]]
                end
                
            else
            
                header_fields[field_name] = field_value
                
            end
        end
        
        # According to RFC7230 Section 5.4 all HTTP/1.1 requests must include a host header field.
        if http_version_number == "1.1"
            puts("Checking for host header field")
            if not header_fields.has_key?("host")
                raise HttpClientError.new(400, "No host header field")
            end            
        end
        
        # According to RFC7230 Section 3.2.2 a Content-Length header field should not be present if there is a Transfer-Encoding header field.
        if header_fields.has_key?("content-length") and header_fields.has_key?("transfer-encoding")
            raise HttpClientError.new(400, "Content-Length not allowed if Transfer-Encoding is set")
        end
        
        # According to RCF7230 Section 3.3 the presence of Content-Length or Transfer-Encoding signal the presence of a message body.
        puts("Determine if we have a message body")
        if header_fields.has_key?("content-length") or header_fields.has_key?("transfer-encoding")
        
            if header_fields.has_key?("content-length")
                content_length = header_fields["content-length"]
                
                # According to RFC7230 Section 3.3.2 we must try to parse mutliple Content-Length headers fields.
                content_length = self.get_unique_or_nil(content_length)
                    
            end
        
            puts("Message body beginning")
            
            message_body = []
            while line = client.gets do
                message_body << line
                
                puts("Received #{line}")
                
            end
            message_body = message_body.join("\r\n")

        end
            
        puts("End of HTTP message")
        
        return request_line, header_fields, message_body
        
    end

    # ---------------------
    # Parse a field header.
    # ---------------------
    def self.parse_header_field(header_field)
        
        field_name, field_value = header_field.split(":", 2)
        
        field_name.downcase!
        field_value.strip!
        
        return field_name, field_value
        
    end
    
    # ------------------------------------------------------------------------------------
    # Parse header fields and find a unique value, if one cannot be found then return nil.
    # ------------------------------------------------------------------------------------
    def self.get_unique_or_nil(header_fields)
        
        # If we were given something array like then re-parse each individual entry.
        if header_fields.respond_to?(:uniq)
            header_field_array = []
            header_fields.uniq.each do |header_field|
                header_field_array << self.get_unique_or_nul(header_field)
            end
            header_fields = header_field_array
        end
        
        # If we were given something string like then split on "," and trim the entries to get an array.
        if header_fields.respond_to?(:split)
            header_field_array = []
            header_fields.split(",").each do |header_field|
                header_field_array << header_field.strip
            end
        end
        
        # If we have only one unique value remaining then return it.
        return (header_field_array.uniq.length > 1) ? nil : header_field_array[0]
        
    end

end