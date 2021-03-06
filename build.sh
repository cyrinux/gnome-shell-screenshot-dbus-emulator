#!/usr/bin/env bash
mkdir -p ~/.local/bin
go build -ldflags "-s" -o ~/.local/bin/gnome-shell-screenshot-dbus-emulator gnome-shell-screenshot-dbus-emulator.go
