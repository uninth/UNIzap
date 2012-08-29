#!/bin/sh
#
# $Header: /lan/ssi/shared/software/internal/UNIzab/src/RCS/setup.sh,v 1.1 2015/05/12 16:58:22 root Exp $
#
#--------------------------------------------------------------------------------------#
# status:
#	sh setup.sh postinitial - virker med gaia
#
# mangler:
#	test splat
#	test afinstallation

FILES=/var/opt/UNIzap
INIT=/etc/init.d/unizab
CRON=/etc/cron.d/unizab

################################################################################
# Main
################################################################################

case `uname` in
	Linux|linux)	
		: # ok
	;;
	*)
		echo "arch not linux, bye"
		exit 1
	;;
esac

if [ `uname -r|grep cp|wc -l|tr -d ' '` ]; then
	: # ok
else
	echo "Linux Kernel doesnt match *cp"
	exit 1
fi

if [ -f /tmp/.CPprofile.sh ]; then
	. /tmp/.CPprofile.sh
else
	echo "/tmp/.CPprofile.sh not found, bye"
	exit 1
fi

if [ -e /bin/clish ]; then
	CPOSVER=GAIA
else
	CPOSVER=SPLAT
fi

case $1 in 
	# pre uninstall script
	uninstall)
		/etc/init.d/unizab stop
        	chkconfig --del unizab
		/bin/rm -f  /etc/cron.d/unizab /etc/init.d/unizab
		/etc/init.d/crond restart >/dev/null 2>&1

		case ${CPOSVER} in
			GAIA)	clish -s -c "delete user zabbix"
			;;
			SPLAT)	userdel -r zabbix
			;;
		esac

		echo now please remove files below /var/opt/UNIzab
		echo files:
		find /var/opt/UNIzab

		# rm data + config + bin/ + ...
	;;

	# install / upgrade part: Just before the upgrade/install

	# Perform tasks to prepare for the initial installation
	preinitial)
		if [ -e /etc/init.d/unizab ]; then
			/etc/init.d/unizab stop
		fi
		if [ -e /etc/cron.d/unizab ]; then
			/bin/rm -f /etc/cron.d/unizab
			/etc/init.d/crond restart >/dev/null 2>&1
		fi
	;;
	# Perform whatever maintenance must occur before the upgrade begin
	preupgrade)	
		# Stop zabbix, move crontab restart crond
		# preserve config files
		if [ -e /etc/init.d/unizab ]; then
			/etc/init.d/unizab stop
		fi
		if [ -e /etc/cron.d/unizab ]; then
			/bin/rm -f /etc/cron.d/unizab
			/etc/init.d/crond restart >/dev/null 2>&1
		fi
	;;
	# post install script -- just before %files
	postinitial|postupgrade)
		# postinitial: Perform tasks for for the initial installation
		echo adduser zabbix ...
		grep -q zabbix /etc/passwd
		case $? in
			0) echo user zabbix found ...
			;;
			*) echo adding user zabbix ...
				case ${CPOSVER} in
					GAIA)	
					echo using clish ...
				cat <<-EOF > /tmp/zabbix.adduser.clish
lock database override
add user zabbix uid 1608 homedir /home/zabbix
add rba user zabbix roles adminRole
set user zabbix shell /bin/bash
EOF
					clish -i -s -f /tmp/zabbix.adduser.clish
					/bin/rm -f /tmp/zabbix.adduser.clish
					;;
					SPLAT)
					echo using useradd ...
					useradd -u 1608 -o -g 100 -d /home/zabbix -s /bin/bash zabbix
					;;
				esac
			;;
		esac
		# postupgrade: Perform whatever maintenance must occur after the upgrade has ended
       	touch /var/run/zabbix_agentd.pid
		chown zabbix /var/run/zabbix_agentd.pid

		cd /var/opt/UNIzab
		echo "setting mode and ownership 'zabbix' in `pwd` ... "

		chown -R zabbix .
		chmod -R 555 .
		chmod -R 744 etc/*.conf
		chmod 755 etc/unizab.etc.init.d

		if [ ! -f /etc/init.d/unizab ]; then
			/bin/cp /var/opt/UNIzab/etc/unizab.etc.init.d /etc/init.d/unizab 
		fi
		chkconfig --add unizab

		/etc/init.d/unizab stop 2>&1 >/dev/null		# 

		echo "adding data ... "
		/var/opt/UNIzab/bin/col2za min	&
		sleep 5
		/var/opt/UNIzab/bin/col2za hour
		/var/opt/UNIzab/bin/col2za day

		echo "adding UserParameters from data ... "
		while :;
		do
			if [ -f /var/opt/UNIzab/data/data_min ]; then
				break
			else
				sleep 1
			fi
		done
		while :;
		do
			if [ -f /var/opt/UNIzab/data/data_hour ]; then
				break
			else
				sleep 1
			fi
		done
		while :;
		do
			if [ -f /var/opt/UNIzab/data/data_day ]; then
				break
			else
				sleep 1
			fi
		done
		/var/opt/UNIzab/bin/mk.i2-zabbix-agent-UserParameter

		Server=172.16.201.242

		ListenIP=$( ifconfig `netstat -rn|awk '$1 == "0.0.0.0" && $3 == "0.0.0.0" { print $NF }'` |sed '/inet6/d; /inet/!d; s/.*addr://; s/[ ]*Bcast.*//' )
		ListenIP=0.0.0.0

		sed "s/^ListenIP=.*/ListenIP=${ListenIP}/" /var/opt/UNIzab/etc/zabbix_agentd.conf.tmpl > /var/opt/UNIzab/etc/zabbix_agentd.conf

		echo "ListenIP=${ListenIP} in /var/opt/UNIzab/etc/zabbix_agentd.conf"
		echo "`sed '/^Server=/!d' /var/opt/UNIzab/etc/zabbix_agentd.conf` in /var/opt/UNIzab/etc/zabbix_agentd.conf"

		/etc/init.d/unizab start 2>&1 >/dev/null

		/bin/cp /var/opt/UNIzab/etc/unizab.etc.cron.d /etc/cron.d/unizab
		chmod 640 /var/opt/UNIzab/etc/unizab.etc.cron.d /etc/cron.d/unizab
		chown admin:root /var/opt/UNIzab/etc/unizab.etc.cron.d /etc/cron.d/unizab

		/etc/init.d/crond restart 2>&1 > /dev/null
		echo "made init.d and cron.d entries"

		/etc/init.d/unizab status
	;;
	*)	echo "usage: $0 uninstall|preinitial|preupgrade|postinitial|postupgrade"
		exit 0
	;;
esac

exit 0
