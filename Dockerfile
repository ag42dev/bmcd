FROM cm2network/steamcmd:root AS build_stage
LABEL maintainer="ag42.online"

ENV STEAMAPPID=346680 STEAMAPPDIR="${HOMEDIR}/bmcd"

COPY start.sh "${HOMEDIR}"

# Addons versions according to
# https://github.com/ampreeT/SourceCoop/blob/master/scripts/srccoop-bms-linux-install.sh
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		ca-certificates lib32gcc-s1 lib32stdc++6 unzip wget \
	&& mkdir -p "${STEAMAPPDIR}" /dist \
	&& wget -P /dist -q -t2 -T30 https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148-linux.tar.gz \
	&& wget -P /dist -q -t2 -T30 https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7163-linux.tar.gz \
	&& wget -P /dist -q -t2 -T30 https://builds.limetech.io/files/accelerator-2.5.0-git138-cd575aa-linux.zip \
	&& wget -P /dist -q -t2 -T30 https://github.com/ampreeT/SourceCoop/releases/download/v1.5-beta2/SourceCoop-1.5-beta2-bms.zip \
	&& { \
		echo '@ShutdownOnFailedCommand 1'; \
		echo '@NoPromptForPassword 1'; \
		echo 'force_install_dir '"${STEAMAPPDIR}"''; \
		echo 'login anonymous'; \
		echo 'app_update '"${STEAMAPPID}"' validate'; \
		echo 'quit'; \
	   } > "${HOMEDIR}/bmds_update" \
	&& chmod +x "${HOMEDIR}/start.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}" /dist \
	&& apt-get -y autoremove --purge \
	&& rm -rf /var/lib/apt/lists/*

FROM build_stage AS run_stage

USER ${USER}
WORKDIR ${HOMEDIR}
VOLUME ${STEAMAPPDIR}

ENV BMCD_PORT=27015 \
	BMCD_TICKRATE=100 \
	BMCD_MAXPLAYERS=32 \
	BMCD_HOSTNAME="New Black Mesa Co-op Server" \
	BMCD_RCONPW="" \
	BMCD_PW="" \
	BMCD_STARTMAP="bm_c0a0a" \
	BMCD_CONTACT="" \
	ADDITIONAL_ARGS=""

CMD ["bash", "start.sh"]
