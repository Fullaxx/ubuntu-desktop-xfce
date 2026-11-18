#!/bin/bash
# This script runs as root
#
# user.sh: set up the desktop user
# Sourced by app.sh after imagestart.sh (system services) and before tiger.sh (VNC server).
#
# Without VNCUSER/VNCUID the desktop runs as root (HOME=/root).
#
# Variables:
#   VNCUSER   account name (required for a non-root desktop)
#   VNCUID    account UID (required for a non-root desktop)
#   VNCGROUP  primary group name (default: VNCUSER)
#   VNCGID    primary group GID (default: VNCUID)
#   ACCTPASS  optional password for the account (otherwise it stays locked)
#   VNCUMASK  optional umask, appended once to ~/.bashrc (root or the account)
#
# Why there are two paths:
# These scripts were written for ubuntu:22.04, which had no default user.
# Ubuntu 24.04 and later images ship a user named "ubuntu" (UID/GID 1000),
# and the old example VNCUSER=guest VNCUID=1000 collided with it.
# Accounts are never renamed or deleted, so a VNCUSER either exists or is created:
#
# 1) VNCUSER already exists: the built-in "ubuntu", or the account that a
#    previous start of this container created (docker restart).
#    It is used as is, and VNCUID (and VNCGROUP/VNCGID) must match it,
#    e.g. VNCUSER=ubuntu VNCUID=1000. A mismatch stops the container.
#
# 2) Any other VNCUSER: a new account is created.
#    VNCUID must be free and above 1000, e.g. VNCUSER=guest VNCUID=1001.
#    Its primary group is VNCGROUP if that exists (keeping its GID), else the
#    group that already has VNCGID, else a new group VNCGROUP/VNCGID.
#    It joins sudo (NOPASSWD rules in conf/sudo), audio (--device /dev/snd)
#    and video (/dev/dri), like the built-in "ubuntu" account.
#
# Errors print the reason (see docker logs) and stop the container (exit 1).
#
# For a non-root account, USER, GROUP and HOME are exported for tiger.sh.

if [ -n "${VNCUSER}" ] && [ -n "${VNCUID}" ]; then
# if VNCGROUP/VNCGID is unset, set it to VNCUSER/VNCUID
  VNCGROUP=${VNCGROUP:-$VNCUSER}
  VNCGID=${VNCGID:-$VNCUID}
# If the GROUP already exists, use the existing GID (Thanks to elisionducoeur)
  if getent group "${VNCGROUP}" >/dev/null; then
    VNCGID=$(getent group "${VNCGROUP}" | cut -d: -f3)
# If the GID exists, but the GROUP is incorrect, use the existing GROUP
  elif getent group "${VNCGID}" >/dev/null; then
    VNCGROUP=$(getent group "${VNCGID}" | cut -d: -f1)
  fi

  if getent passwd "${VNCUSER}" >/dev/null; then
# 1) Use the existing account as is: the variables must match it
    if [ "$(id -u "${VNCUSER}")" != "${VNCUID}" ] || [ "$(id -g "${VNCUSER}")" != "${VNCGID}" ]; then
      echo "ERROR: ${VNCUSER} already exists as $(id -u "${VNCUSER}"):$(id -gn "${VNCUSER}")($(id -g "${VNCUSER}"))," >&2
      echo "ERROR: but VNCUID/VNCGROUP/VNCGID ask for ${VNCUID}:${VNCGROUP}(${VNCGID})" >&2
      exit 1
    fi
  else
# 2) Create a new account with a free UID above 1000
    if [ "${VNCUID}" -le 1000 ] || getent passwd "${VNCUID}" >/dev/null; then
      echo "ERROR: VNCUID=${VNCUID} can't be used for a new account (${VNCUSER})," >&2
      echo "ERROR: choose a free VNCUID above 1000, or use VNCUSER=ubuntu VNCUID=1000" >&2
      exit 1
    fi
    getent group "${VNCGROUP}" >/dev/null || groupadd -g "${VNCGID}" "${VNCGROUP}" || exit 1
    useradd -u "${VNCUID}" -g "${VNCGID}" -G sudo,audio,video -s /bin/bash -m -d "/home/${VNCUSER}" "${VNCUSER}" || exit 1
  fi

  export USER="${VNCUSER}"
  export GROUP="${VNCGROUP}"
  if [ -n "${ACCTPASS}" ]; then
    echo "${VNCUSER}:${ACCTPASS}" | chpasswd
    unset ACCTPASS
  fi
fi

if [ -n "${USER}" ]; then
  HOME=$(getent passwd "${USER}" | cut -d: -f6)
  export HOME
fi

# $HOME should always be set at this point
# Set umask in all future bash shell instances
# (only append it once: the container may be restarted and $HOME may persist)
if [ -n "${VNCUMASK}" ]; then
  if ! grep -qx "umask ${VNCUMASK}" ${HOME}/.bashrc 2>/dev/null; then
    echo >> ${HOME}/.bashrc
    echo "umask ${VNCUMASK}" >> ${HOME}/.bashrc
  fi
fi
