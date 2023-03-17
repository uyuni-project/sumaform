#!{{grains['pythonexecutable']}}

import subprocess
import sys
import time


if len(sys.argv) != 2:
    print("Usage: wait_for_setup_end.py podman|k3s")

_, runtime = sys.argv

print("Waiting for setup to complete...")

cmd = ""
if runtime == "podman":
    cmd = "podman exec uyuni-server "
elif runtime == "k3s":
    cmd = "kubectl exec $(kubectl get pod -lapp=uyuni -o jsonpath={.items[0].metadata.name}) -- "

cmd += "systemctl is-enabled uyuni-setup"

while True:
    process = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    print("Run {}, return {}".format(cmd, process.returncode))
    if process.returncode == 1 and b"Failed to connect to bus" not in process.stdout:
        break

    print("... not finished yet...")
    time.sleep(10)

print("Done.")
