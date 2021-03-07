## Gnome Shell Screenshot DBus Emulation

Fork of https://git.sr.ht/~synaptiko/gnome-shell-screenshot-dbus-emulator, that is inspired by https://gitlab.com/jamedjo/gnome-dbus-emulation-wlr but rewritten in Go so it can be compiled to a binary and used in my .files easily. Also it only has support for `grim` and hard-coded `DP-1` output.

Check this to fix problems with Zoom: https://gitlab.com/jamedjo/gnome-dbus-emulation-wlr/-/issues/1

# Archlinux

AUR package available here https://aur.archlinux.org/packages/gnome-shell-screenshot-dbus-emulator

# Zoom

To make it working with Zoom, add the following in the `~/.config/zoomus.conf` config file.

```
[AS]
showframewindow=false
```
