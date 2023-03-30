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

enabled_cmd = cmd + "systemctl is-enabled uyuni-setup"
failed_cmd = cmd + "systemctl is-failed uyuni-setup"

while True:
    enabled_process = subprocess.run(enabled_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if enabled_process.returncode == 1 and b"Failed to connect to bus" not in enabled_process.stdout:
        break

    failed_process = subprocess.run(failed_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if failed_process.returncode == 0:
        print("Failed")
        sys.exit(1)

    print("... not finished yet...")
    time.sleep(10)

print("Done.")
