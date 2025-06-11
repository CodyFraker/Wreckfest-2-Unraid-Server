#!/bin/bash

echo "=== Wreckfest2 Screen Session Diagnostics ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "Date: $(date)"
echo ""

echo "=== Environment Variables ==="
echo "STEAMCMD_DIR: ${STEAMCMD_DIR}"
echo "SERVER_DIR: ${SERVER_DIR}"
echo "DEBUG_MODE: ${DEBUG_MODE}"
echo "ENABLE_WEBCONSOLE: ${ENABLE_WEBCONSOLE}"
echo ""

echo "=== Screen Sessions ==="
screen -list
echo ""

echo "=== Running Processes ==="
ps aux | grep -E "(wine|Wreckfest|screen|gotty)" | grep -v grep
echo ""

echo "=== Wine Processes ==="
pgrep -f wine
pgrep -f Wreckfest2.exe
echo ""

echo "=== Server Directory Contents ==="
ls -la ${SERVER_DIR}/ | head -20
echo ""

echo "=== Wine Configuration ==="
echo "WINEPREFIX: ${WINEPREFIX}"
echo "WINEARCH: ${WINEARCH}"
echo "WINEDEBUG: ${WINEDEBUG}"
echo ""

if [ -f "${SERVER_DIR}/Wreckfest2.exe" ]; then
    echo "=== Game Executable Found ==="
    ls -la "${SERVER_DIR}/Wreckfest2.exe"
else
    echo "=== ERROR: Game Executable Not Found ==="
fi

echo ""
echo "=== Network Ports ==="
netstat -tlnp | grep -E "(8080|30100)"
echo ""

echo "=== Diagnostics Complete ===" 