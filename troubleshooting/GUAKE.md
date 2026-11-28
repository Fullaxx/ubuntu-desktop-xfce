# Guake's F12 key does nothing

If Guake opens from the menu (Applications > Ubuntu Desktop > Terminals > Guake) but F12 doesn't show or hide it, Xfce's window manager has the key. Started from a terminal, Guake says so: `Binding 'F12' failed!`
- **Why:** the window manager, xfwm4, has a shortcut on Alt+F12 ("Toggle above"). On Ubuntu 26.04's Xfce, it keeps Guake from taking F12, its key for "Toggle Guake visibility". The `:24.04` image has the same shortcut, but Guake gets F12 there.
- **Check:** in a terminal in the desktop, `xfconf-query -c xfce4-keyboard-shortcuts -l -v | grep F12` lists `/xfwm4/custom/<Alt>F12` with `above_key`.

Fix it on either side: clear Xfce's shortcut, or give Guake another key.

## Adjust Xfce: clear its Alt+F12 shortcut
Guake keeps F12, and Xfce loses its Alt+F12 shortcut for "Toggle above", which keeps a window above the others.
- **In the settings:** Applications > Settings > Window Manager, tab Keyboard: select "Toggle above" and click Clear. "Reset to Defaults" in the same tab brings it back.
- **From a terminal in the desktop:**
  ```
  xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>F12' -r
  ```
  To bring it back:
  ```
  xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>F12' -n -t string -s above_key
  ```
- **Then restart Guake,** which tries its key only when it starts: quit it (right-click in Guake > Quit, or `guake --quit`), and start it from the menu again.

## Adjust Guake: give it another key
Xfce keeps Alt+F12, and Guake gets a key nothing else has, such as Shift+F12.
- **In Guake's Preferences:** right-click in Guake > Preferences (or `guake --preferences`), tab "Keyboard shortcuts": click "Toggle Guake visibility" and press the new key.
- **From a terminal in the desktop:**
  ```
  gsettings set guake.keybindings.global show-hide '<Shift>F12'
  ```
  A running Guake takes the new key at once. To go back to F12: `gsettings reset guake.keybindings.global show-hide`.

## Where the change is kept
Either way, it's the desktop user's setting, kept in its HOME: Xfce's in `~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`, Guake's in dconf (`~/.config/dconf/user`). It survives `docker restart`; a new container starts with the defaults again, unless HOME is on a volume.
