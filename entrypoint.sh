#!/bin/bash
# Runs the egg's startup command, the same way the Pterodactyl images do.
cd /home/container || exit 1

# Wings passes the startup command in STARTUP, with {{VARIABLE}} placeholders
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
echo "container@bofanodes:~$ ${MODIFIED_STARTUP}"

# exec: the start script replaces this one, so it receives stop signals directly
exec /bin/bash -c "${MODIFIED_STARTUP}"
