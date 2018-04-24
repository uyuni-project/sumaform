#!/usr/bin/python
import sys
import time
import xmlrpclib
import getopt
import requests

locust = "{{ grains.get("pts_locust") }}.{{ grains.get("domain") }}"
system_count = {{ grains.get("pts_system_count") }}
system_prefix = "{{ grains.get("pts_system_prefix") }}"
run_patching = True
run_locust = True

manager_url = "http://localhost/rpc/api"
client = xmlrpclib.Server(manager_url, verbose=0)
key = client.auth.login('admin', 'admin')

def parse_arguments():
    try:
        options, remainder = getopt.getopt(sys.argv[1:], '', ['patching-only','locust-only'])
    except getopt.GetoptError:
        sys.exit(1)

    global run_patching
    global run_locust

    for opt, arg in options:
        if opt in ('--patching-only'):
            run_locust = False
        elif opt in ('--locust-only'):
            run_patching = False

def retry_for_minutes(fun, minutes):
    """Runs fun for up to minutes minutes, every 10 seconds, until it returns True"""
    for iteration in range(minutes * 60 / 10 - 1):
        if fun():
            return
        time.sleep(10)
    if not fun():
        print("Timeout reached, aborting")
        sys.exit(1)

def check_system_count(expected_count, system_prefix):
    all_systems = client.system.listSystems(key)
    systems = [s for s in all_systems if s["name"].startswith(system_prefix)]
    actual_count = len(systems)
    print("Found %d/%d systems" % (actual_count, expected_count))
    return actual_count == expected_count

def check_patched_system_count(expected_count, system_prefix):
    all_patchable_systems = client.system.listOutOfDateSystems(key)
    patchable_systems = [s for s in all_patchable_systems if s["name"].startswith(system_prefix)]
    actual_count = len(patchable_systems)
    print("Found %d/%d patchable systems" % (actual_count, expected_count))
    return actual_count == expected_count

def wait_for_patchable_systems(expected_systems_count, expected_patched_systems_count, system_prefix):
    retry_for_minutes(lambda: check_system_count(expected_systems_count, system_prefix), 15)
    retry_for_minutes(lambda: check_patched_system_count(expected_patched_systems_count, system_prefix), 20)

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
        'hatch_rate': 100
    }
    res = requests.post('http://'+locust+'/swarm', data=LocustPayload)
    print(res.json()["message"])
    time.sleep(120)
    res = requests.get('http://'+locust+'/stop')
    print(res.json()["message"])

parse_arguments()

if run_patching:
    #wait for onboarding minions
    wait_for_patchable_systems(system_count, system_count, system_prefix)
    #Patch all evil minions
    patch_all_systems()
    #wait por patched minions
    wait_for_patchable_systems(system_count, 0, system_prefix)

if run_locust:
    #run locust for 200
    run_locust_http_load(200)
    #run locust for 300
    run_locust_http_load(300)
    #run locust for 400
    run_locust_http_load(400)
