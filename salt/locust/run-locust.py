#!{{grains['pythonexecutable']}}

import argparse
import requests
import time

parser = argparse.ArgumentParser()
parser.add_argument('-c', '--clients', action='store', dest='clients',
                    default=200, type=int,
                    help='Number of concurrent clients')
parser.add_argument('-r', '--hatch-rate', action='store', dest='hatch_rate',
                    default=100, type=int,
                    help='The rate per second in which clients are spawned')
parser.add_argument('-t', '--swarm-time', action='store', dest='swarm_time',
                    default=120, type=int,
                    help='The duration of the swarm in seconds')
args = parser.parse_args()

LocustPayload = {
    'locust_count': args.clients,
    'hatch_rate': args.hatch_rate
}

res = requests.post('http://localhost/swarm', data=LocustPayload)
print(res.json()["message"])
time.sleep(args.swarm_time)
res = requests.get('http://localhost/stop')
print(res.json()["message"])
