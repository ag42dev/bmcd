# Black Mesa Co-op in Docker <img align="right" height="96" src="bmcd.png" alt="Black Mesa Co-op in Docker" />
[![bmcd](https://github.com/ag42dev/bmcd/actions/workflows/docker.yml/badge.svg?event=push)](https://github.com/ag42dev/bmcd/pkgs/container/bmcd)

## About
Docker image for [Black Mesa](https://store.steampowered.com/app/362890) dedicated server with cooperative gamemode using [SourceCoop](https://github.com/ampreeT/SourceCoop). Required disk space for gameserver files is 30 Gb.

## Quick run
```
install -d /opt/bmcd -o 1000 -g 1000 && \
docker run -d \
	--name bmcd \
	--restart unless-stopped \
	-p 27015:27015 \
	-p 27015:27015/udp \
	-v /opt/bmcd:/home/steam/bmcd \
	-e BMCD_HOSTNAME="New Black Mesa Co-op Server" \
	-e BMCD_PW="" \
ghcr.io/ag42dev/bmcd
```

## Environment

| Variable="Default Value" | Description |
| :----: | --- |
| `BMCD_PORT=27015` | Game port. If not default, should be set along with docker port mapping |
| `BMCD_TICKRATE=100` | Server tickrate |
| `BMCD_MAXPLAYERS=32` | Maximum players |
| `BMCD_HOSTNAME="New Black Mesa Co-op Server"` | Server name |
| `BMCD_RCONPW=""` | RCON password |
| `BMCD_PW=""` | Server password |
| `BMCD_STARTMAP="bm_c0a0a"` | Start map |
| `BMCD_CONTACT=""` | Your contact |
| `ADDITIONAL_ARGS=""` | Additional arguments passed to `srcds_run` |

## Image contents
* [SteamCMD](https://hub.docker.com/r/cm2network/steamcmd) base image
	* [BMDS](https://steamdb.info/app/346680)
* [MM:S](https://www.metamodsource.net)
	* [SM](https://www.sourcemod.net)
		* [Accelerator](https://builds.limetech.io/?p=accelerator)
		* [SC](https://github.com/ampreeT/SourceCoop)
