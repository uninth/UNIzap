#
# Proto spec for UNIzab
#
# $Header$
#
# See
#	http://www.ibm.com/developerworks/library/l-rpm2/
# and
#	https://fedoraproject.org/wiki/Packaging:ScriptletSnippets
#

AutoReqProv: no

Requires: UNItools

# for compatibility with old md5 digest
# %global _binary_filedigest_algorithm 1
# %global _source_filedigest_algorithm 1

%define defaultbuildroot /
# Do not try autogenerate prereq/conflicts/obsoletes and check files
%undefine __check_files
%undefine __find_prereq
%undefine __find_conflicts
%undefine __find_obsoletes
# Be sure buildpolicy set to do nothing
%define __spec_install_post %{nil}
# Something that need for rpm-4.1
%define _missing_doc_files_terminate_build 0

%define name    UNIzab
%define version 1.0
%define release 12

Summary: Zabbix agent for Check Point Firewall
Name: %{name}
Version: %{version}
Release: %{release}
License: GPL
Group: root
Packager: Niels Thomas Haugaard, nth@i2.dk
Vendor: i2 - Intelligent Infrastructure, the Danish Technical University
%description
Tools for simplified administration of Check Point firewalls based on GAiA

%prep
PREFIX=/lan/ssi/shared/software/internal/UNIzab/
BUILDROOT=${PREFIX}/UNIzab_buildroot

ln -s ${BUILDROOT} /tmp/UNIzab_buildroot

%clean
rm /tmp/UNIzab_buildroot

################################################################################

%pre
# Just before the upgrade/install
if [ "$1" = "1" ]; then
	echo "pre: prepare for initial installation ... "
	# Perform tasks to prepare for the initial installation - check fw version
	# and UNItools installed
	# fra /var/opt/UNIzab/bin/setup.sh preinitial - men filen findes endnu ikke

	case `uname` in
		Linux|linux)
			echo "Linux ... ok"
		;;
		*)
			echo "arch not linux, bye"
			exit 1
		;;
	esac

	if [ `uname -r|grep cp|wc -l|tr -d ' '` ]; then
		echo "Linux Kernel made by Check Point ... ok "
	else
		echo "Linux Kernel doesnt match *cp"
		exit 1
	fi

	if [ -f /tmp/.CPprofile.sh ]; then
		echo "CPprofile found ... good"
		. /tmp/.CPprofile.sh
	else
		echo "/tmp/.CPprofile.sh not found, bye"
		exit 1
	fi

	if [ -e /bin/clish ]; then
		echo "OS is GAiA ... good"
		CPOSVER=GAIA
	else
		echo "OS is Secure Platform ... ok"
		CPOSVER=SPLAT
	fi

	if [ -e /etc/init.d/unizab ]; then
		echo "stopping existing Zabbix ... "
		/etc/init.d/unizab stop
	fi
	if [ -e /etc/cron.d/unizab ]; then
		echo "removing existing cron entry for Zabbix ... "
		/bin/rm -f /etc/cron.d/unizab
		/etc/init.d/crond restart >/dev/null 2>&1
	fi

	# fra /var/opt/UNIzab/bin/setup.sh preinitial - men filen findes endnu ikke
	:
elif [ "$1" = "2" ]; then
	# Perform whatever maintenance must occur before the upgrade begins
	echo "pre: prepare for upgrading ..."
	NOW=`/bin/date +%Y-%m-%d`
	mkdir /var/tmp/${NOW}
	cp /var/opt/UNIzab/etc/*.conf			/var/tmp/${NOW}/
	echo "Old config files saved in /var/tmp/${NOW}/"
	# fra /var/opt/UNIzab/bin/setup.sh preinitial - men filen findes endnu ikke

	if [ -e /etc/init.d/unizab ]; then
		echo "stopping existing Zabbix ... "
		/etc/init.d/unizab stop
	fi
	if [ -e /etc/cron.d/unizab ]; then
		echo "removing existing cron entry for Zabbix ... "
		/bin/rm -f /etc/cron.d/unizab
		/etc/init.d/crond restart >/dev/null 2>&1
	fi

	# fra /var/opt/UNIzab/bin/setup.sh preinitial - men filen findes endnu ikke
fi

# post install script -- just before %files
%post
# Just after the upgrade/install
if [ "$1" = "1" ]; then
	# Perform tasks for for the initial installation
	echo "post: initial installation ... "
	echo "post: running setup.sh postinstall"
	/var/opt/UNIzab/bin/setup.sh postinitial
elif [ "$1" = "2" ]; then
	# Perform whatever maintenance must occur after the upgrade has ended
	echo "post: upgrade ... "
	NOW=`/bin/date +%Y-%m-%d`
	echo "Existing config files saved as /var/opt/UNIzab/etc/${NOW}/"
	/bin/mv /var/tmp/${NOW}/ /var/opt/UNIzab/etc/${NOW}/
	echo "post: Please compare with the new ones"

	echo "post: running setup.sh postupgrade"
	/var/opt/UNIzab/bin/setup.sh postupgrade

	# fix Server= in all config files
	(
	cd /var/opt/UNIzab/etc/${NOW}
	for FILE in *; do
		S=`sed '/^Server=/!d' $FILE`
		if [ -n "${S}" ]; then
			echo "fixing existing setting $S in ${FILE} ... "
			if [ -f ../${FILE} ]; then
				sed "s/^Server=.*/$S/g" /var/opt/UNIzab/etc/${FILE} >/tmp/${FILE}
				/bin/mv /tmp/${FILE} /var/opt/UNIzab/etc/${FILE}
				chmod 744 /var/opt/UNIzab/etc/${FILE}
				chown zabbix:users /var/opt/UNIzab/etc/${FILE}
			else
				echo "hmm: file /var/opt/UNIzab/etc/${FILE} not found"
			fi
		else
			echo "skipping 'Server=' not found in ${FILE} ... "
		fi
	done
	)
fi

# pre uninstall script
%preun
if [ "$1" = "1" ]; then
	# upgrade
	echo "pre uninstall: upgradeing ... "
	echo "Existing Zabbix Server settings:"
	( cd /var/opt/UNIzab/etc; for f in zabbix_agent*.conf*; do echo "$f: `sed '/^Server=/!d' $f`"; done)

elif [ "$1" = "0" ]; then
	# remove
	echo "pre uninstall: removing ... "
	echo "pre uninstall: running setup.sh uninstall"
	/var/opt/UNIzab/bin/setup.sh uninstall
	echo "Please remove everything left in /var/opt/UNIzab"
fi

# All files below here - special care regarding upgrade for the config files
%files
%config /var/opt/UNIzab/etc/zabbix_agentd/zabbix_agentd.userparams.conf
%config /var/opt/UNIzab/etc/zabbix_agentd.conf
/var/opt/UNIzab
