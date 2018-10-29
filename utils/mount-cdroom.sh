#! /bin/bash
mount_path=`pwd`/../root/cdroom/
mount_point=`realpath $mount_path`
umount $mount_point
mount -o loop CentOS-7-x86_64-Minimal-1708\(1\).iso $mount_point
