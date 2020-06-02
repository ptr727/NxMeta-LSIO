# Use LSIO Ubuntu Bionic version
FROM lsiobase/ubuntu:bionic

# Beta versions are listed under the patches section:
# https://meta.nxvms.com/downloads/patches
ARG DOWNLOAD_URL="http://updates.networkoptix.com/metavms/30731/linux/metavms-server-4.1.0.30731-linux64-beta-prod.deb"
ARG DOWNLOAD_VERSION="4.1.0.30731 R5"

# Prevent EULA and confirmation prompts in installers
ENV DEBIAN_FRONTEND=noninteractive \
# NxWitness (networkoptix) or DWSpectrum (digitalwatchdog) or NxMeta (networkoptix-metavms)
    COMPANY_NAME="networkoptix-metavms"

LABEL name="NxMeta-LSIO" \
    version=${DOWNLOAD_VERSION} \
    download=${DOWNLOAD_URL} \
    description="NxMeta IPVMS Docker based on LinuxServer" \
    maintainer="Pieter Viljoen <ptr727@users.noreply.github.com>"

# Install tools
RUN apt-get update \
    && apt-get install --yes \
        mc \
        nano \
        strace \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download the DEB installer file
RUN wget -nv -O ./vms_server.deb ${DOWNLOAD_URL}

# Replace the LSIO abc usernames with the mediaserver names
# The mediaserver calls "chown ${COMPANY_NAME}" at runtime
# We have to match the ${COMPANY_NAME} username with the LSIO "abc" usernames
# https://github.com/linuxserver/docker-baseimage-alpine/blob/master/root/etc/cont-init.d/10-adduser
# Change user "abc" to ${COMPANY_NAME}
RUN usermod -l ${COMPANY_NAME} abc \
# Change group "abc" to ${COMPANY_NAME}
    && groupmod -n ${COMPANY_NAME} abc \
# Replace "abc" with ${COMPANY_NAME}
    && sed -i "s/abc/\${COMPANY_NAME}/g" /etc/cont-init.d/10-adduser

# Install the mediaserver
# Add missing dependencies (gdb)
# Remove root tool to prevent it from being used in service mode
RUN apt-get update \
    && apt-get install --yes \
        gdb \
        ./vms_server.deb \
    && apt-get clean \
    && rm -rf /opt/${COMPANY_NAME}/mediaserver/bin/root-tool-bin \
    && rm -rf /var/lib/apt/lists/*

# Cleanup
RUN rm -rf ./vms_server.deb

# Copy etc init and services files
# The scripts are using the ${COMPANY_NAME} global environment variable
# https://github.com/just-containers/s6-overlay#container-environment
COPY root/etc /etc

# Expose port 7001
EXPOSE 7001

# Create mount points
# Links will be created at runtime in the etc/cont-init.d/50-relocate-files script
# /opt/digitalwatchdog/mediaserver/etc -> /config/etc
# /opt/digitalwatchdog/mediaserver/var -> /config/var
# /opt/digitalwatchdog/mediaserver/var/data -> /media
# /config is for configuration
# /media is for media recording
# /archive is for media backups
VOLUME /config /media /archive
