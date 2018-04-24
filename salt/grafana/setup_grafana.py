#!/usr/bin/env python

import base64
import errno
import httplib
import json
import socket
import sys
import time

def do(method, connection, headers, path, body=None):
    connection.request(method, path, headers=headers, body=json.dumps(body))
    resp = connection.getresponse()
    content = resp.read()

    if resp.status != 200:
        raise IOError("Unexpected HTTP status received on %s: %d" % (path, resp.status))

    return json.loads(content)


connection = httplib.HTTPConnection("localhost")

# try to connect, multiple times if ECONNREFUSED is raised
# (service is up but not ready for requests yet)
for retries in range(0,10):
    try:
        connection.connect()
    except socket.error as e:
        if e.errno != errno.ECONNREFUSED:
            raise e
        print("Connection refused, retrying...")
        time.sleep(1)

token = base64.b64encode("admin:admin".encode("ASCII")).decode("ascii")
headers = {
  "Authorization" : "Basic %s" %  token,
  "Content-Type" : "application/json; charset=utf8"
}

datasources = do("GET", connection, headers, "/api/datasources")

if "Prometheus on localhost" not in map(lambda d: d["name"], datasources):
    do("POST", connection, headers, "/api/datasources", {
      "name" : "Prometheus on localhost",
      "type" : "prometheus",
      "url" : "http://localhost:9090/",
      "access" : "proxy",
      "basicAuth" : False,
      "isDefault": True,
    })

dashboards = do("GET", connection, headers, "/api/search")
suse_manager_dashboards = filter(lambda d: d["title"] == "SUSE Manager Server", dashboards)

with open('/opt/grafana/conf/suse_manager.json', 'r') as content_file:
    dashboard = json.loads(content_file.read())
    dashboard["id"] = suse_manager_dashboards[0]["id"] if suse_manager_dashboards else None
    do("POST", connection, headers, "/api/dashboards/db", { "dashboard" : dashboard, "overwrite" : True })
