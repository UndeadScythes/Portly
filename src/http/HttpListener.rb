# Include socket classes and our client service and crypto class.
require "socket"
require "ClientService"
require "Crypto"

# =====================================================================
# This class listens for and handles incoming TCP/IP connections.
# Each connection is handed to a new client service class for response.
# =====================================================================
class HttpListener

    @@LOGGER = LogManager.get_logger("HTTPListener")

    # ----------------------
    # Initialise this class.
    # ----------------------
    def initialize(port, hostname = "localhost")
        
        @server = TCPServer.new(hostname, port)
        
        @connected_clients = {}

        @@LOGGER.info("Server created on port #{port}")
        
    end

    # ----------------------------------------------
    # This method contains the infinite listen loop.
    # ----------------------------------------------
    def listen
    
        loop do
        
            client = @server.accept
            
            @@LOGGER.debug("=" * 80)
            @@LOGGER.info("Connection received from #{client.peeraddr()}")
            
            client_service = ClientService.new(client, self)
            
            unique_id = Crypto.get_unique_id()
            @connected_clients[unique_id] = client_service
            
        end
    
    end
    
end