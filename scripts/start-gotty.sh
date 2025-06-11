#!/bin/bash

echo "---Gotty starting as user: $(whoami)---"
echo "---Checking for Wreckfest2 screen session---"

# Wait for screen session to be available
for i in {1..10}; do
    echo "---Screen sessions for current user:---"
    screen -list
    
    if screen -list | grep -q "Wreckfest2"; then
        echo "---Found Wreckfest2 screen session, starting gotty---"
        break
    else
        echo "---Waiting for Wreckfest2 screen session... attempt $i/10---"
        sleep 1
    fi
done

# Final check before starting gotty
echo "---Final screen session check:---"
screen -list

if screen -list | grep -q "Wreckfest2"; then
    echo "---Starting gotty on port 8080---"
    echo "---Gotty command: gotty --port 8080 ${GOTTY_PARAMS} screen -r Wreckfest2---"
    gotty --port 8080 ${GOTTY_PARAMS} screen -r Wreckfest2
else
    echo "---ERROR: Wreckfest2 screen session not found after waiting---"
    echo "---Current user: $(whoami)---"
    echo "---Available screen sessions for current user:---"
    screen -list
    echo "---Checking all screen directories:---"
    ls -la /run/screen/ 2>/dev/null || echo "No screen directories found"
    exit 1
fi 