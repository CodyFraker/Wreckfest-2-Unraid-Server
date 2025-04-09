#!/bin/bash

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

wine Wreckfest2.exe --server --save-dir="$SERVERCONFIGDIR"