FROM ubuntu:bionic

ENV TERM xterm

ENV STEAM_DIR "/opt/steam"
ENV STEAMCMD_DIR "/opt/steam/steamcmd"
ENV CSGO_APP_ID 740
ENV CSGO_DIR "/opt/steam/csgo"
ENV USECONFIG "butterlan.cfg"
ENV GAMEMODESURL "https://raw.githubusercontent.com/apefrei/butterlan-gameserver-configs/main/csgo/gamemodes_server.txt"
ENV CONFIGURL "https://raw.githubusercontent.com/apefrei/butterlan-gameserver-configs/main/csgo/butterlan.cfg"

SHELL ["/bin/bash", "-c"]

ARG STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz

RUN set -xo pipefail \
      && apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
          lib32gcc1 \
          lib32stdc++6 \
          lib32z1 \
          ca-certificates \
          net-tools \
          locales \
          curl \
          unzip \
      && locale-gen en_US.UTF-8 \
      && mkdir -p ${STEAMCMD_DIR} \
      && cd ${STEAMCMD_DIR} \
      && curl -sSL ${STEAMCMD_URL} | tar -zx -C ${STEAMCMD_DIR} \
      && mkdir -p ${STEAM_DIR}/.steam/sdk32 \
      && ln -s ${STEAMCMD_DIR}/linux32/steamclient.so ${STEAM_DIR}/.steam/sdk32/steamclient.so \
      && { \
            echo '@ShutdownOnFailedCommand 1'; \
            echo '@NoPromptForPassword 1'; \
            echo 'login anonymous'; \
            echo 'force_install_dir ${CSGO_DIR}'; \
            echo 'app_update ${CSGO_APP_ID}'; \
            echo 'quit'; \
        } > ${STEAM_DIR}/autoupdate_script.txt \
      && mkdir -p ${CSGO_DIR}/csgo/cfg \
      && chown root -R ${STEAM_DIR} \
      && chmod 755 -R ${STEAM_DIR} \
      && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN curl ${GAMEMODESURL} --output ${CSGO_DIR}/csgo/gamemodes_server.txt
RUN curl ${CONFIGURL} --output ${CSGO_DIR}/csgo/cfg/butterlan.cfg

COPY start.sh ${STEAM_DIR}/

USER root
WORKDIR ${CSGO_DIR}
VOLUME ${CSGO_DIR}
ENTRYPOINT exec ${STEAM_DIR}/start.sh
