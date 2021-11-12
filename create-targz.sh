#!/bin/bash
set -ex

DIST="bookworm"

BUILDIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
TMPDIR=$(mktemp -d --tmpdir create-targz.XXXXXXXXXX)
CHROOT_BUILDIR="$TMPDIR/$DIST/tmp/$(basename "$BUILDIR")"

cleanup() {
	if mountpoint --quiet "$CHROOT_BUILDIR"; then sudo umount "$CHROOT_BUILDIR" || :; fi
	sudo rm -rf "$TMPDIR"
}
trap cleanup EXIT

create_x64_rootfs() {
	pushd "$TMPDIR"

	sudo cdebootstrap -a "amd64" --exclude=debfoster --include=sudo,locales $DIST $DIST http://deb.debian.org/debian

	sudo mkdir -p "$CHROOT_BUILDIR"
	sudo mount --bind "$BUILDIR" "$CHROOT_BUILDIR"
	sudo chroot "$DIST" "/tmp/$(basename "$BUILDIR")/chroot-setup.sh"
	sudo umount "$CHROOT_BUILDIR"
	sudo rmdir "$CHROOT_BUILDIR"

	cd "$DIST"
	sudo tar --ignore-failed-read -czf "$TMPDIR/install.tar.gz" -- *

	mkdir -p "$BUILDIR/x64"
	mv "$TMPDIR/install.tar.gz" "$BUILDIR/x64"
	popd
}

create_x64_rootfs
