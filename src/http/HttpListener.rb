require "socket"
require "ClientService"

class HttpListener

    def initialize(port, hostname = "localhost")
        
        @server = TCPServer.new(hostname, port)
        
        @connected_clients = []

        puts("Server created on port #{port}")
        
        puts("Starting new thread")
        
        @thread = Thread.new { listen }
        
    end
    
    def listen
    
        loop do
        
            client = @server.accept
            
            puts("=" * 80)
            puts("Connection received from #{client.peeraddr(true)}")
            
            client_service = ClientService.new(client, self)
            @connected_clients << client_service
            
            puts("Client being served")
        
        end
    
    end
    
    def wait
        @thread.join
    end

end