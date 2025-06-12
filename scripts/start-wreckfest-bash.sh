#!/bin/bash
cd /serverdata/serverfiles

# Create a named pipe
PIPE=/tmp/wreckfest.pipe
rm -f "$PIPE"
mkfifo "$PIPE"

# Launch server, redirect stdout+stderr into the pipe
wineconsole --backend=curses Wreckfest2.exe --server --save-dir="$PWD" "${GAME_PARAMS}" > "$PIPE" 2>&1 &

# Capture the server PID
PID=$!

# Read from the pipe and output to console in real time
while IFS= read -r line; do
  echo "$line"
done < "$PIPE" &

WAIT_PID=$!

# When the server exits, clean up
wait "$PID"
kill "$WAIT_PID"
rm -f "$PIPE"
exit 0
