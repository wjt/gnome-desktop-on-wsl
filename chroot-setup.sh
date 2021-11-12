#!/bin/bash
set -ex

BUILDIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

export DEBIAN_FRONTEND=noninteractive
	
cp $BUILDIR/profile /etc/profile
cp $BUILDIR/sources.list /etc/apt/sources.list

update-locale LANGUAGE=en_US.UTF-8 LC_ALL=C
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

apt-get update
# - fuse3: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=998846
apt-get install -y --no-install-recommends \
    ca-certificates \
    fuse3 \
    gnome-remote-desktop \
    gnome-session \
    gnome-shell \
    gnome-terminal \
    jq \
    librsvg2-common \
    wget \
    wireplumber \
    $NULL
apt-get remove -y pipewire-pulse

# For .net, dependency of systemd-genie
wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# For systemd-genie
wget -O /etc/apt/trusted.gpg.d/wsl-transdebian.gpg https://arkane-systems.github.io/wsl-transdebian/apt/wsl-transdebian.gpg
cp $BUILDIR/sources.list.d/* /etc/apt/sources.list.d 

apt-get update
apt-get install -y systemd-genie
apt-get clean

# https://github.com/arkane-systems/genie/wiki/WSLg-FAQ#multi-usertarget
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

cp -a $BUILDIR/systemd-sysusers.service.d /etc/systemd/system/systemd-sysusers.service.d
cp -a $BUILDIR/gnome-remote-desktop.service.d /etc/systemd/user/gnome-remote-desktop.service.d

mkdir -p /usr/local/bin
cp $BUILDIR/bin/* /usr/local/bin