#!/usr/bin/env python

import yaml
from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        # don't verify ssl certs
        self.client.verify = False
        self.download_path = self.get_download_path()

    def get_download_path(self):
        channel_name = 'cloned-2017-q4-sles12-sp3-updates-x86_64'
        package_name = 'at-3.1.14-8.3.1.x86_64.rpm'

        response = self.client.get("/pub/pillar_data/pillar_evil-minions-0.yml")
        json_pillar = yaml.load(response.content)
        validation_token = json_pillar['channels'][channel_name]['token']

        return "/rhn/manager/download/" + channel_name + "/getPackage/" + package_name + "?" + validation_token;

    @task(1)
    def download_package(self):
        self.client.get(self.download_path)

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    # These are the minimum and maximum time respectively, in milliseconds, that a simulated user will wait between executing each task.
    min_wait = 5000
    max_wait = 9000
