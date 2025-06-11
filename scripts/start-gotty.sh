#!/bin/bash

echo "---Gotty starting, checking for Wreckfest2 screen session---"

# Wait for screen session to be available
for i in {1..10}; do
    if screen -list | grep -q "Wreckfest2"; then
        echo "---Found Wreckfest2 screen session, starting gotty---"
        break
    else
        echo "---Waiting for Wreckfest2 screen session... attempt $i/10---"
        sleep 1
    fi
done

# Final check before starting gotty
if screen -list | grep -q "Wreckfest2"; then
    echo "---Starting gotty on port 8080---"
    gotty --port 8080 ${GOTTY_PARAMS} screen -r Wreckfest2
else
    echo "---ERROR: Wreckfest2 screen session not found after waiting---"
    echo "---Available screen sessions:---"
    screen -list
    exit 1
fi 