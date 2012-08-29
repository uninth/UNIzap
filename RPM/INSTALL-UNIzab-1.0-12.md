
## Installation procedure for UNIzab-1.0-12.i386.rpm
    Package name: UNIzab-1.0-12.i386.rpm
    Version     : 1.0
    Release     : 12

## Prerequisite

1. The package ``UNItools`` must also be installed first.

1. Agents and daemon downloaded from http://www.zabbix.com/download.php as pre-compiled binaries.
   A copy is in the package. Also if your hardware is HP branded and contains a RAID controller
   then install `compat-libstdc++-7.3-2.96.128.i386.rpm` and `hpacucli-8.25-5.noarch.rpm` from
   `EXTERNAL_RPMs` first.

## Installation
Copy UNIzab-1.0-12.i386.rpm to target host, which should be a Check Point firewall either
stand alone, enforcement module or management station (any combination).

		export TARGET="a.b.c.d"
        td -x UNIzab-1.0-12.i386.rpm ${TARGET}
        rpm -Uvh /var/tmp/UNIzab-1.0-12.i386.rpm

Check that the service is running with

        /etc/init.d/unizab status

The reply should match ``zabbix_agentd running on pid ``_xxxxx_.

And

        ps -fe | grep /var/opt/UNIzab/bin/col2za

``col2za`` should be running with argument ``min`` started
by ``bin/bash -c ulimit -S -c 0``

All software is installed below ``/var/opt/UNIzab`` except for the
``cron`` and ``init`` parts.

Please check the _Server address_ is correct in the config files, and
that the zabbix server on IPv4 172.16.201.242 has access to TCP port
10050.

## Uninstallation

Remove the package with:

    rpm -e --nodeps UNIzab-1.0-12.i386.rpm

You may have to remove old config and data files below /var/opt/UNIzab

## Note

This document is in RCS and build with make, do not edit.

## RPM info

View rpm content with

        rpm -lpq UNIzab-1.0-12.i386.rpm

