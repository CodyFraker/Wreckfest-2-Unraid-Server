#!/bin/bash
echo "~~ Setting Variables ~~"
export WINEARCH=win64
export WINEDEBUG=-all
export DISPLAY=:0

# Going to start bringing over some vars from ich777's Wreckfest server script.

# run virtual display in  background
X -config /home/steam/dummy-640x480.conf >> "${XLOGDIR}/stdout.log" 2>> "${XLOGDIR}/stderr.log" &

echo "----------------"
echo "Installing Wreckfest 2 Dedicated Server from Steam"
echo "----------------"

# install wreckfest 2 server
/usr/games/steamcmd +force_install_dir "$STEAMAPPDIR" +login anonymous +@sSteamCmdForcePlatformType windows +app_update "$STEAMAPPID" validate +quit

echo "----------------"
echo "Finished Installing Wreckfest 2 Dedicated Server from Steam"
echo "----------------"

echo "----------------"
echo "Starting Wreckfest 2 Dedicated Server in WINE"
echo "----------------"

cd $STEAMAPPDIR

wine Wreckfest2.exe --server --save-dir="$SERVERCONFIGDIR" > "${WINELOGDIR}/stdout.log" 2> "${WINELOGDIR}/stderr.log" &

cd $HOME

echo "----------------"
echo "Wreckfest 2 Dedicated Server has been started in WINE"
echo "----------------"

# Get wreckfest window ID
echo "----------------"
echo "Geting Wreckfest Window ID"
echo "----------------"

export WID=$(xdotool search --name Wreckfest)

# Wait for the server to start
while [ -z "$WID" ]; do
    sleep 1
    export WID=$(xdotool search --name Wreckfest)
done

sleep 1

echo "----------------"
echo "Finished getting Wreckfest Window ID"
echo "----------------"

# Move the window to the top left corner
xdotool windowmove $WID 0 0

echo "----------------"
echo "Starting Console"
echo "----------------"

sleep 2

python3 "$WRAPPERDIR/main.py"