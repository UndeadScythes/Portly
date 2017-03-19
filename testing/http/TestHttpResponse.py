import unittest, subprocess, os, urllib.request, time, telnetlib, socket

def send_request(request):
    telnet = telnetlib.Telnet("localhost", 80, 3)
    telnet.write(request.encode())
    try:
        response = telnet.read_all().decode()
    except socket.timeout as error:
        response = error
    return response

def wait_for_port(alive=True, dead=True):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    while True:
        port_test = sock.connect_ex(("localhost", 80))
        if alive and port_test > 0:
            break;
        if dead and port_test == 0:
            break;
    sock.close()
    
class TestHttpResponse(unittest.TestCase):

    def setUp(self):
        testing_directory = os.getcwd()
        os.chdir("..")
        print("Starting up a Portly WebServer")
        print("--------------------------------------------------------------------------------")
        self.portly_server = subprocess.Popen("portly.bat")
        wait_for_port(alive=True)
        os.chdir(testing_directory)
        
    def tearDown(self):
        print("--------------------------------------------------------------------------------")
        print("Trying to kill the Portly WebServer")
        self.portly_server.terminate()
        wait_for_port(dead=True)
        self.portly_server.wait()
        
    def test_200(self):
        response = urllib.request.urlopen("http://localhost").read()
        self.assertEqual(response, b"Portly WebServer\r\n")
        
    def test_400(self):
        response = send_request("GET / HTTPx1.1\r\n")
        self.assertEqual(response, "HTTP/1.1 400 Bad HTTP version in request line\r\n")
        
unittest.main(verbosity=2)