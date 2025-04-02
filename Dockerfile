FROM debian:bookworm-slim

RUN echo "deb http://deb.debian.org/debian bookworm contrib non-free non-free-firmware" > /etc/apt/sources.list

RUN apt update

RUN apt install -y wget gpg

# Install Wine

RUN dpkg --add-architecture i386

RUN mkdir -pm755 /etc/apt/keyrings

RUN wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -

RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources

RUN apt update

RUN apt install -y --install-recommends winehq-stable

RUN apt install -y winbind

# Install SteamCMD

RUN apt install -y software-properties-common

# not needed as we do this for wine, but keeping for reference
# RUN dpkg --add-architecture i386

# RUN apt update

RUN echo steam steam/question select "I AGREE" | debconf-set-selections

RUN echo steam steam/license note '' | debconf-set-selections

RUN apt install -y steamcmd

# Set up virtual display & tools

RUN apt install -y xserver-xorg-video-dummy

RUN apt install -y xdotool

RUN apt install -y xclip

# Set up steam stuff

RUN useradd -m steam

USER steam

WORKDIR /home/steam

# disable wine mono check
ENV WINEDLLOVERRIDES "mscoree="

ENV STEAMAPPDIR /home/steam/wf2-server

ENV SERVERCONFIGDIR /home/steam/wf2-config

ENV STEAMAPPID 3519390

ENV XLOGDIR /home/steam/logs/x

ENV WINELOGDIR /home/steam/logs/wine

ENV WFLOGFILEDIR /home/steam/logs/wf

ENV WRAPPERDIR /home/steam/wrapper

RUN mkdir -p ${STEAMAPPDIR} ${SERVERCONFIGDIR} ${XLOGDIR} ${WINELOGDIR} ${WFLOGFILEDIR} ${WRAPPERDIR}

COPY --chown=steam wrapper ${WRAPPERDIR}

COPY --chown=steam dummy-640x480.conf /home/steam/dummy-640x480.conf

COPY --chown=steam entry.sh /home/steam/entry.sh

EXPOSE 30100/udp

ENV EXPERIMENTAL_CONSOLE "0"

ENTRYPOINT [ "./entry.sh" ]