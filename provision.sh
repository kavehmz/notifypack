#!/bin/bash -x

export DEBIAN_FRONTEND=noninteractive

[[ "$(uname -a)" == *"Debian"* ]] && echo "deb http://http.debian.net/debian jessie-backports main" > /etc/apt/sources.list.d/jessie_backports.list
apt-get update
apt-get install -y libjson-perl git httpie locate curl cpanminus exuberant-ctags htop iotop atop sysdig ack-grep linux-tools-3.16
apt-get -y upgrade

if [ ! -f /etc/cron.d/zram ]
then
cat <<End > /opt/zram.sh
#!/bin/bash
set -x
[ -f /sys/block/zram0/disksize ] && exit 0
/sbin/modprobe zram
echo 256M > /sys/block/zram0/disksize
/sbin/mkswap /dev/zram0
/sbin/swapoff -a
/sbin/swapon /dev/zram0
End
	chmod +x /opt/zram.sh
	echo "@reboot root /opt/zram.sh" > /etc/cron.d/zram
	/opt/zram.sh
fi

exit 0
