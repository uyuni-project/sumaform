#!/usr/bin/python
import sys
import time
import xmlrpclib
import getopt
import requests

evil_minion_hostname = "evil-minions"
locust_hostname = "locust.tf.local"
run_all = True
patching_only = False
locust_only = False

manager_url = "http://localhost/rpc/api"
client = xmlrpclib.Server(manager_url, verbose=0)
key = client.auth.login('admin', 'admin')

def parse_arguments():
    try:
        options, remainder = getopt.getopt(sys.argv[1:], '', ['evil-minions-hostname=','locust-hostname=','patching-only','locust-only'])
    except getopt.GetoptError:
        sys.exit(1)

    global evil_minion_hostname
    global locust_url
    global patching_only
    global locust_only
    global run_all

    for opt, arg in options:
        if opt in ('--evil-minions-hostname'):
            evil_minion_hostname = arg
        elif opt in ('--locust-hostname'):
            locust_url = 'http://' + arg + '.tf.local'
        elif opt in ('--patching-only'):
            patching_only = True
            run_all = False
        elif opt in ('--locust-only'):
            locust_only = True
            run_all = False

def retry_for_minutes(fun, minutes):
    """Runs fun for up to minutes minutes, every 10 seconds, until it returns True"""
    for iteration in range(minutes * 60 / 10 - 1):
        if fun():
            return
        time.sleep(10)
    if not fun():
        print("Timeout reached, aborting")
        sys.exit(1)

def check_system_count(expected_count):
    all_systems = client.system.listSystems(key)
    systems = [s for s in all_systems if s["name"].startswith(evil_minion_hostname)]
    actual_count = len(systems)
    print("Found %d/%d systems" % (actual_count, expected_count))
    return actual_count == expected_count

def check_patched_system_count(expected_count):
    all_patchable_systems = client.system.listOutOfDateSystems(key)
    patchable_systems = [s for s in all_patchable_systems if s["name"].startswith(evil_minion_hostname)]
    actual_count = len(patchable_systems)
    print("Found %d/%d patchable systems" % (actual_count, expected_count))
    return actual_count == expected_count

def wait_for_patchable_systems(expected_systems_count, expected_patched_systems_count):
    retry_for_minutes(lambda: check_system_count(expected_systems_count), 15)
    retry_for_minutes(lambda: check_patched_system_count(expected_patched_systems_count), 20)

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
    res = requests.post('http://'+locust_hostname+'/swarm', data=LocustPayload)
    print(res.json()["message"])
    time.sleep(120)
    res = requests.get('http://'+locust_hostname+'/stop')
    print(res.json()["message"])

parse_arguments()

if (run_all or patching_only):
    #wait for onboarding minions
    wait_for_patchable_systems(200,200)
    #Patch all evil minions
    patch_all_systems()
    #wait por patched minions
    wait_for_patchable_systems(200,0)

if (run_all or locust_only):
    #run locust for 200
    run_locust_http_load(200)
    #run locust for 300
    run_locust_http_load(300)
    #run locust for 400
    run_locust_http_load(400)
