#! /usr/bin/python

import requests
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-c', '--clients', action='store', dest='clients',
                    default=200, type=int,
                    help='Number of concurrent clients')
parser.add_argument('-r', '--hatch-rate', action='store', dest='hatch_rate',
                    default=100, type=int,
                    help='The rate per second in which clients are spawned')
inputUser = parser.parse_args()

LocustPayload = {
    'locust_count': inputUser.clients,
    'hatch_rate': inputUser.hatch_rate
}

res = requests.post('http://localhost/swarm', data=LocustPayload)
print(res.json())
