#!/usr/bin/python
import sys
import time
import xmlrpclib
import getopt
import requests
import subprocess
import datetime

locust = "{{ grains.get("pts_locust") }}.{{ grains.get("domain") }}"
system_count = {{ grains.get("pts_system_count") }}
system_prefix = "{{ grains.get("pts_system_prefix") }}"
last_clone_prefix = "{{ (grains.get("cloned_channels")|last)['prefix'] }}"

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
            enabled_phases = ["onboarding", "patching"]
        elif opt in ('--locust-only'):
            enabled_phases = ["onboarding", "locust"]

def set_up():
    # system prefixes
    original_system_name = system_prefix + ".tf.local"
    evil_minion_system_prefix = system_prefix + "-"
    # get server ids
    systems = client.system.listSystems(key)
    original_system_id = next(s["id"] for s in systems if s["name"].startswith(original_system_name))
    evil_minion_system_ids = [s["id"] for s in systems if s["name"].startswith(evil_minion_system_prefix)]

    # patch the original minion to the q3 clone
    print("Patching original minion with erratas from q3 clone channel")
    patch_minions([original_system_id], original_system_name)

    # now all evil-minions can copy the original, an be patched as well
    print("Patching evil-minions with erratas from q3 clone channel")
    patch_minions(evil_minion_system_ids, evil_minion_system_prefix)

    # now subscribe the original minion to q4 channels
    print("Subscribing original minions to q4 clone channel")
    base_channel_label = get_base_channel_label(last_clone_prefix)
    children_channel_labels = get_children_channel_labels(base_channel_label)
    subscribe_minions_to_channels([original_system_id], base_channel_label, children_channel_labels, original_system_name)

    # now all evil-minions can copy the original, an be subscribed to q4 channel as well
    print("Subscribing evil-minions to q4 clone channel")
    subscribe_minions_to_channels(evil_minion_system_ids, base_channel_label, children_channel_labels, evil_minion_system_prefix)

    # patch the original minion to the q4 clone
    print("Patching original minion with erratas from q4 clone channel")
    patch_minions([original_system_id], original_system_name)

def retry_for_minutes(fun, minutes):
    """Runs fun for up to minutes minutes, every 10 seconds, until it returns True"""
    for iteration in range(minutes * 60 / 10 - 1):
        if fun():
            return
        time.sleep(10)
    if not fun():
        print("Timeout of {} minutes elapsed, aborting".format(minutes))
        sys.exit(1)

def check_system_count(retrieve_systems_fun, expected_count, system_prefix, log_msg):
    all_systems = retrieve_systems_fun()
    systems = [s for s in all_systems if s["name"].startswith(system_prefix)]
    actual_count = len(systems)
    print(log_msg.format(actual_count))
    return actual_count == expected_count

def check_onboarded_system_count(expected_count, system_prefix):
    return check_system_count(lambda: client.system.listSystems(key), expected_count, system_prefix, "{} systems are onboarded")

def check_patched_system_count(expected_count, system_prefix):
    return check_system_count(lambda: client.system.listOutOfDateSystems(key), expected_count, system_prefix, "{} systems are patchable")

def check_subscribed_to_channels_system_count(channel_label, expected_count, system_prefix):
    return check_system_count(lambda: client.channel.software.listSubscribedSystems(key, channel_label), expected_count, system_prefix, "{} systems are subscribed")

def get_base_channel_label(channel_prefix):
    allChannels = client.channel.listSoftwareChannels(key)
    baseChannel = next(c for c in allChannels if (c["label"].startswith(channel_prefix) and c["parent_label"] == ''))
    return baseChannel["label"]

def get_children_channel_labels(parent_channel_label):
    children = client.channel.software.listChildren(key, parent_channel_label)
    return [c["label"] for c in children]

def subscribe_minions_to_channels(system_ids, base_channel_label, children_channel_labels, system_prefix):
    print("Sending command to subscribe to channels: {} systems".format(len(system_ids)))
    now = datetime.datetime.now()
    for system_id in system_ids:
        client.system.scheduleChangeChannels(key, system_id, base_channel_label, children_channel_labels, now)

    print("Waiting for {} systems to be subscribed to channels (timeout: 20 minutes)...".format(len(system_ids)))
    retry_for_minutes(lambda: check_subscribed_to_channels_system_count(base_channel_label, len(system_ids), system_prefix), 20)

def patch_minions(system_ids, system_prefix):
    print("Sending command to patch %d systems" % len(system_ids))
    # all minions should have same errata, so we use first server on the list to get it
    erratas = client.system.getUnscheduledErrata(key, system_ids[0])
    errata_ids = [errata["id"] for errata in erratas]
    client.system.scheduleApplyErrata(key, system_ids, errata_ids)

    print("Waiting for {} systems to be not patchable anymore (timeout: 20 minutes)...".format(len(system_ids)))
    retry_for_minutes(lambda: check_patched_system_count(0, system_prefix), 20)

def patch_all_systems():
    systems = client.system.listSystems(key)
    system_ids = [system["id"] for system in systems]
    patch_minions(system_ids, system_prefix)

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

if "fio" in enabled_phases:
    print("Test I/O performance: random reads")
    subprocess.call(["fio", "--name", "randread", "--fsync=1", "--direct=1", "--rw=randread", "--blocksize=4k", "--numjobs=8", "--size=512M", "--time_based", "--runtime=60", "--group_reporting"])
    print("Test I/O performance: random writes")
    subprocess.call(["fio", "--name", "randwrite", "--fsync=1", "--direct=1", "--rw=randwrite", "--blocksize=4k", "--numjobs=8", "--size=512M", "--time_based", "--runtime=60", "--group_reporting"])

if "onboarding" in enabled_phases:
    print("Waiting for {} systems to be onboarded in SUSE Manager (timeout: 15 minutes)...".format(system_count))
    retry_for_minutes(lambda: check_onboarded_system_count(system_count, system_prefix), 15)

    print("Waiting for {} systems to be patchable in SUSE Manager (timeout: 20 minutes)...".format(system_count))
    retry_for_minutes(lambda: check_patched_system_count(system_count, system_prefix), 20)

if "locust" in enabled_phases:
    for users in range(50, 450, 25):
        run_locust_http_load(users)

if "patching" in enabled_phases:
    set_up()
    patch_all_systems()
