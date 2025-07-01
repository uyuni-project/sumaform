#!/bin/sh

USER=$1
PASS=$2

echo "
SELECT '=== ' || COUNT(DISTINCT task.name) || ' ===' AS count
FROM rhnTaskoRun run
JOIN rhnTaskoTemplate template ON template.id = run.template_id
JOIN rhnTaskoBunch bunch ON bunch.id = template.bunch_id
JOIN rhnTaskoTask task ON task.id = template.task_id
WHERE bunch.name = 'mgr-sync-refresh-bunch' AND run.end_time IS NOT NULL
" > /tmp/sync-refresh-query.sql

echo "Waiting for mgr-sync refresh to finish..."

sleep 3
for i in $(seq 100); do
    OUT=$(sudo su - postgres -c "psql susemanager < /tmp/sync-refresh-query.sql")
    if echo $OUT | grep "=== " >/dev/null && ! echo $OUT | grep "=== 0 ===" >/dev/null; then
        if test -f /root/.mgr-sync ; then
            mgr-sync refresh
        else
            echo -e "$USER\\n$PASS\\n" | mgr-sync refresh
        fi
        if [ $? -eq 0 ]; then
            break
        fi
    fi
    echo "...not finished yet..."
    sleep 10
done
rm -f /tmp/sync-refresh-query.sql
echo "Done."
