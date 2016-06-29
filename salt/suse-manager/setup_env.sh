MANAGER_USER="spacewalk"
MANAGER_PASS="spacewalk"
MANAGER_ADMIN_EMAIL="galaxy-noise@suse.de"
CERT_O="Novell"
CERT_OU="SUSE"
CERT_CITY="Nuernberg"
CERT_STATE="Bayern"
CERT_COUNTRY="DE"
CERT_EMAIL="galaxy-noise@suse.de"
CERT_PASS="spacewalk"
USE_EXISTING_CERTS="N"
{% if grains['database'] == 'pgpool' %}
LOCAL_DB=0
{% endif %}
MANAGER_DB_NAME="susemanager"
MANAGER_DB_HOST="localhost"
MANAGER_DB_PORT="5432"
MANAGER_DB_PROTOCOL="TCP"
MANAGER_ENABLE_TFTP="Y"
{% if '2.1' in grains['version'] %}
NCC_USER="UC7"
NCC_PASS="***REMOVED***"
NCC_EMAIL="mc@suse.com"
{% else %}
SCC_USER="UC7"
SCC_PASS="***REMOVED***"
{% endif %}
