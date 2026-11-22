# Input methods

Chinese, Japanese, Korean, Vietnamese, the Indian scripts and many other languages are typed through an input method: you type letters, and it turns them into the characters you pick. The desktop gets one when the container starts with `docker run -e INPUT_METHOD`:
```
-e INPUT_METHOD='pinyin'
```
It's optional: without it, nothing is installed and typing works as before. With it, the container's first start installs [fcitx5](https://fcitx-im.org) and the input methods it names, which takes about 10 seconds and 90 to 190 MB (see [First start](#first-start)). Like the other variables, it's read at every start, but a container keeps the value it was created with: to change it, start a new container. In docker compose it goes under `environment:`.

"The desktop" below means the Xfce session and every program started from it.

## Common setups
A Chinese desktop, typing with Pinyin
```
-e LOCALE='zh_CN' -e INPUT_METHOD='pinyin'
```
Traditional Chinese, typing with Zhuyin (Bopomofo)
```
-e LOCALE='zh_TW' -e INPUT_METHOD='chewing'
```
A Japanese desktop, typing with Mozc, which needs a desktop user other than root: here the built-in `ubuntu` account ([Mozc and root](#mozc-and-root))
```
-e LOCALE='ja_JP' -e INPUT_METHOD='mozc' -e VNCUSERMAP='ubuntu/1000'
```
A Japanese desktop as root (the default user), typing with Anthy
```
-e LOCALE='ja_JP' -e INPUT_METHOD='anthy'
```
A Korean desktop
```
-e LOCALE='ko_KR' -e INPUT_METHOD='hangul'
```
A Vietnamese desktop
```
-e LOCALE='vi_VN' -e INPUT_METHOD='unikey'
```
An English desktop that types Chinese, Japanese and Korean
```
-e INPUT_METHOD='pinyin,anthy,hangul'
```
`LOCALE` sets the language of menus and dialogs ([LOCALE.md](LOCALE.md)), and `INPUT_METHOD` only adds typing, so any combination works.

## Names
`INPUT_METHOD` takes fcitx5's names for its input methods, separated by commas. Until you've used another, Ctrl+Space turns on the first one ([Typing](#typing)).

| Language | Name | Typing | Size, on top of fcitx5's 87 MB |
|---|---|---|---|
| Chinese (Simplified) | `pinyin` | Pinyin | 49 MB |
| | `shuangpin` | Shuangpin | in `pinyin`'s package |
| | `wbx`, `wbpy`, `erbi`, `qxm`, `wanfeng`, `zrm` | Wubi, Wubi with Pinyin, and other shape tables | in `pinyin`'s package |
| Chinese (Traditional) | `chewing` | Zhuyin (Bopomofo) | 7 MB |
| | `cangjie` | Cangjie | in `pinyin`'s package |
| | `cangjie5`, `quick5`, `boshiamy` and more | more tables, one package each (`fcitx5-table-<name>`) | small |
| Chinese, either | `rime` | Rime, with Luna Pinyin, Terra Pinyin, Bopomofo, Cangjie 5 and Stroke | 106 MB |
| Japanese | `mozc` | Romaji to kana and kanji; needs a desktop user other than root ([Mozc and root](#mozc-and-root)) | 27 MB |
| | `anthy` | Romaji to kana and kanji, as root too | 28 MB |
| Korean | `hangul` | Hangul (2-set keyboard) | 7 MB |
| Vietnamese | `unikey` | Telex, VNI | under 1 MB |
| | `bamboo` | Telex, VNI | 2 MB |
| The Indian scripts, Thai, Amharic and many more | `m17n_<language>_<name>` | m17n's input methods: `m17n_hi_inscript2` (Hindi, InScript), `m17n_ta_tamil99` (Tamil 99), `m17n_th_kesmanee` (Thai) and 200 others | 11 MB |

An m17n name comes from m17n's file for it, `/usr/share/m17n/<language>-<name>.mim`: `hi-inscript2.mim` is `m17n_hi_inscript2`.

## Mozc and root
Mozc doesn't work when the desktop runs as root, which it does unless `VNCUSERMAP` is set ([README](README.md#non-root-users)): its server, `mozc_server`, refuses to run as root. So on a root desktop, `mozc` is left out, and `docker logs` says so (see [Errors](#errors)). Either type Japanese with `anthy`, which works as root, or run the desktop as a user, such as the built-in `ubuntu` account:
```
-e INPUT_METHOD='mozc' -e VNCUSERMAP='ubuntu/1000'
```
Don't add Mozc by hand on a root desktop either: fcitx5 hangs waiting for Mozc's server, for minutes, and typing stops in the whole desktop.

## Typing
- **Ctrl+Space** turns the input method on and off. It turns on the one you used last: the first name in `INPUT_METHOD`, until you've used another.
- **Another input method:** keep Ctrl held and press Space again. Each press goes on to the next one in the list, which is plain letters followed by the names in `INPUT_METHOD`, and starts over after the last one. With `pinyin,anthy,hangul` and Pinyin on, holding Ctrl and pressing Space four times goes to plain letters, Pinyin, Anthy, then Hangul.
- **Left Shift** switches between plain letters and the input method you were using.
- **The fcitx5 icon** in the panel shows which one is on.
- For example:
  - Pinyin: type `nihao`, then pick 你好 with Space (the first choice) or its number.
  - Mozc: type `konnichiha`, press Space to convert and Enter to accept: こんにちは.
  - Anthy: type `konnichiha` and press Enter to accept the kana as typed: こんにちは. Space converts to kanji first.
  - Hangul: the keys follow the Korean 2-set layout, so `dkssud` gives 안녕.

## Mac clients
macOS uses Ctrl+Space itself, to switch its own input sources, so a VNC viewer on a Mac may never see it. Either turn that shortcut off on the Mac (System Settings > Keyboard > Keyboard Shortcuts > Input Sources), or give fcitx5 another key: Fcitx 5 Configuration > Global Options > Toggle Input Method.

## Settings, and more input methods later
- **Fcitx 5 Configuration** (Applications > Settings) adds, removes and orders the input methods, changes the keys, and holds each input method's own options. Its changes are kept in `~/.config/fcitx5`, which `docker restart` keeps.
- **Another input method later:** install its package from a terminal in the desktop (`apt-get` runs without a password for the desktop user), restart fcitx5, then add it in Fcitx 5 Configuration:
  ```
  sudo apt-get update && sudo apt-get install -y fcitx5-hangul
  fcitx5 -r -d
  ```
  Like anything installed that way, it lasts as long as the container; a new container gets it from `INPUT_METHOD` instead.

## First start
- The first start installs fcitx5, its plugins for GTK and Qt 6 programs, its settings program and the input methods' packages from Ubuntu's archive, so it needs the network. The desktop comes up when that's done: the install takes about 10 seconds on a fast connection, and the desktop comes up about 20 seconds after `docker run` instead of 3.
- The container grows by fcitx5's 87 MB plus each input method's size from [Names](#names): 136 MB with `pinyin`, 121 MB with `mozc,hangul`.
- `docker logs` shows
  ```
  Input method: installing fcitx5 fcitx5-frontend-gtk2 fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt6 fcitx5-config-qt fcitx5-chinese-addons (first start only)
  Input method: installed in 8 s
  Input method: pinyin (fcitx5; Ctrl+Space switches)
  ```
- `docker restart` keeps it all, and prints only the last line. A new container installs it again.
- Qt 5 programs (VLC, for example) get no fcitx5 plugin, which would add 30 MB. `sudo apt-get install -y fcitx5-frontend-qt5` adds it, for Qt 5 programs started afterwards.

## Errors
A name that isn't an input method doesn't stop the container, and the other names still work. `docker logs` says
```
INPUT_METHOD: 'klingon' is not an input method (there is no package fcitx5-table-klingon); INPUT_METHODS.md lists them
```
`mozc` on a root desktop is left out the same way ([Mozc and root](#mozc-and-root)):
```
INPUT_METHOD: 'mozc' doesn't work when the desktop runs as root, so it's left out; use anthy, or a non-root desktop user (VNCUSERMAP); see INPUT_METHODS.md
```
If none of the names works, or the install fails (no network, for example), the desktop starts without an input method:
```
INPUT_METHOD='klingon': no input method is installed; the desktop starts without one
```

## Fonts
The image has fonts for all of these languages: see [LOCALE.md](LOCALE.md#fonts).

## How it works
- At every start, before the desktop, `app/input.sh` runs as root. With `INPUT_METHOD` set, it:
  - leaves out `mozc` if the desktop runs as root (UID 0), before installing anything: Mozc's server refuses to run as root, and fcitx5 would hang waiting for it;
  - installs what's missing: fcitx5, and each name's package (only a first start finds anything missing);
  - checks each name against what's installed: `/usr/share/fcitx5/inputmethod/<name>.conf`, or m17n's `.mim` file;
  - writes the desktop user's `~/.config/fcitx5/profile` (plain letters first, then the names) and `~/.config/fcitx5/conf/xcb.conf`, each only if it isn't there yet, so changes made in Fcitx 5 Configuration last;
  - puts fcitx5's own `org.fcitx.Fcitx5.desktop` in `/etc/xdg/autostart`, so the desktop session starts fcitx5. Ubuntu's fcitx5 package doesn't start it by itself: its `im-config` does that from `/etc/X11/Xsession.d`, which a VNC session doesn't run.
- When that autostart entry exists, the session's start script (`xstartup`) sets `GTK_IM_MODULE`, `QT_IM_MODULE`, `XMODIFIERS`, `SDL_IM_MODULE` and `GLFW_IM_MODULE`. Programs started in the desktop then use fcitx5: GTK and Qt programs through fcitx5's plugins and the session's D-Bus, xterm and Java programs through XIM.
- `xcb.conf` turns off fcitx5's "Allow Overriding System XKB Settings". The VNC server translates the client's keys itself, and fcitx5 would otherwise load its own keyboard layout into it.

## Checking a container
What the start script reported:
```
docker logs <container> | grep -E '^(Input method|INPUT_METHOD)'
```
In a terminal in the desktop:
- `fcitx5-remote` prints 1 while plain letters are on and 2 while the input method is on (0: fcitx5 isn't running, or no window has focus).
- `fcitx5-diagnose` reports the whole setup. Two of its complaints don't apply here: it can't find the fcitx5 modules for GTK 2 and 3 (it looks for `gtk-query-immodules`, which the image doesn't have, but the modules are installed), and there are no Qt 4 or Qt 5 modules (see [First start](#first-start)).
