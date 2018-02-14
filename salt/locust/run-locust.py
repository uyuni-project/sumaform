#! /usr/bin/python

import requests
import argparse


# set user and hrate needed for locust webui

parser = argparse.ArgumentParser()
parser.add_argument('-c', action='store', dest='userLocust', default=200, type=int,
                    help='user that locust will simulate')
parser.add_argument('-r', action='store', dest='hrate', default=100, type=int,
                    help='hatch rate locust')
inputUser = parser.parse_args()
print('locust users: ', inputUser.userLocust)
print('locust hatch rate: ', inputUser.hrate)
LocustPayload = {
    'locust_count': inputUser.userLocust,
    'hatch_rate': inputUser.hrate
}

# start locust webui (needed for locust_export statistics)
# We assume implicity that locust and locust_exporter run in the same server
locustLocalhost = 'http://localhost:8089/swarm'

# TODO: add locust file/s to be executed
return_code = subprocess.call("locust -f ", shell=True)  

res = requests.post(locustLocalhost, data=LocustPayload)
print(res.json())
