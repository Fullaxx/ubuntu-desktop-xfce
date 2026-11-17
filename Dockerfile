# ------------------------------------------------------------------------------
# Base Image : Ubuntu 26.04 LTS (Resolute Raccoon)
# Support    : Apr 2026 - May 2031
FROM ubuntu:26.04
LABEL author="Brett Kuskie <fullaxx@gmail.com>"

# ------------------------------------------------------------------------------
# Set environment variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV WINDOWMANAGER="xfce4"
ENV LOCALE="en_US"

# ------------------------------------------------------------------------------
# Install tigervnc,xfce4 and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bzip2 \
      ca-certificates \
      curl \
      dbus \
      dbus-x11 \
      less \
      libasound2t64 \
      libgtk2.0-0t64 \
      locales \
      nano \
      sudo \
      tigervnc-common \
      tigervnc-standalone-server \
      tigervnc-tools \
      tzdata \
      wget \
      x11-utils \
      x11-xserver-utils \
      xfce4 \
      xfce4-goodies \
      xfonts-base \
      xterm \
      xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ------------------------------------------------------------------------------
# Configure locale
RUN echo "LC_ALL=${LOCALE}.UTF-8" >> /etc/environment && \
    echo "LANG=${LOCALE}.UTF-8" > /etc/locale.conf && \
    echo "${LOCALE}.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# ------------------------------------------------------------------------------
# Configure XTerm
RUN sed -e 's/saveLines: 1024/saveLines: 8192/' -i /etc/X11/app-defaults/XTerm

# ------------------------------------------------------------------------------
# Install scripts and configuration files
COPY app/app.sh app/imagestart.sh app/tiger.sh /app/
COPY conf/xstartup /usr/share/ubuntu-desktop/vnc/
COPY conf/sudo /usr/share/ubuntu-desktop/sudo
COPY conf/bash.colors conf/color_prompt.sh /opt/bash/
COPY scripts/*.sh /app/scripts/

# ------------------------------------------------------------------------------
# Install xfce4 scripts and configuration files
# COPY xfce4/* /root/.config/autostart/

# ------------------------------------------------------------------------------
# Expose ports
EXPOSE 5901

# ------------------------------------------------------------------------------
# Define default command
CMD ["/app/app.sh"]
