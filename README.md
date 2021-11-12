# GNOME Desktop on WSL2

This contains scripts to set up and launch a **demo** of a full GNOME desktop running on Windows via WSL2. Two modes are supported:

- Running a headless GNOME Shell session, exporting it over RDP, and then connecting to it from Windows's Remote Desktop client.
- Running as an X11 client under WSLg (which is normally used to run individual Linux apps on Windows, not an entire desktop).

The headless session works more reliably but is clunkier. Most obviously, you need to sign into the remote desktop session; and we don't get any of the good stuff from WSLg, such as transparently forwarding audio from PulseAudio to the Windows host.

The WSLg approach is neater when it works: you get audio, etc. But it is fragile in a number of ways:

- Sometimes apps are launched with the WSLg $WAYLAND_DISPLAY, not the nested GNOME Shell's $WAYLAND_DISPLAY, so you launch an app from within the GNOME Shell session and they appear as freestanding Windows windows. This is probably because gnome-session or the systemd user instance have the wrong environment and Shell is not updating them. But it is nondeterministic.
- Sometimes WSLg's `Xwayland` falls over for unknown reasons, and can only be recovered by terminating your container with `wsl -t Bookworm` (which also terminates the WSLg system container) and relaunching.
- On my system, GNOME Shell interacts poorly with the D3D12 Mesa driver (which passes graphics commands through to the host) when running as a client of the WSLg Xwayland server. The scripts in this repo set `LIBGL_ALWAYS_SOFTWARE=1` to work around this, but this is discarding one of the key advantages of using WSLg!

In either configuration, GNOME Terminal doesn't launch because it is sad about the supposedly non-UTF-8 locale. Try weston-terminal instead.

## Setup

- Install WSL
- Optional: install the most modern graphics drivers you can find (e.g. https://www.intel.com/content/www/us/en/support/intel-driver-support-assistant.html)
- Import a rootfs generated by `create-targz.sh` in this repo:

```powershell
PS> wsl --import Bookworm $HOME\Bookworm \\path\to\install.tar.gz --version 2
```

- Start the container, and create a user. (This is normally done by the WSL distro wrapper app, but we don't have one for this demo.)

```
PS> wsl -d Bookworm
# adduser test --gecos Test
# usermod -G adm,sudo test
# exit
```

- Log into the container as the user you just created, and start a session:

```
PS> wsl -d Bookworm -u test
$ launch-gnome
(or)
$ launch-gnome --use-wslg
```

## Credits

- `create-targz.sh` is a heavily-modified copy of the script from https://salsa.debian.org/debian/WSL, as is the `profile` in this repo.
- Many thanks to Daniel Stone for advice about WSL2 and Mesa's D3D12 driver.