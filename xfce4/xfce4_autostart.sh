#!/bin/bash

# Started at xfce4 login by /etc/xdg/autostart/xfce4_autostart.desktop
# (VNCUMASK is applied to the whole session in xstartup)

# https://github.com/jessfraz/dockerfiles/issues/4
# Allow root (sudo, docker exec) to use this display.
# si:localuser:root admits only root; the old "local:root" admitted every local user.
xhost +si:localuser:root

# if WALLPAPER/WPLAYOUT were set at docker cmdline
if [ -n "${WALLPAPER}" ]; then
  /usr/local/bin/set_wallpaper_xfce4.sh "${WALLPAPER}" "${WPLAYOUT}"
fi
