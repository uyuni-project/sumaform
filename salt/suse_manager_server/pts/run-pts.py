#!/usr/bin/python
import sys
import time
import xmlrpclib
import getopt
import requests
import subprocess

locust = "{{ grains.get("pts_locust") }}.{{ grains.get("domain") }}"
system_count = {{ grains.get("pts_system_count") }}
system_prefix = "{{ grains.get("pts_system_prefix") }}"
enabled_phases = ["onboarding", "patching", "locust"]

manager_url = "http://localhost/rpc/api"
client = xmlrpclib.Server(manager_url, verbose=0)
key = client.auth.login('admin', 'admin')

def parse_arguments():
    try:
        options, remainder = getopt.getopt(sys.argv[1:], '', ['onboarding-only', 'fio-only', 'patching-only','locust-only'])
    except getopt.GetoptError:
        sys.exit(1)

    global enabled_phases

    for opt, arg in options:
        if opt in ('--onboarding-only'):
            enabled_phases = ["onboarding"]
        if opt in ('--fio-only'):
            enabled_phases = ["fio"]
        elif opt in ('--patching-only'):
            enabled_phases = ["patching"]
        elif opt in ('--locust-only'):
            enabled_phases = ["locust"]

def retry_for_minutes(fun, minutes):
    """Runs fun for up to minutes minutes, every 10 seconds, until it returns True"""
    for iteration in range(minutes * 60 / 10 - 1):
        if fun():
            return
        time.sleep(10)
    if not fun():
        print("Timeout of %d minutes elapsed, aborting" % minutes)
        sys.exit(1)

def check_system_count(expected_count, system_prefix):
    all_systems = client.system.listSystems(key)
    systems = [s for s in all_systems if s["name"].startswith(system_prefix)]
    actual_count = len(systems)
    print("%d systems are registered" % actual_count)
    return actual_count == expected_count

def check_patched_system_count(expected_count, system_prefix):
    all_patchable_systems = client.system.listOutOfDateSystems(key)
    patchable_systems = [s for s in all_patchable_systems if s["name"].startswith(system_prefix)]
    actual_count = len(patchable_systems)
    print("%d systems are patchable" % actual_count)
    return actual_count == expected_count

def patch_all_systems():
    systems = client.system.listSystems(key)
    system_ids = [system["id"] for system in systems]
    # all evil-minions have same errata, so we use first server on the list to get it
    erratas = client.system.getUnscheduledErrata(key, system_ids[0])
    errata_ids = [errata["id"] for errata in erratas]
    client.system.scheduleApplyErrata(key, system_ids, errata_ids)

def run_locust_http_load(clients_count):
    LocustPayload = {
        'locust_count': clients_count,
        'hatch_rate': 1000
    }
    res = requests.post('http://'+locust+'/swarm', data=LocustPayload)
    print(res.json()["message"])
    time.sleep(60)
    res = requests.get('http://'+locust+'/stop')
    print(res.json()["message"])

parse_arguments()

if "onboarding" in enabled_phases:
    print("Waiting for %d systems to be onboarded in SUSE Manager (timeout: 15 minutes)..." % system_count)
    retry_for_minutes(lambda: check_system_count(system_count, system_prefix), 15)

    print("Waiting for %d systems to be patchable in SUSE Manager (timeout: 20 minutes)..." % system_count)
    retry_for_minutes(lambda: check_patched_system_count(system_count, system_prefix), 20)

if "fio" in enabled_phases:
    print("Test I/O performance: random reads")
    subprocess.call(["fio", "--name", "randread", "--fsync=1", "--direct=1", "--rw=randread", "--blocksize=4k", "--numjobs=8", "--size=512M", "--time_based", "--runtime=60", "--group_reporting"])
    print("Test I/O performance: random writes")
    subprocess.call(["fio", "--name", "randwrite", "--fsync=1", "--direct=1", "--rw=randwrite", "--blocksize=4k", "--numjobs=8", "--size=512M", "--time_based", "--runtime=60", "--group_reporting"])

if "patching" in enabled_phases:
    print("Sending command to patch %d systems" % system_count)
    patch_all_systems()

    print("Waiting for %d systems to be not patchable anymore (timeout: 20 minutes)..." % system_count)
    retry_for_minutes(lambda: check_patched_system_count(0, system_prefix), 20)

if "locust" in enabled_phases:
    for users in range(50, 450, 25):
        run_locust_http_load(users)
