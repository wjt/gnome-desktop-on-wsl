- Install WSL
- Optional: install the most modern graphics drivers you can find (e.g. https://www.intel.com/content/www/us/en/support/intel-driver-support-assistant.html)
- Install a Debian container
- Update it to Bookworm
- Install packages-microsoft-prod.deb
- Install Genie repo

```
sudo apt install -y systemd-genie gnome-shell gnome-remote-desktop gnome-session flatpak rsync jq
sudo apt remove pipewire-pulse
```

- `systemctl set-default multi-user.target`
- Mask some unitsl
- Add some overrides


## Credits

`create-targz.sh` is a heavily-modified copy of the script from https://salsa.debian.org/debian/WSL, as is the `profile` in this repo. Everything else is original.