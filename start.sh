#! /bin/bash

function create_dnsmasq_pxe_config()
{
	root_path="$1"
	cat << EOF > /etc/dnsmasq.d/pxe_dnsmasq.cfg
#port=0

#dhcp server :10.10.10.0/24
interface=eth0
#dhcp-range=10.10.10.100,10.10.10.200,255.255.255.0,12h
#dhcp-option=3,10.10.10.11
#dhcp-option=6,114.114.114.114

#log-facility=/var/log/dnsmasq.log
#enable pxe
enable-tftp
tftp-root=$root_path/root/
dhcp-boot=pxelinux.0
#enable pxe finish

EOF
}

function mount_iso()
{
	#mount_path=`pwd`/../root/cdroom/
	iso_path="$1"
	mnt="$2"
	mnt=`realpath $mnt`
	umount $mnt 2>/dev/null
	mount -o loop "$iso_path" $mnt
	return $?
}

function prepare_boot_files()
{
	iso_path="$1"
	mnt="$2"
	prefix_src="$3"
	prefix_dst="$4"

	if mount_iso "$iso_path" "$mnt" ;
	then
		echo "mount $mnt success";
		rm -f $prefix_dst/initrd.img
		ln -s "$prefix_src/initrd.img" "$prefix_dst/initrd.img"
		rm -f $prefix_dst/vmlinuz
		ln -s "$prefix_src/vmlinuz" "$prefix_dst/vmlinuz"
		return 0
		
	else
		echo "mount $mnt failed";
		return 1
	fi;
}

function setup_vftpd()
{
	ftp_root="$1"
	cat << EOF > /etc/vsftpd.conf
listen=yes
listen_ipv6=NO
anonymous_enable=yes
local_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
anon_root=$ftp_root
EOF
}

if [ ! `id -u` -eq 0 ];
then
	echo "require root login"
	exit 1
fi;

ROOT=`pwd`
#create_dnsmasq_pxe_config "$ROOT"
prepare_boot_files "/home/pi/Downloads/CentOS-7-x86_64-Minimal-1708.iso" "$ROOT/ftp_root/cdroom" "$ROOT/ftp_root/cdroom/isolinux" "$ROOT/root"
if [ ! "$?" -eq 0 ] ;
then
     echo "prepare boot files failed" && exit 1
fi;

setup_vftpd "$ROOT/ftp_root"


systemctl restart vsftpd.service
#systemctl restart dnsmasq
