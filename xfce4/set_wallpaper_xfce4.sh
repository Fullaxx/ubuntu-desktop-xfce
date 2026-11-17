#!/bin/bash

if [ -z "$1" ]; then
  echo "$0: <wallpaper> [layout]"
  exit 1
fi

case "$1" in
  1) WPURL="https://images.rapidlinux.org/udwp/metallurgy1HDfree.jpg" ;;
  2) WPURL="https://images.rapidlinux.org/udwp/portals1HDfree.jpg" ;;
  3) WPURL="https://images.rapidlinux.org/udwp/cronusrising2k141HDfree.jpg" ;;
  4) WPURL="https://images.rapidlinux.org/udwp/harbinger2k91HDfree.jpg" ;;
  5) WPURL="https://images.rapidlinux.org/udwp/arcana2HDfree.jpg" ;;
  6) WPURL="https://images.rapidlinux.org/udwp/rivenHDfree.jpg" ;;
  7) WPURL="https://images.rapidlinux.org/udwp/circularlogicHDfree.jpg" ;;
  8) WPURL="https://images.rapidlinux.org/udwp/gardener2k121HDfree.jpg" ;;
  9) WPURL="https://images.rapidlinux.org/udwp/overseer2k141_single_1920x1080.jpg" ;;
  *) echo "$0: unknown wallpaper: $1" >&2; exit 1 ;;
esac

# Same layout names as ubuntu-desktop's set_wallpaper.sh (hsetroot), mapped to
# xfdesktop image-style: 1=centered 2=tiled 3=stretched 4=scaled 5=zoomed
case "$2" in
    "fill") WPSTYLE="3" ;;
  "extend") WPSTYLE="4" ;;
    "full") WPSTYLE="4" ;;
    "tile") WPSTYLE="2" ;;
   "cover") WPSTYLE="5" ;;
  "center") WPSTYLE="1" ;;
         *) WPSTYLE="1" ;;
esac

# Keep the image on disk, xfdesktop reloads it on every redraw/resize/login
WPDIR="${XDG_DATA_HOME:-${HOME}/.local/share}/backgrounds"
WPIMG="${WPDIR}/udwp${1}.jpg"
if [ ! -s "${WPIMG}" ]; then
  mkdir -p "${WPDIR}"
  if ! wget -q -T 20 -t 2 "${WPURL}" -O "${WPIMG}.tmp"; then
    echo "$0: failed to download ${WPURL}" >&2
    rm -f "${WPIMG}.tmp"
    exit 1
  fi
  mv "${WPIMG}.tmp" "${WPIMG}"
fi

# Set the backdrop of each monitor (Xtigervnc has one, named VNC-0)
# -n creates the properties, a fresh session does not have them yet
# workspace0 covers every workspace in xfdesktop's default single-workspace mode
MONITORS=`xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $NF}'`
for MON in ${MONITORS:-VNC-0}; do
  PROP="/backdrop/screen0/monitor${MON}/workspace0"
  xfconf-query -c xfce4-desktop -p "${PROP}/image-style" -n -t int -s "${WPSTYLE}"
  xfconf-query -c xfce4-desktop -p "${PROP}/last-image" -n -t string -s "${WPIMG}"
done
