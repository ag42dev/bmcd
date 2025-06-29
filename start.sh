#!/bin/bash

if [ "$EUID" -eq 0 ]; then
	chown -R "$BMCD_UID:$BMCD_GID" "${HOME}" /dist
	exec setpriv --reuid="$BMCD_UID" --regid="$BMCD_GID" --clear-groups "${HOME}/start.sh"
fi

function getbmds() { /usr/bin/steamcmd \
	+force_install_dir "${STEAMAPPDIR}" \
	+login anonymous \
	+app_update "${STEAMAPPID}" \
	validate +quit; }

until getbmds; do getbmds; done

mkdir -p "${HOME}/.steam/sdk32" ||:
ln -fs "${STEAMAPPDIR}/bin/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so"
cd "${STEAMAPPDIR}" ||:

BMCD_CFG="bms/cfg/server.cfg"
BMCD_MAPC="bms/mapcycle.txt"

if [[ ! -d bms/logs ]]; then
	tar xzf /dist/mmsource* -C bms
	tar xzf /dist/sourcemod* -C bms
	unzip -o /dist/accelerator* -d bms
	unzip -o /dist/SourceCoop* -d bms
fi

cat << EOF > $BMCD_CFG
hostname "${BMCD_HOSTNAME}"
sv_password "${BMCD_PW}"
rcon_password "${BMCD_RCONPW}"
sv_contact "${BMCD_CONTACT}"
mp_timelimit 0
mp_fraglimit 0
mp_teamplay 1
mp_forcerespawn 1
mp_friendlyfire 0
sv_alltalk 1
sv_cheats 0
sv_tags "custom, coop, sourcecoop"
//sourcecoop_ft FIRSTPERSON_DEATHCAM 1
sourcecoop_ft HEV_SOUNDS 1
sourcecoop_ft KEEP_EQUIPMENT 1
sourcecoop_ft NO_TELEFRAGGING 1
sourcecoop_ft NOBLOCK 1
sourcecoop_ft SHOW_WELCOME_MESSAGE 0
sourcecoop_ft AUTODETECT_MAP_END 1
sourcecoop_ft CHANGELEVEL_FX 1
sourcecoop_ft TRANSFER_PLAYER_STATE 1
sourcecoop_ft SP_WEAPONS 1
EOF

cat << EOF > $BMCD_MAPC
bm_c0a0a
bm_c1a0a
bm_c1a1a
bm_c1a2a
bm_c1a3a
bm_c1a4a
bm_c2a1a
bm_c2a1a
bm_c2a2a
bm_c2a3a
bm_c2a4a
bm_c2a4e
bm_c2a5a
bm_c3a1a
bm_c3a2a
bm_c4a1a
bm_c4a2a
bm_c4a3a
EOF

"${STEAMAPPDIR}/srcds_run" -game bms +ip 0.0.0.0 +log on \
	-port "${BMCD_PORT}" \
	-tickrate "${BMCD_TICKRATE}" \
	+maxplayers "${BMCD_MAXPLAYERS}" \
	+map "${BMCD_STARTMAP}" \
	"${ADDITIONAL_ARGS}"
