# Ubuntu Desktop running Xfce4 in VNC

## Base Docker Image
[Ubuntu](https://hub.docker.com/_/ubuntu) 26.04/24.04 (x64)

## Branches and tags
Each branch publishes its own tags of `ghcr.io/fullaxx/ubuntu-desktop-xfce`, rebuilt at every push:

| Tag | Branch | Ubuntu | Xfce |
| --- | --- | --- | --- |
| `:latest`, `:26.04` | [`master`](https://github.com/Fullaxx/ubuntu-desktop-xfce/tree/master) | 26.04 (resolute) | 4.20 |
| `:24.04` | [`24.04`](https://github.com/Fullaxx/ubuntu-desktop-xfce/tree/24.04) | 24.04 (noble) | 4.18 |

- `:latest` tracks 26.04: every push to `master` publishes the same image as `:latest` and `:26.04`.
- `24.04` gets the changes that apply to Ubuntu 24.04. Its README uses `:24.04` in every example.
- Every build is also tagged `<branch>-<short commit>`, such as `:24.04-1ae62ad`. These tags never move.
- The examples below use `:latest`. Everything in this README works the same with `:26.04` or `:24.04`.

## Get the image or build it locally
```
docker pull ghcr.io/fullaxx/ubuntu-desktop-xfce
docker pull ghcr.io/fullaxx/ubuntu-desktop-xfce:26.04
docker pull ghcr.io/fullaxx/ubuntu-desktop-xfce:24.04

docker build -t="ghcr.io/fullaxx/ubuntu-desktop-xfce" https://github.com/Fullaxx/ubuntu-desktop-xfce.git
docker build -t="ghcr.io/fullaxx/ubuntu-desktop-xfce:24.04" https://github.com/Fullaxx/ubuntu-desktop-xfce.git#24.04
```

## VNC Options
Optional: Set Depth 16 \
Default: 24
```
-e VNCDEPTH='16'
```
Optional: Set 1920x1080 Resolution \
Default: 1280x800
```
-e VNCRES='1920x1080'
```
Optional: Bind to Port 5909 \
Default: port 5901
```
-e VNCPORT='9'
```
Optional: Set Password Authentication \
Default: No Authentication
```
-e VNCPASS='vncpass'
```
Optional: Set Read-Write and Read-Only password \
Default: No Authentication
```
-e VNCPASS='vncpass' -e VNCPASSRO='readonly'
```
Optional: Run as a non-root user (see [Non-root users](#non-root-users)) \
Default: root (UID: 0)
```
-e VNCUSERMAP='guest/1001'
```
Optional: Set the primary group of a new non-root user \
Default: same name and number as VNCUSERMAP \
Pre-Req: VNCUSERMAP must be set; the group is created, its GID must be free and greater than 1000
```
-e VNCGROUPMAP='guests/1002'
```
Optional: Set a password for the non-root user \
Default: none and the account is locked \
Pre-Req: VNCUSERMAP must be set
```
-e ACCTPASS='mysecretpassword'
```
Optional: Set umask to define permission for new files \
Default: 0022 for root, 0002 for a non-root user whose group has the same name
```
-e VNCUMASK='0002'
```

## Non-root users
Ubuntu 24.04 and later images (this one is 26.04) already contain a user named `ubuntu` with UID and GID 1000.
The startup scripts were written for Ubuntu 22.04, which had no such user, so the old example
`-e VNCUSER='guest' -e VNCUID='1000'` collided with it and the container exited.
There are now two distinct ways to run as a non-root user, each set with `VNCUSERMAP=name/uid`
(and optionally `VNCGROUPMAP=name/gid` for the primary group).

Use the built-in `ubuntu` account as is \
The maps must match it (VNCGROUPMAP, if set, must be ubuntu/1000)
```
-e VNCUSERMAP='ubuntu/1000'
```
Create your own account with any other name \
Its UID and GID must be free and greater than 1000, and its group is created too \
It joins the sudo, audio and video groups, like the built-in account
```
-e VNCUSERMAP='guest/1001'
-e VNCUSERMAP='guest/1001' -e VNCGROUPMAP='guests/1002'
```
Anything else, such as `-e VNCUSERMAP='guest/1000'`, stops the container, and `docker logs` explains why.

`VNCUSER`, `VNCUID`, `VNCGROUP` and `VNCGID` were replaced by `VNCUSERMAP` and `VNCGROUPMAP`. \
A container started with only the old variables runs as root and shows a notice in the desktop and in `docker logs`.

## TimeZone Configuration
Set the timezone to be used inside the container (it also sets /etc/localtime) \
Default: UTC \
A name that isn't in /usr/share/zoneinfo is reported in `docker logs`; all the details: [LOCALE.md](LOCALE.md#time-zone-tz)
```
-e TZ='Asia/Tokyo'
-e TZ='Europe/London'
-e TZ='America/Los_Angeles'
-e TZ='America/Denver'
-e TZ='America/Chicago'
-e TZ='America/New_York'
```

## Locale Configuration
Set the language of menus and dialogs, and how dates, times and numbers are written \
All the details, more examples and how it works: [LOCALE.md](LOCALE.md)

Optional: Set the locale \
Default: en_US (English, 11/19/2026, 03:12:31 PM, 1,234,567.89) \
Fonts for Chinese, Japanese, Korean, the Indian scripts, Thai and every other script the translations use are built in: [LOCALE.md](LOCALE.md#fonts)
```
-e LOCALE='en_GB'
-e LOCALE='de_DE'
-e LOCALE='fr_FR'
-e LOCALE='es_MX'
-e LOCALE='pt_BR'
-e LOCALE='ru_RU'
-e LOCALE='zh_CN'
-e LOCALE='ja_JP'
-e LOCALE='hi_IN'
```
Optional: Set the locale with LANG instead, so that `docker exec` shells use it too \
Default: en_US.UTF-8 in the desktop, none (ASCII only) in `docker exec` shells \
Write it with .UTF-8; if LOCALE is set too, LOCALE wins
```
-e LANG='de_DE.UTF-8'
-e LANG='fr_FR.UTF-8'
```
Optional: Set only the language of menus and dialogs, and keep the locale's dates and numbers \
Default: the locale's language
```
-e LOCALE='de_DE' -e LANGUAGE='en'
-e LANGUAGE='de'
```
Use these instead of LC_ALL, LC_TIME and the other LC_ variables, which don't work here: [LOCALE.md](LOCALE.md#dont)

## Wallpaper Configuration
Set a background image for the Xfce desktop \
Default: None \
Image Links:
[1](https://images.rapidlinux.org/udwp/metallurgy1HDfree.jpg) /
[2](https://images.rapidlinux.org/udwp/portals1HDfree.jpg) /
[3](https://images.rapidlinux.org/udwp/cronusrising2k141HDfree.jpg) /
[4](https://images.rapidlinux.org/udwp/harbinger2k91HDfree.jpg) /
[5](https://images.rapidlinux.org/udwp/arcana2HDfree.jpg) /
[6](https://images.rapidlinux.org/udwp/rivenHDfree.jpg) /
[7](https://images.rapidlinux.org/udwp/circularlogicHDfree.jpg) /
[8](https://images.rapidlinux.org/udwp/gardener2k121HDfree.jpg) /
[9](https://images.rapidlinux.org/udwp/overseer2k141_single_1920x1080.jpg) \
Layout Options: fill / extend / full / tile / cover / center \
Default Layout: center
```
-e WALLPAPER='1'
-e WALLPAPER='3'
-e WALLPAPER='5' -e WPLAYOUT='cover'
```
Change the wallpaper from a terminal inside the running desktop
```
set_wallpaper_xfce4.sh 5 cover
```

## Sound Configuration (to support audio)
Passthrough for audio devices inside the container
```
--device /dev/snd
or
--privileged
```

## FUSE Configuration (to support AppImages)
Set privileges to allow FUSE to work properly inside the container
```
--device /dev/fuse --cap-add SYS_ADMIN
```

## Privileged Mode (to support FlatPak)
Set privileged mode to allow FlatPaks to work properly inside the container
```
--privileged
```

## Shared Memory Modification (to support Web Browsers)
Increase the size of shared memory to prevent web browsers from crashing \
Thanks to [jlesage](https://hub.docker.com/r/jlesage/firefox/#increasing-shared-memory-size)
```
--shm-size 2g
```

## Run the image
Run the image on localhost port 5901 with default configuration
```
docker run -d -p 127.0.0.1:5901:5901 ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image with Depth 16
```
docker run -d -p 127.0.0.1:5901:5901 -e VNCDEPTH='16' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image with 1920x1080 Resolution
```
docker run -d -p 127.0.0.1:5901:5901 -e VNCRES='1920x1080' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image with Password Authentication
```
docker run -d -p 127.0.0.1:5901:5901 -e VNCPASS='vncpass' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image with Read-Write and Read-Only password (Using R/O pass requires R/W pass)
```
docker run -d -p 127.0.0.1:5901:5901 -e VNCPASS='vncpass' -e VNCPASSRO='readonly' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image as the built-in ubuntu user account
```
docker run -d -p 127.0.0.1:5901:5901 -e VNCUSERMAP='ubuntu/1000' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image as a new non-root user account
```
docker run -d -p 127.0.0.1:5901:5901 -e VNCUSERMAP='guest/1001' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image as a new non-root user account with custom group
```
docker run -d -p 127.0.0.1:5901:5901 -e VNCUSERMAP='guest/1001' -e VNCGROUPMAP='guests/1002' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image in Tokyo
```
docker run -d -p 127.0.0.1:5901:5901 -e TZ='Asia/Tokyo' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image in Berlin, with German menus, dates and numbers
```
docker run -d -p 127.0.0.1:5901:5901 -e TZ='Europe/Berlin' -e LOCALE='de_DE' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image with FUSE privileges
```
docker run --device /dev/fuse --cap-add SYS_ADMIN -d -p 127.0.0.1:5901:5901 ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image using host networking binding tigervncserver to port 5909
```
docker run -d --network=host -e VNCPORT='9' ghcr.io/fullaxx/ubuntu-desktop-xfce
```
Run the image on localhost port 5901 with a decent hostname
```
docker run -d -h mycagedbuntu -p 127.0.0.1:5901:5901 ghcr.io/fullaxx/ubuntu-desktop-xfce
```

## Connect using vncviewer or a web browser
Use any standard VNC client to connect directly. \
For web access, check out [noVNC](https://hub.docker.com/r/fullaxx/novnc) to access your ubuntu-desktop with a web browser.
```
vncviewer 127.0.0.1:5901
```

## Using the Xfce Desktop Environment
Open Applications > Ubuntu Desktop (the panel menu at the top left, or right-click the desktop) to start popular applications. \
Each entry runs one of the convenience scripts in /app/scripts, which installs its application the first time (in xterm windows), then starts it.

Many more convenience scripts are available (see the list in [ubuntu-desktop](https://github.com/Fullaxx/ubuntu-desktop#using-the-openbox-desktop-environment)), though some don't support Ubuntu 26.04 yet. \
Run any of them from a terminal inside the desktop
```
/app/scripts/doublecmd.sh
```
