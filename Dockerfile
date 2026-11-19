# ------------------------------------------------------------------------------
# Base Image : Ubuntu 26.04 LTS (Resolute Raccoon)
# Support    : Apr 2026 - May 2031
FROM ubuntu:26.04
LABEL author="Brett Kuskie <fullaxx@gmail.com>"

# ------------------------------------------------------------------------------
# Set environment variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV WINDOWMANAGER="xfce4"

# ------------------------------------------------------------------------------
# Keep translations
# (the Ubuntu base image's dpkg excludes leave out every package's translations; without that line,
# the packages installed below and by the launcher scripts keep theirs, and menus and dialogs follow
# the desktop's locale)
RUN sed -e '\#^path-exclude=/usr/share/locale/#d' -i /etc/dpkg/dpkg.cfg.d/excludes

# ------------------------------------------------------------------------------
# Install tigervnc,xfce4,apps and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      adwaita-icon-theme-legacy \
      bzip2 \
      ca-certificates \
      curl \
      dbus \
      dbus-x11 \
      elementary-xfce-icon-theme \
      fonts-dejavu-core \
      fonts-noto-cjk \
      fonts-noto-core \
      greybird-gtk-theme \
      gtk2-engines-pixbuf \
      gvfs \
      less \
      libasound2t64 \
      libgtk2.0-0t64 \
      locales \
      nano \
      sudo \
      tigervnc-common \
      tigervnc-standalone-server \
      tigervnc-tools \
      tumbler \
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
# (en_US is the image's default: at startup, app/locale.sh switches to docker run's -e LOCALE, or else -e LANG)
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# ------------------------------------------------------------------------------
# Configure XTerm
RUN sed -e 's/saveLines: 1024/saveLines: 8192/' -i /etc/X11/app-defaults/XTerm

# ------------------------------------------------------------------------------
# Install scripts and configuration files
COPY app/*.sh /app/
COPY conf/xstartup /usr/share/ubuntu-desktop/vnc/
COPY conf/sudo /usr/share/ubuntu-desktop/sudo
COPY conf/bash.colors conf/color_prompt.sh /opt/bash/
COPY scripts/*.sh /app/scripts/

# ------------------------------------------------------------------------------
# Install xfce4 scripts and configuration files
# (/etc/xdg/autostart is only for .desktop files, the scripts go on PATH)
COPY xfce4/xfce4_autostart.sh xfce4/set_wallpaper_xfce4.sh /usr/local/bin/
COPY xfce4/xfce4_autostart.desktop /etc/xdg/autostart/
# System-wide default backdrop (user settings and WALLPAPER override it)
COPY xfce4/xfce4-desktop.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
# Stub pm-is-supported (pm-utils is not installed) so xfce4-session stops
# logging a failed check at every login and logout
COPY xfce4/pm-is-supported /usr/bin/
# Applications > Ubuntu Desktop: menu entries for a set of the launcher scripts in /app/scripts
# (one .desktop file per entry: delete a file from xfce4/menu/applications to drop its entry)
COPY xfce4/menu/ubuntu-desktop.menu /etc/xdg/menus/applications-merged/
COPY xfce4/menu/desktop-directories/ /usr/local/share/desktop-directories/
COPY xfce4/menu/applications/ /usr/local/share/applications/

# ------------------------------------------------------------------------------
# Expose ports
EXPOSE 5901

# ------------------------------------------------------------------------------
# Define default command
CMD ["/app/app.sh"]
