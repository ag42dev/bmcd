FROM steamcmd/steamcmd AS build_stage
LABEL maintainer="ag42.online"

ENV STEAMAPPID=346680 \
	HOME="/home/ubuntu" \
	STEAMAPPDIR="/home/ubuntu/bmcd"

ARG SRC_MMS="https://mms.alliedmods.net/mmsdrop/1.12/mmsource-1.12.0-git1219-linux.tar.gz" \
	SRC_SM="https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7163-linux.tar.gz" \
	SRC_ACC="https://builds.limetech.io/files/accelerator-2.5.0-git138-cd575aa-linux.zip" \
	SRC_SC="https://github.com/ampreeT/SourceCoop/releases/download/v1.5-beta2/SourceCoop-1.5-beta2-bms.zip"

COPY start.sh "${HOME}"

# Addons versions according to
# https://github.com/ampreeT/SourceCoop/blob/master/scripts/srccoop-bms-linux-install.sh
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		ca-certificates lib32gcc-s1 lib32stdc++6 nano qstat unzip wget \
	&& mkdir -p "${STEAMAPPDIR}" /dist \
	&& wget -P /dist -q -t2 -T30 "${SRC_MMS}" "${SRC_SM}" "${SRC_ACC}" "${SRC_SC}" \
	&& chmod +x "${HOME}/start.sh" \
	&& apt-get -y autoremove --purge \
	&& rm -rf /var/lib/apt/lists/*

FROM build_stage AS run_stage

WORKDIR "${HOME}"
VOLUME "${STEAMAPPDIR}"
ENV BMCD_PORT=27015 \
	BMCD_TICKRATE=128 \
	BMCD_MAXPLAYERS=32 \
	BMCD_HOSTNAME="New Black Mesa Co-op Server" \
	BMCD_RCONPW="" \
	BMCD_PW="" \
	BMCD_STARTMAP="bm_c0a0a" \
	BMCD_CONTACT="" \
	BMCD_UID="1000" \
	BMCD_GID="1000" \
	BMCD_CFG_CTRL_DOCKER=1 \
	ADDITIONAL_ARGS=""

ENTRYPOINT [""]
CMD ["bash", "start.sh"]

HEALTHCHECK --interval=60s --timeout=30s --start-period=3000s --retries=5 \
	CMD quakestat -R -timeout 30 -a2s localhost:${BMCD_PORT:-27015} | grep -q "dedicated=1" || exit 1
