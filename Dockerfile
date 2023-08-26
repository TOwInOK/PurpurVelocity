# Build stage
FROM eclipse-temurin:20-jre-alpine AS build
RUN apk update && \
    apk add curl jq && \
    rm -rf /var/cache/apk/*

LABEL Velocity server

WORKDIR /opt/minecraft
COPY ./getvelocity.sh /
RUN chmod +x /getvelocity.sh
RUN /getvelocity.sh 

#Running environment
FROM eclipse-temurin:20-jre-alpine AS runtime
ARG TARGETARCH
# Download and copy the gosu binary for arm64
RUN set -eux; \
    apk add --no-cache curl && \
    curl -sL https://github.com/tianon/gosu/releases/download/1.16/gosu-amd64 -o /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Working directory
WORKDIR /data
COPY --from=build /opt/minecraft/velocity.jar /opt/minecraft/velocity.jar

#Rcon install
ARG TARGETARCH
ARG RCON_CLI_VER=1.6.0
ADD https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VER}/rcon-cli_${RCON_CLI_VER}_linux_${TARGETARCH}.tar.gz /tmp/rcon-cli.tgz
RUN mkdir -p /tmp/rcon-cli && \
    tar -x -C /tmp/rcon-cli -f /tmp/rcon-cli.tgz && \
    mv /tmp/rcon-cli/rcon-cli /usr/local/bin/ && \
    rm -rf /tmp/rcon-cli /tmp/rcon-cli.tgz && \
    apk del curl

# Volumes for the external data
VOLUME "/data"

# Main Port
EXPOSE 25565/tcp

ARG memory_size="128M"
ENV MEMORYSIZE=${memory_size}

# ZGC by default
ARG java_flags="-Djava.awt.headless=true -Dterminal.jline=false -Dterminal.ansi=true -XX:+UseZGC -XX:MaxGCPauseMillis=10 -XX:ActiveProcessorCount=1 -XX:+UseNUMA -XX:+AlwaysPreTouch -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:InitiatingHeapOccupancyPercent=20 -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=${java_flags}

WORKDIR /data

COPY /docker-entrypoint.sh /opt/minecraft
RUN chmod +x /opt/minecraft/docker-entrypoint.sh

# Entrypoint
ENTRYPOINT ["/opt/minecraft/docker-entrypoint.sh"]
