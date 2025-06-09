#!/bin/bash
echo "~~ Setting Variables ~~"
export WINEARCH=win64
export WINEDEBUG=-all
export DISPLAY=:0

# Going to start bringing over some vars from ich777's Wreckfest server script.

# Ensure log directories exist
echo "~~ Creating log directories ~~"
mkdir -p "${XLOGDIR}" "${WINELOGDIR}" "${WFLOGFILEDIR}" 2>/dev/null || {
    echo "WARNING: Cannot create log directories in mounted volume, using container directories"
    export XLOGDIR="/tmp/logs/x"
    export WINELOGDIR="/tmp/logs/wine"
    export WFLOGFILEDIR="/tmp/logs/wf"
    mkdir -p "${XLOGDIR}" "${WINELOGDIR}" "${WFLOGFILEDIR}"
}

# run virtual display in background
echo "~~ Starting virtual display ~~"
X -config /home/steam/dummy-640x480.conf >> "${XLOGDIR}/stdout.log" 2>> "${XLOGDIR}/stderr.log" &
XSERVER_PID=$!

# Give X server time to start
sleep 2

echo "----------------"
echo "Installing Wreckfest 2 Dedicated Server from Steam"
echo "----------------"

# install wreckfest 2 server with timeout and retries
echo "Performing network connectivity checks..."
# Check if we can resolve Steam servers
if nslookup steamcommunity.com > /dev/null 2>&1; then
    echo "DNS resolution working"
else
    echo "WARNING: DNS resolution issues detected"
fi

# Test basic connectivity
if ping -c 3 steamcommunity.com > /dev/null 2>&1; then
    echo "Network connectivity to Steam servers confirmed"
else
    echo "WARNING: Network connectivity issues detected"
fi

echo "Attempting to connect to Steam servers..."
RETRY_COUNT=0
MAX_RETRIES=3

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Steam download attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES"
    timeout 900 /usr/games/steamcmd +force_install_dir "$STEAMAPPDIR" +login anonymous +@sSteamCmdForcePlatformType windows +app_update "$STEAMAPPID" validate +quit
    STEAM_EXIT_CODE=$?
    
    if [ $STEAM_EXIT_CODE -eq 0 ]; then
        echo "Steam download completed successfully"
        break
    elif [ $STEAM_EXIT_CODE -eq 124 ]; then
        echo "Steam download timed out after 15 minutes (attempt $((RETRY_COUNT + 1)))"
    else
        echo "Steam download failed with exit code: $STEAM_EXIT_CODE (attempt $((RETRY_COUNT + 1)))"
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        echo "Waiting 30 seconds before retry..."
        sleep 30
    fi
done

# Check if all retries failed
if [ $RETRY_COUNT -eq $MAX_RETRIES ] && [ $STEAM_EXIT_CODE -ne 0 ]; then
    echo "ERROR: All Steam download attempts failed"
    exit 1
fi

echo "----------------"
echo "Finished Installing Wreckfest 2 Dedicated Server from Steam"
echo "----------------"

# Check if Wreckfest2.exe exists
if [ ! -f "$STEAMAPPDIR/Wreckfest2.exe" ]; then
    echo "ERROR: Wreckfest2.exe not found in $STEAMAPPDIR"
    ls -la "$STEAMAPPDIR"
    exit 1
fi

echo "----------------"
echo "Starting Wreckfest 2 Dedicated Server in WINE"
echo "----------------"

cd $STEAMAPPDIR

echo "Contents of $STEAMAPPDIR:"
ls -la

echo "Initializing Wine prefix..."
wineboot --init 2>/dev/null || echo "Wine initialization completed"

# Check Wine dependencies and install if needed
echo "Installing Wine dependencies for Windows games..."
winetricks -q corefonts vcrun2022 || echo "Some dependencies may have failed, continuing..."

# Start wine server in background and capture PID
echo "Starting Wreckfest2.exe with arguments: --server --save-dir=$SERVERCONFIGDIR"
wine Wreckfest2.exe --server --save-dir="$SERVERCONFIGDIR" > "${WINELOGDIR}/stdout.log" 2> "${WINELOGDIR}/stderr.log" &
WINE_PID=$!

cd $HOME

echo "----------------"
echo "Wreckfest 2 Dedicated Server has been started in WINE (PID: $WINE_PID)"
echo "----------------"

# Wait for server to stabilize and check if it's running properly
echo "----------------"
echo "Checking if Wreckfest 2 Dedicated Server is running properly..."
echo "----------------"

TIMEOUT=60
COUNTER=0
SERVER_READY=false

# Wait for the server to start with timeout
while [ $COUNTER -lt $TIMEOUT ]; do
    sleep 1
    COUNTER=$((COUNTER + 1))
    
    # Check if wine process is still running
    if ! kill -0 $WINE_PID 2>/dev/null; then
        echo "ERROR: Wine process (PID: $WINE_PID) has exited"
        echo "Wine stdout log:"
        cat "${WINELOGDIR}/stdout.log" 2>/dev/null || echo "No stdout log found"
        echo "Wine stderr log:"
        cat "${WINELOGDIR}/stderr.log" 2>/dev/null || echo "No stderr log found"
        exit 1
    fi
    
    # Check for signs that the server is running (look for network port or log files)
    if netstat -ln 2>/dev/null | grep -q ":30100 " || [ -f "${SERVERCONFIGDIR}/logs"* ] 2>/dev/null; then
        echo "Server appears to be running and listening on port 30100"
        SERVER_READY=true
        break
    fi
    
    # Try to find a window (for servers that do create GUI)
    export WID=$(xdotool search --name Wreckfest 2>/dev/null)
    if [ -n "$WID" ]; then
        echo "Found Wreckfest window: $WID"
        xdotool windowmove $WID 0 0
        SERVER_READY=true
        break
    fi
    
    if [ $((COUNTER % 10)) -eq 0 ]; then
        echo "Still waiting for server to be ready... ($COUNTER seconds)"
        echo "Checking for any Wreckfest processes:"
        ps aux | grep -i wreckfest | grep -v grep || echo "No Wreckfest processes found"
    fi
done

if [ "$SERVER_READY" = false ]; then
    echo "WARNING: Server may not be ready after $TIMEOUT seconds, but Wine process is still running"
    echo "This might be normal for a headless dedicated server"
    echo "Wine stdout log:"
    cat "${WINELOGDIR}/stdout.log" 2>/dev/null || echo "No stdout log found"
    echo "Wine stderr log:"
    cat "${WINELOGDIR}/stderr.log" 2>/dev/null || echo "No stderr log found"
    echo "Continuing anyway..."
fi

echo "----------------"
echo "Server setup complete. Process PID: $WINE_PID"
echo "----------------"

echo "----------------"
echo "Starting Console Management"
echo "----------------"

if [ -n "$WID" ]; then
    echo "GUI window detected, starting interactive console wrapper"
    python3 "$WRAPPERDIR/main.py"
else
    echo "No GUI window detected, running in headless mode"
    echo "Server is running in background. Monitoring Wine process..."
    
    # Create a simple log monitor for headless operation
    echo "Wine process PID: $WINE_PID"
    echo "Server should be accessible on port 30100/UDP"
    echo "To stop the server, stop this container"
    
    # Monitor the wine process and logs
    while kill -0 $WINE_PID 2>/dev/null; do
        echo "$(date): Server is running (PID: $WINE_PID)"
        
        # Show any new content in wine logs
        if [ -f "${WINELOGDIR}/stdout.log" ]; then
            tail -n 5 "${WINELOGDIR}/stdout.log" 2>/dev/null | while read line; do
                [ -n "$line" ] && echo "STDOUT: $line"
            done
        fi
        
        if [ -f "${WINELOGDIR}/stderr.log" ]; then
            tail -n 5 "${WINELOGDIR}/stderr.log" 2>/dev/null | while read line; do
                [ -n "$line" ] && echo "STDERR: $line"
            done
        fi
        
        # Check if server is listening on the expected port
        if netstat -ln 2>/dev/null | grep -q ":30100 "; then
            echo "$(date): Server is listening on port 30100"
        fi
        
        sleep 30
    done
    
    echo "$(date): Wine process has exited"
    exit 1
fi