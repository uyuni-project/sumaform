#!/usr/bin/{{ pythonexec }}

import time

from spacewalk.server import rhnSQL

rhnSQL.initDB()

task_query = rhnSQL.prepare("""
    SELECT COUNT(DISTINCT task.name) AS count
      FROM rhnTaskoRun run
       JOIN rhnTaskoTemplate template ON template.id = run.template_id
       JOIN rhnTaskoBunch bunch ON bunch.id = template.bunch_id
       JOIN rhnTaskoTask task ON task.id = template.task_id
      WHERE bunch.name = 'mgr-sync-refresh-bunch' AND run.end_time IS NOT NULL
""");


print("Waiting for mgr-sync refresh to finish...")

while True:
    task_query.execute()

    if task_query.fetchone_dict()['count'] > 0:
        break

    print("...not finished yet...")
    time.sleep(10)

print("Done.")
