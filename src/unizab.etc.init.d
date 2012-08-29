#!/bin/sh
#
# $Header: /lan/ssi/shared/software/internal/UNIzab/src/RCS/unizab.etc.init.d,v 1.4 2015/08/19 16:29:25 root Exp $
#
# chkconfig: 2345 55 25
# description: zabbix agent daemon startup script
#

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Source CP specific configuration
. /tmp/.CPprofile.sh

# Source the rest
. /home/admin/.bash_profile

# Check that networking is up.
[ ${NETWORKING} = "no" ]		&& exit 1

PROD_DIR=/var/opt/UNIzab
RC=${PROD_DIR}/etc/unizab.etc.init.d

AGENTDPATH=${PROD_DIR}/sbin/zabbix_agentd
AGENTD=`basename ${AGENTDPATH}`

# zabbix_agentd.conf
CONFIG=${PROD_DIR}/etc/zabbix_agentd.conf

ARGUMENTS=" -c ${CONFIG}"

[ -f "${CONFIG}" ]      || exit 1

getpid()
{
	PID=`/bin/ps -fe | awk '$8 == "'${AGENTDPATH}'" { print $2 }'`
	PID=`echo $PID` # concatenate words
}

case "$1" in
	start)  getpid
	case "${PID}" in
		"")	touch /var/run/zabbix_agentd.pid
		   	chmod 777 /var/run/zabbix_agentd.pid
			daemon $AGENTDPATH $ARGUMENTS &
		;;
		*)	echo "$AGENTD allready running on pid $PID ... "
			RETVAL=1
		;;
	esac
	echo "collecting initial data ... "
	/var/opt/UNIzab/bin/col2za hour	2>&1 >/dev/null		&
	/var/opt/UNIzab/bin/col2za day	2>&1 >/dev/null		&
	daemon /var/opt/UNIzab/bin/col2za min			& 
	;;
	stop)   killproc $AGENTDPATH
		RETVAL=$?
		killproc /var/opt/UNIzab/bin/col2za
		RETVAL=$?
		#kill -9 `ps -fe|awk '$0 ~ /\/var\/opt\/UNIzab\/bin\/col2za min/ { print $2 }'` >/dev/null 2>&1
	;;

	status) getpid
		case "${PID}" in
			"")	 echo "$AGENTD not running"
			;;
			*)	  echo "$AGENTD running on pid $PID ... "
			;;
		esac
	;;
	restart) $RC stop; $RC start
		;;
	loglevel)	
		case $2 in
			u|up|i|increase)   ${AGENTDPATH} -c ${CONFIG} --runtime-control log_level_increase
			;;
			d|down|decrease) ${AGENTDPATH} -c ${CONFIG} --runtime-control log_level_decrease
			;;
			*)	echo "loglevel u|i|increase | d|decrease"
				exit 0
			;;
		esac
		LOGFILE=`sed '/LogFile=/!d; s/^.*=//' ${CONFIG}`
		tail -10 $LOGFILE
	;;
	*)
		echo "Usage: $0 {start|stop|restart|status|loglevel [level]}"
		exit 1
	;;
esac

exit 0
