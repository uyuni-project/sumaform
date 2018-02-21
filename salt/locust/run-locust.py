#! /usr/bin/python

import requests
import argparse


parser = argparse.ArgumentParser()
parser.add_argument('-c', '--clients' action='store', dest='clients', default=200, type=int,
                    help='Number of concurrent clients')
parser.add_argument('-r', '--hatch-rate', action='store', dest='hatch_rate', default=100, type=int,
                    help='The rate per second in which clients are spawned')
inputUser = parser.parse_args()
print('locust users: ', inputUser.clients)
print('locust hatch rate: ', inputUser.hatch_rate)
LocustPayload = {
    'locust_count': inputUser.clients,
    'hatch_rate': inputUser.hatch_rate
}

# start locust webui (needed for locust_export statistics)
# We assume implicity that locust and locust_exporter run in the same server
locustLocalhost = 'http://localhost:8089/swarm'

# TODO: add locust file/s to be executed
return_code = subprocess.call("locust -f ", shell=True)  

res = requests.post(locustLocalhost, data=LocustPayload)
print(res.json())
