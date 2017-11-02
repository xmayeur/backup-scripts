#!/bin/bash -eu

dir=$(mktemp -d)
bkdir="/mnt/nas/rpi"
NOW=$(date +"%Y%m%d")
DAY=$(date +%d)
if [ ${DAY} -eq 01 ]
then
    LEV="--level=0"
    SUFFIX="_level0"
else
    LEV=""
    SUFFIX=""
fi

cleanup(){
    cd /tmp/ # You can't umount or rm a directory while you are in it.
    for m in /dev/ /tmp/ /var/log/ /boot/ /; do
        umount ${dir}${m}
    done
    umount /mnt/nas
    rm -rf ${dir}
}

do_mounts(){
    mount                     /dev/mmcblk0p2    ${dir}/
    mount -t tmpfs -o size=1m tmpfs             ${dir}/dev/
    mount -t tmpfs -o size=1m tmpfs             ${dir}/tmp/
    mount -t tmpfs -o size=1m tmpfs             ${dir}/var/log/
    mount                     /dev/mmcblk0p1    ${dir}/boot/
    mount -t cifs //192.168.0.16/Other /mnt/nas -o credentials=/home/pi/.smbcredentials,uid=root,file_mode=0777,dom=WORKGROUP

}

send_data(){
    cd ${dir}; tar -g ${bkdir}/incr.snar ${LEV} -pcf - . | gzip | pv > ${bkdir}/rpiMon$SUFFIX_$NOW.tgz 
# tee >(md5sum > /tmp/backup.md5);
}

give_feedback(){
    awk '{print "MD5:", $1}' < /tmp/backup.md5 >&2
}

trap cleanup EXIT INT TERM
do_mounts
send_data
# give_feedback

