# CSGO containerized

The Dockerfile will build an image for running a Counter-Strike: Global Offensive dedicated server in a container.

This is a modified version of [kmallea/csgo](https://hub.docker.com/r/kmallea/csgo/) - removed some stuff and made it to just run a very specified csgo instance.

## How to Use

```bash
docker pull apetomate/csgo-server:latest
```

To use the image as-is, run it with a few useful environment variables to configure the server:

```bash
docker run \
  --rm \
  --interactive \
  --tty \
  --detach \
  --mount source=csgo-data,target=/home/steam/csgo \
  --network=host \
  --env "SERVER_HOSTNAME=hostname" \
  --env "SERVER_PASSWORD=password" \
  --env "RCON_PASSWORD=rconpassword" \
  --env "STEAM_ACCOUNT=gamelogintoken" \
  --env "AUTHKEY=webapikey" \
  --env "SOURCEMOD_ADMINS=STEAM_1:0:123456,STEAM_1:0:654321" \
  apetomate/csgo-server
```

Would you rather use a bind volume so that you can access file contents directly? Use `--mount type=bind,source=$(pwd),target=/home/steam/csgo` instead of the one in the example above.

If you plan on managing plugins manually with a bind volume, you might want pass an empty or reduced `INSTALL_PLUGINS` environment variable to prevent conflicts (see below for default value of `INSTALL_PLUGINS`).

### Required Game Login Token

The `STEAM_ACCOUNT` is a "Game Login Token" required by Valve to run public servers. Confusingly, this token is also referred to as a steam account (it's set via `sv_setsteamaccount`). To get one, visit https://steamcommunity.com/dev/managegameservers. You'll need one for each server.

Remember that if you DO NOT give a valid Game Login Token, your server will be restricted to LAN only

### Playing on LAN

If you're on a LAN, add the environment variable `LAN=1` (e.g., `--env "LAN=1"`) to have `sv_lan 1` set for you in the server.

### Environment variable overrides

Below are the default values for environment variables that control the server configuration. To override, pass one or more of these to docker using the `-e` or `--env` argument (example above).

```bash
SERVER_HOSTNAME=Counter-Strike: Global Offensive Dedicated Server
SERVER_PASSWORD=
RCON_PASSWORD=changeme
STEAM_ACCOUNT=changeme
AUTHKEY=changeme
IP=0.0.0.0
PORT=27015
TV_PORT=27020
TICKRATE=128
FPS_MAX=400
GAME_TYPE=0
GAME_MODE=1
MAP=de_dust2
MAPGROUP=mg_active
HOST_WORKSHOP_COLLECTION=
WORKSHOP_START_MAP=
MAXPLAYERS=12
TV_ENABLE=1
LAN=0
SOURCEMOD_ADMINS=
RETAKES=0
NOMASTER=0
```

For compatibility with the [Docker secrets](https://docs.docker.com/engine/swarm/secrets/) feature the following 
environment variables are also available as a '_FILE' variant.

```bash
SERVER_PASSWORD_FILE
RCON_PASSWORD_FILE
STEAM_ACCOUNT_FILE
AUTHKEY_FILE
SOURCEMOD_ADMINS_FILE
```

If one of these is set the content of the referred file is used as content for the non-'_FILE" environment variable. If both
environment variables are set, the content of the non-'_FILE' variable takes precedence.

Usage of _FILE variables allows constructs like this in docker compose files:

```yml
version: "3.7"
services:
  app:
    image: kmallea/csgo
    secrets:
      - csgo_rcon_password
    environment:
      - RCON_PASSWORD_FILE=/run/secrets/csgo_rcon_password

secrets:
  csgo_rcon_password:
    file: ${SECRETS_DIR}/csgo_rcon_password.txt
```

### Troubleshooting

If you're unable to use [`--network=host`](https://docs.docker.com/network/host/), you'll need to publsh the ports instead, e.g.:

```bash
docker run \
  --rm \
  --interactive \
  --tty \
  --detach \
  --mount source=csgo-data,target=/home/steam/csgo \
  --publish 27015:27015/tcp \
  --publish 27015:27015/udp \
  --publish 27020:27020/tcp \
  --publish 27020:27020/udp \
  --env "SERVER_HOSTNAME=hostname" \
  --env "SERVER_PASSWORD=password" \
  --env "RCON_PASSWORD=rconpassword" \
  --env "STEAM_ACCOUNT=gamelogintoken" \
  --env "AUTHKEY=webapikey" \
  --env "SOURCEMOD_ADMINS=STEAM_1:0:123456,STEAM_1:0:654321" \
  kmallea/csgo
```

## Manually Building

```bash
docker build -t csgo-dedicated-server .
```

_OR_

```bash
make
```

The game data is downloaded on first run (~26GB). Mount a volume to preserve game data if you need to recreate the container. The volume's target should be `/home/steam/csgo`. In these example I use a data volume, but you can use a bind volume as well since plugins are installed during container startup.

### Overriding versions of SteamCMD, Metamod, SourceMod, and/or PugSetup

#### SteamCMD

SteamCMD is installed directly into the image at build time. To override the URL it installs from, pass in a build arg named `STEAMCMD_URL`:

```bash
docker build \
  -t $(IMAGE_NAME) \
  --build-arg STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
  .
```