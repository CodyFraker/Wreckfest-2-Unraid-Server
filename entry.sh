#!/bin/bash

export DISPLAY=:0

# run virtual display in  background
X -config /home/steam/dummy-640x480.conf >> "${XLOGDIR}/stdout.log" 2>> "${XLOGDIR}/stderr.log" &

echo "----------------"
echo "START Installing Wreckfest 2 Dedicated Server from Steam"
echo "----------------"

# install wreckfest 2 server
/usr/games/steamcmd +force_install_dir "$STEAMAPPDIR" +login anonymous +@sSteamCmdForcePlatformType windows +app_update "$STEAMAPPID" validate +quit
# run wreckfest 2 server in background, wine only runs from the same directory as the executable

echo "----------------"
echo "FINISH Installing Wreckfest 2 Dedicated Server from Steam"
echo "----------------"


# experimental console env var is EXPERIMENTAL_CONSOLE=1

if [ "$EXPERIMENTAL_CONSOLE" =~ "1" ]; then
    echo "----------------"
    echo "START Wreckfest 2 Dedicated Server in WINE"
    echo "----------------"
    cd $STEAMAPPDIR

    wine Wreckfest2.exe --server --save-dir="$SERVERCONFIGDIR" > "${WINELOGDIR}/stdout.log" 2> "${WINELOGDIR}/stderr.log" &

    cd $HOME

    echo "----------------"
    echo "FINISH Wreckfest 2 Dedicated Server in WINE"
    echo "----------------"

    # Get wreckfest window ID
    echo "----------------"
    echo "START Get Wreckfest Window ID"
    echo "----------------"

    export WID=$(xdotool search --name Wreckfest)

    # Wait for the server to start
    while [ -z "$WID" ]; do
        sleep 1
        export WID=$(xdotool search --name Wreckfest)
    done

    sleep 1

    echo "----------------"
    echo "FINISH Get Wreckfest Window ID"
    echo "----------------"

    # Move the window to the top left corner
    xdotool windowmove $WID 0 0

    python3 "$WRAPPERDIR/main.py"

else

    wine Wreckfest2.exe --server --save-dir="$SERVERCONFIGDIR" > "${WINELOGDIR}/stdout.log" 2> "${WINELOGDIR}/stderr.log"

fi