#!/bin/bash

echo "=== Gotty Web Console Startup ==="
echo "User: $(whoami)"
echo "UID: $(id -u)" 
echo "GID: $(id -g)"
echo "Home: $HOME"
echo "Date: $(date)"
echo ""

# Wait for screen session to be available
echo "Waiting for Wreckfest2 screen session..."
for i in {1..15}; do
    echo "Attempt $i/15: Checking for screen sessions..."
    
    # List all screen sessions
    screen -list
    
    if screen -list 2>/dev/null | grep -q "Wreckfest2"; then
        echo "✓ Found Wreckfest2 screen session!"
        break
    else
        echo "⏳ No Wreckfest2 session found, waiting..."
        sleep 2
    fi
done

# Final verification
echo ""
echo "=== Final Screen Session Check ==="
screen -list

if screen -list 2>/dev/null | grep -q "Wreckfest2"; then
    echo ""
    echo "🚀 Starting gotty web console on port 8080..."
    echo "Command: gotty --port 8080 ${GOTTY_PARAMS} screen -x Wreckfest2"
    echo ""
    
    # Start Gotty as the same user running the screen session
    exec su - steam -c "gotty --port 8080 --permit-write --title-format Wreckfest2-Console screen -xS Wreckfest2"
else
    echo ""
    echo "❌ ERROR: Cannot find Wreckfest2 screen session"
    echo "Available screen sessions:"
    screen -list
    echo ""
    echo "Screen directories:"
    ls -la /run/screen/ 2>/dev/null || echo "No screen directories found"
    echo ""
    echo "Running processes:"
    ps aux | grep -E "(screen|wine|Wreckfest)" | grep -v grep
    exit 1
fi 