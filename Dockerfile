FROM steamcmd/steamcmd AS build_stage
LABEL maintainer="ag42.online"

ENV STEAMAPPID=346680 \
	HOME="/home/ubuntu" \
	STEAMAPPDIR="/home/ubuntu/bmcd"

ARG SRC_MMS="https://api.github.com/repos/alliedmodders/metamod-source/releases/latest" \
	SRC_SM="https://api.github.com/repos/alliedmodders/sourcemod/releases/latest" \
	SRC_ACC="https://builds.limetech.io/?p=accelerator" \
	SRC_SC="https://github.com/ampreeT/SourceCoop/releases/download/v1.7-beta1/SourceCoop-1.7-dev-bms-build597.zip"

COPY start.sh "${HOME}"

# Addons versions according to
# https://github.com/ampreeT/SourceCoop/blob/master/scripts/srccoop-bms-linux-install.sh
RUN set -x -o pipefail \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		ca-certificates lib32gcc-s1 lib32stdc++6 nano qstat unzip wget \
	&& mkdir -p "${STEAMAPPDIR}" /dist \
	&& URL_MMS=$(wget -qO- -t2 -T30 "${SRC_MMS}" | grep -o '"browser_download_url": *"[^"]*-linux\.tar\.gz"' | cut -d '"' -f 4 | sed -n 1p) \
	&& URL_SM=$(wget -qO- -t2 -T30 "${SRC_SM}" | grep -o '"browser_download_url": *"[^"]*-linux\.tar\.gz"' | cut -d '"' -f 4 | sed -n 1p) \
	&& URL_ACC=https://builds.limetech.io/$(wget -qO- -t2 -T30 "${SRC_ACC}" | grep -o 'files/accelerator-[^"]*-linux\.zip' | sed -n 1p) \
	&& wget -P /dist -q -t2 -T30 "${URL_MMS}" "${URL_SM}" "${URL_ACC}" "${SRC_SC}" \
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
	ADDITIONAL_ARGS=""

ENTRYPOINT [""]
CMD ["bash", "start.sh"]

HEALTHCHECK --interval=60s --timeout=30s --start-period=3000s --retries=5 \
	CMD quakestat -R -timeout 30 -a2s "$(hostname -i):${BMCD_PORT:-27015}" | grep -q "dedicated=1" || exit 1
