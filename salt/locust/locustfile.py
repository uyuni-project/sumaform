#! /usr/bin/python

from locust import HttpLocust, TaskSet, task

server = 'https://{{ grains["server"] }}/'
username = 'admin'
password = 'admin'

class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        # don't verify ssl certs
        self.login()
        self.client.verify = False

    def login(self):
        self.client.post("/", {"username": username, "password": password })

    @task(1)
    def index(self):
        self.client.get("rhn/YourRhn.do")

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    host = server
    # These are the minimum and maximum time respectively, in milliseconds, that a simulated user will wait between executing each task.
    min_wait = 5000
    max_wait = 9000
