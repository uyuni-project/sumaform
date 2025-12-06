import http.server
import ssl
import socketserver
import os

# Define the port and the certificate file paths
PORT = 443
CERT_FILE = "/etc/apache2/ssl.crt/selfsigned.crt"
KEY_FILE = "/etc/apache2/ssl.key/selfsigned.key"
DIRECTORY = "/root/spacewalk/testsuite" # Use the original working directory

# Change the current working directory to the target directory
os.chdir(DIRECTORY)

# Configure the HTTP Request Handler
Handler = http.server.SimpleHTTPRequestHandler

# Set up the SSL context
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
try:
    context.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE)
except FileNotFoundError:
    print("Error: SSL certificate files not found. Ensure selfsigned.crt and selfsigned.key exist.")
    exit(1)

# Start the server
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
    print(f"Serving securely on https://0.0.0.0:{PORT} from {DIRECTORY}")
    httpd.serve_forever()
