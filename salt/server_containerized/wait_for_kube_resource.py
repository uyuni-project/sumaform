#!{{grains['pythonexecutable']}}

import subprocess
import sys
import time


if len(sys.argv) != 4:
    print("Usage: wait_for_kube_resource.py <namespace> <kind> <name>")

_, namespace, kind, name = sys.argv

print("Waiting for {} {} to be ready...".format(name, kind))

ready_check = "grep Running"
if kind in ["service", "svc"]:
    ready_check = "wc -l | grep 1"
elif kind in ["deployment", "deploy"]:
    ready_check = "grep 1/1"
elif kind == "issuer":
    ready_check = "grep True"

cmd = "kubectl get --no-headers -n {} {} {} | {}".format(namespace, kind, name, ready_check)

for i in range(60):

    process = subprocess.run(cmd, shell=True)
    if process.returncode == 0:
        break

    print("... not finished yet...")
    time.sleep(10)

print("Done.")
