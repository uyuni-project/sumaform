#! /usr/bin/python

from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        # don't verify ssl certs
        self.client.verify = False
        self.login()

    def login(self):
        self.client.post("/", {"username": "admin", "password": "admin" })

    @task(1)
    def index(self):
        self.client.get("/rhn/YourRhn.do")

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    # These are the minimum and maximum time respectively, in milliseconds, that a simulated user will wait between executing each task.
    min_wait = 5000
    max_wait = 9000
