## WIP: This line will be removed once its confirmed to work on my server!

# Wreckfest 2 Dedicated Server for Unraid

This Docker container will download and install SteamCMD and Wreckfest 2 Dedicated Server, then run it with Wine.

**Persistent Storage:** The container uses shared volumes for both SteamCMD and game files, so the game won't be re-downloaded on every restart.

**Update Notice:** Simply restart the container if a newer version of the game is available.

**WEB CONSOLE:** You can connect to the Wreckfest 2 console by opening your browser and go to HOSTIP:8080 (eg: 192.168.1.1:8080) or click on WebUI on the Docker page within Unraid.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| STEAMCMD_DIR | Folder for SteamCMD | /serverdata/steamcmd |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| GAME_ID | The GAME_ID for Wreckfest 2 Dedicated Server | 3519390 |
| GAME_PARAMS | Enter your start up parameters for the server if needed. | none |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| VALIDATE | Validates the game data | true |
| USERNAME | Steam username (leave blank for anonymous login) | blank |
| PASSWRD | Steam password (leave blank for anonymous login) | blank |
| ENABLE_WEBCONSOLE | Enable web console access | true |

## Run example
```
docker run --name Wreckfest2 -d \
	-p 30100:30100/udp -p 8080:8080 \
	--env 'GAME_ID=3519390' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /path/to/steamcmd:/serverdata/steamcmd \
	--volume /path/to/wreckfest2:/serverdata/serverfiles \
	your-repo/wreckfest2-server:latest
```

## Key Features
- **Persistent Game Installation**: Game files are stored in mounted volumes and won't be re-downloaded
- **Shared SteamCMD**: SteamCMD is also stored persistently to avoid re-downloading
- **Unraid Optimized**: Proper UID/GID handling for Unraid compatibility
- **Web Console**: Built-in web console for server management
- **Automatic Updates**: Server checks for updates on restart

This Docker is inspired by and based on the excellent work by (ich777)[https://github.com/ich777] (adapted)[https://github.com/ich777/docker-steamcmd-server/tree/wreckfest#] for Wreckfest 2.
Shoutout to (nvitaterna)[https://github.com/nvitaterna] for the early start.

