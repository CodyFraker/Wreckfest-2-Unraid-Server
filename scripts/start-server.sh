#!/bin/bash
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

echo "---Prepare Server---"
export WINEARCH=win64
export WINEPREFIX=/serverdata/serverfiles/WINE64
export WINEDEBUG=-all
export DBUS_FATAL_WARNINGS=0
export DISPLAY=:99
echo "---Checking if WINE workdirectory is present---"
if [ ! -d ${SERVER_DIR}/WINE64 ]; then
	echo "---WINE workdirectory not found, creating please wait...---"
    mkdir ${SERVER_DIR}/WINE64
else
	echo "---WINE workdirectory found---"
fi
echo "---Checking if WINE is properly installed---"
if [ ! -d ${SERVER_DIR}/WINE64/drive_c/windows ]; then
	echo "---Setting up WINE---"
    cd ${SERVER_DIR}
    winecfg > /dev/null 2>&1
    sleep 15
else
	echo "---WINE properly set up---"
fi
if [ ! -f ~/.screenrc ]; then
    echo "defscrollback 30000
bindkey \"^C\" echo 'Blocked. Please use to command \"exit\" to shutdown the server or close this window to exit the terminal.'" > ~/.screenrc
fi
if [ ! -f ${SERVER_DIR}/server_config.scnf ]; then
    cp ${SERVER_DIR}/initial_server_config.scnf ${SERVER_DIR}/server_config.scnf
    sed -i '/^#/!s/server_name=.*/server_name="Wreckfest2 Docker"/g' ${SERVER_DIR}/server_config.scnf
    sed -i '/welcome_message=/c\welcome_message="Welcome to Wreckfest 2 running on Docker"' ${SERVER_DIR}/server_config.scnf
    sed -i '/^#/!s/password=.*/password="Docker"/g' ${SERVER_DIR}/server_config.scnf
else
    echo "---'server_config.scnf' found..."
fi
echo "---Checking for old display lock files---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Starting Xvfb server---"
Xvfb :99 -screen scrn 640x480x16 2>/dev/null &
sleep 3

echo "---Start Server---"
cd ${SERVER_DIR}

# Check if game executable exists
if [ ! -f "Wreckfest2.exe" ]; then
    echo "---ERROR: Wreckfest2.exe not found in ${SERVER_DIR}---"
    ls -la ${SERVER_DIR}/
    exit 1
fi

echo "---Game executable found: Wreckfest2.exe---"

if [ "${DEBUG_MODE}" == "true" ]; then
    echo "---Debug Mode: Running server with output to Docker logs---"
    # Run server directly in foreground so all output goes to Docker logs
    exec wine64 Wreckfest2.exe --server --save-dir=/serverdata/serverfiles ${GAME_PARAMS}
else
    echo "---Normal Mode: Running server in screen session---"
    screen -S Wreckfest2 -d -m wine64 Wreckfest2.exe --server --save-dir=/serverdata/serverfiles ${GAME_PARAMS}
    sleep 2
    echo "---Checking screen session status---"
    screen -list
    if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
        echo "---Starting web console---"
        /opt/scripts/start-gotty.sh 2>/dev/null &
    fi
    sleep 1
    tail --pid=$(pgrep Wreckfest2.exe) -f /dev/null
fi 