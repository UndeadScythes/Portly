import unittest, subprocess, os, urllib.request, time

class TestHttpResponse(unittest.TestCase):

    def setUp(self):
        testing_directory = os.getcwd()
        os.chdir("..")
        print("Starting up a Portly WebServer and waiting 5 seconds")
        self.portly_server = subprocess.Popen("portly.bat")
        time.sleep(5)
        os.chdir(testing_directory)
        
    def tearDown(self):
        while self.portly_server.poll() == None:
            print("Trying to kill the Portly WebServer")
            self.portly_server.kill()
            time.sleep(1)
        
    def test_200(self):
        response = urllib.request.urlopen("http://localhost").read()
        self.assertEqual(response, b"Portly WebServer\r\n")
        
unittest.main()