require "HttpClientError"

# RFC7230: Hypertext Transfer Protocol (HTTP/1.1): Message Syntax and Routing

class Http

    # Parse a HTTP message according to the format laid out in RFC7230 §3 'Message Format'.
    def self.parse_http_message(client)
        
        puts("Starting HTTP message parsing")
        
        start_line = client.gets
        
        puts("Start line received: #{start_line}")
        
        header_fields = {}
        while line = client.gets do
            if line.eql?("\r\n") 
                break
            end
            
            puts("Header line received: #{line}")
            
            field_name, field_value = self.parse_header_field(line)
            
            if header_fields.has_key?(field_name)
                
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
        
        puts("Checking for host header field")
        if not header_fields.has_key?("host")
            raise HttpClientError.new(400, "No host header field")
        end            

        
        puts("Determine if we have a message body")
        if header_fields.has_key?("content-length") or header_fields.has_key?("transfer-encoding")
        
            puts("Message body beginning")
            
            message_body = []
            while line = client.gets do
                message_body << line
                
                puts("Received #{line}")
                
            end
            message_body = message_body.join("\r\n")

        end
            
        puts("End of HTTP message")
        
        return start_line, header_fields, message_body
        
    end

    # Parse a field header according to the format laid out in RFC7230 §3.2 'Header Fields'.
    def self.parse_header_field(header_field)
        
        field_name, field_value = header_field.split(":", 2)
        
        field_name.downcase!
        field_value.strip!
        
        return field_name, field_value
        
    end

end