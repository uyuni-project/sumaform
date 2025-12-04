import http.server
import ssl
import socketserver
import os

is_debian_family = False

# Check for the /etc/os-release file (standard across most modern Linux)
if os.path.exists("/etc/os-release"):
    try:
        # Read the file and parse it into a dictionary
        os_info = {}
        with open("/etc/os-release", "r") as f:
            for line in f:
                if "=" in line:
                    key, value = line.strip().split("=", 1)
                    # Remove quotes from the value
                    os_info[key] = value.strip('"')

        # Check for Debian or Ubuntu, or if the system is Debian-like
        system_id = os_info.get("ID", "").lower()
        id_like = os_info.get("ID_LIKE", "").lower()

        if system_id in ("debian", "ubuntu") or "debian" in id_like:
            is_debian_family = True

    except Exception as e:
        print(f"Warning: Could not read /etc/os-release. Falling back to defaults. Error: {e}")

PORT = 443
if is_debian_family:
    CERT_FILE = "/etc/ssl/certs/selfsigned.crt"
    KEY_FILE = "/etc/ssl/private/selfsigned.key"
    DIRECTORY = "/root/spacewalk/"
else:
    CERT_FILE = "/etc/apache2/ssl.crt/selfsigned.crt"
    KEY_FILE = "/etc/apache2/ssl.key/selfsigned.key"
    DIRECTORY = "/root/spacewalk/testsuite"

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
