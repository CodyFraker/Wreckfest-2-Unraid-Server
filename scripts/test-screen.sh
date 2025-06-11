#!/bin/bash

echo "=== Screen Session Test ==="
echo "Current user: $(whoami)"
echo "Current UID: $(id -u)"
echo "Current GID: $(id -g)"
echo ""

echo "=== Screen Directories ==="
ls -la /run/screen/ 2>/dev/null || echo "No screen directories found"
echo ""

echo "=== Screen Sessions for Current User ==="
screen -list
echo ""

echo "=== All Screen Processes ==="
ps aux | grep screen | grep -v grep
echo ""

echo "=== Test: Try to connect to Wreckfest2 screen (non-interactive) ==="
timeout 2 screen -r Wreckfest2 -X version 2>&1 || echo "Cannot connect to Wreckfest2 screen session"
echo ""

echo "=== Environment Check ==="
echo "HOME: $HOME"
echo "USER: $USER" 
echo "LOGNAME: $LOGNAME"
echo ""

echo "=== Test Complete ===" 