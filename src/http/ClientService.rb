require "Http"

class ClientService
    
    def initialize(client, server)
    
        @client = client
        @server = server
        
        puts("Starting thread to serve client")
        
        @thread = Thread.new { serve_client }
        
    end
    
    def serve_client

        begin
            start_line, header_fields, message_body = Http.parse_http_message(@client)
        
            puts("Serving hard coded response")
        
            @client.puts("HTTP/1.1 200 OK\r\n\r\nPortly WebServer\r\n")
        
            @client.close
            
        rescue HttpClientError => error
            
            @client.puts("HTTP/1.1 #{error.error_code} #{error}\r\n\r\n")
        
        rescue HttpConnectionClosed => error
        
            puts("Connection was closed by client")
        
        end
        
    end
    
end