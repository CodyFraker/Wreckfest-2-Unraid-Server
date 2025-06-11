FROM ich777/winehq-baseimage

LABEL org.opencontainers.image.authors="codyfraker@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/CodyFraker/Wreckfest-2-Unraid-Server"

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get -y install --no-install-recommends lib32gcc-s1 screen xvfb winbind net-tools wine32 && \
	rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
	tar -C /usr/bin/ -xvf /tmp/gotty.tar.gz && \
	rm -rf /tmp/gotty.tar.gz

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_ID="3519390"
ENV GAME_PARAMS=""
ENV VALIDATE=""
ENV ENABLE_WEBCONSOLE="true"
ENV GOTTY_PARAMS="--permit-write --title-format Wreckfest2-Console"
ENV DEBUG_MODE="false"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV USERNAME=""
ENV PASSWRD=""
ENV USER="steam"
ENV TERM=xterm
ENV DATA_PERM=770

RUN mkdir $DATA_DIR && \
	mkdir $STEAMCMD_DIR && \
	mkdir $SERVER_DIR && \
	if [ "$USER" != "root" ]; then useradd -d $DATA_DIR -s /bin/bash $USER; fi && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

# Copy config files
COPY server_config.scnf ${SERVER_DIR}/server_config.scnf

EXPOSE 30100/udp 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]