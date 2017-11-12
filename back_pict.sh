#!/bin/bash -eu

folder=$1

do_back() {
	mount /mnt/stack
	rsync -a --progress /media/pi/Data/${folder} /mnt/stack/pictures/
}

cleanup() {
    umount /mnt/stack
}
trap cleanup EXIT INT TERM
do_back

