# Import a whole load of guff.
import unittest, subprocess, os, time, telnetlib, socket

# ----------------------------------------------
# Send a request to the test server over Telnet.
# ----------------------------------------------
def send_request(request):

    # If we have something like an array then join the elements with CRLFs.
    if hasattr(request, "__iter__"):
        request = "\r\n".join(request) + "\r\n\r\n"
        
    # Open the Telnet channel on port 80 with a 3 second timeout and send the request.
    telnet = telnetlib.Telnet("localhost", 80, 3)
    telnet.write(request.encode())
    
    # Read the response into a variable and catch any timeouts.
    try:
        response = telnet.read_all().decode()
    except socket.timeout as error:
        print("Telnet timed out")
        response = str(error)
        
    # Return the response split on CRLFs.
    return response.split("\r\n")

# ========================================================================================
# The main test case class in this file - we will be testing specific HTTP response codes.
# ========================================================================================
class TestHttpResponse(unittest.TestCase):

    # ----------------------------------------
    # Set up the test server before each test.
    # ----------------------------------------
    def setUp(self):
    
        # Store the current directory so we can switch back to it later.
        testing_directory = os.getcwd()
        
        # Jump up a level and fire up the Portly webserver.
        os.chdir("../src")
        print("\nStarting up a Portly WebServer and waiting 5 seconds")
        print("--------------------------------------------------------------------------------")
        self.portly_server = subprocess.Popen(["ruby", "portly.rb"])
        
        # Wait for the port to be open then return to the testing directory.
        time.sleep(5)
        os.chdir(testing_directory)
    
    # ------------------------------------------    
    # Shut the test server down after each test.
    # ------------------------------------------
    def tearDown(self):
    
        # Kill the server.
        print("--------------------------------------------------------------------------------")
        print("Trying to kill the Portly WebServer, waiting 5 seconds")
        while self.portly_server.poll() == None:
            self.portly_server.kill()
            
        # Wait for port 80 to die then wait for the server to close.
        time.sleep(5)
    
    # ----------------------------------------------
    # Test each of the supported 200 response codes.
    # ----------------------------------------------
    def test_200(self):
        response = send_request(["GET / HTTP/1.1", "Host: localhost"])
        self.assertEqual(response[0], "HTTP/1.1 200 OK")
    
    # ----------------------------------------------
    # Test each of the supported 400 response codes.
    # ----------------------------------------------
    def test_400(self):
        response = send_request(["GET / HTTPx1.1"])
        self.assertEqual("HTTP/1.1 400 Bad HTTP version in request line", response[0])
        
        response = send_request(["GET / HTTP/1.1", "Host: localhost", "Host: localhost"])
        self.assertEqual("HTTP/1.1 400 Too many host header fields", response[0])
        
        response = send_request(["GET / HTTP/1.1"])
        self.assertEqual("HTTP/1.1 400 No host header field", response[0])
        
        response = send_request(["GET / HTTP/1.1","Host: localhost","Content-Length: 0", "Transfer-Encoding: test"])
        self.assertEqual("HTTP/1.1 400 Content-Length not allowed if Transfer-Encoding is set", response[0])
        
# =================================================
# Run the unit tests with a little extra verbosity.
# =================================================
unittest.main(verbosity=2)