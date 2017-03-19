# Include out HTTP helper class.
require "Http"

# ==================================================
# This class serves a client based on their request.
# ==================================================
class ClientService

    @@LOGGER = LogManager.get_logger("ClientService")
    
    # ----------------------------
    # Create a new client service.
    # ----------------------------
    def initialize(client, server)
    
        @client = client
        @server = server
        
        serve_client()
        
    end
    
    # ---------------------------------------------
    # Read the clients request and send a response.
    # ---------------------------------------------
    def serve_client()

        begin
            start_line, header_fields, message_body = Http.parse_http_message(@client)
        
            @@LOGGER.debug("Serving hard coded response")
        
            @client.puts("HTTP/1.1 200 OK\r\n\r\nPortly WebServer\r\n")
        
            @client.close()
            
        rescue HttpClientError => error
        
            @@LOGGER.info("Client error raised: [#{error.error_code}] #{error}")
            
            @client.puts("HTTP/1.1 #{error.error_code} #{error}\r\n\r\n")
            
            @client.close()
        
        rescue HttpConnectionClosed => error
        
            @@LOGGER.info("Connection was closed by client")
        
        end
        
    end
    
end