
[![Documentation][logo]][documentation]
[logo]: src/UNIzab-documentation.bundle/assets/img/UNIzab-coverpage.png
[documentation]: RPM/INSTALL-UNIzab-1.0-12.md

# UNIzab - client

**UNIzab** is a [zabbix](https://www.zabbix.com/) client made for Check Point
firewall-1 version 75.x - 77.30 both 32 and 64bit systems. It comes with
a set of collectors for interface statistic, firewall kernel statistic,
certificate expiration and more. It requires a zabbix server for monitoring,
alerting and visualization.

### Security

The client sends data back to the server, thereby exposing the server
which must be protected accordingly. It is possible to execute commands
from the zabbix server on the client (the firewall), so the server must
be in a trusted environment.

## Deployment

The RPM and the installation instruction is found [in RPM](RPM).

## Documentation

There is no documentation for the zabbix configuration, please consult
[zabbix](https://www.zabbix.com/) and e.g. [youtube](https://www.youtube.com/results?search_query=zabbix+administration).

The following parameters are monitored:

### Check Point
  - Check Point concurrent connections
  - Check Point peak concurrent connections
  - Dead gateways with static routes
  - Linux ARP tabel GC_THRESH1 value
  - Linux ARP tabel GC_THRESH2 value
  - Linux ARP tabel GC_THRESH3 value
  - Linux ARP tabel size
  - New ICMP connections per second
  - New TCP connections per second
  - New UDP connections per second
  - Policy installation date
  - Policy Name
  - Total number of new connnections per second
  - Unreachable gateways (ICMP)
### CPU
  - Context switches per second
  - For each CPU:
  - CPU idle time
  - CPU interrupt time
  - CPU iowait time
  - CPU nice time
  - CPU softirq time
  - CPU steal time
  - CPU system time
  - CPU user time
  - Interrupts per second
  - Processor load (1 min average per core)
  - Processor load (5 min average per core)
  - Processor load (15 min average per core)
### Filesystems
  - Free disk space on each filesystem
  - Free disk space on each filesystem in %
  - Total disk space on each filesystem
  - Used disk space on each filesystem
### General
  - Host boot time
  - Host local time
  - Host name
  - System information
  - System uptime
### ICMP
  - ICMP loss
  - ICMP ping
  - ICMP response time
### Memory
  - Available memory
  - Free swap space
  - Free swap space in %
  - Total memory
  - Total swap space
### Network interfaces 
  - Incoming network drops on each interface
  - Incoming network errors on each interface
  - Incoming network packets on each interface
  - Incoming network traffic on each interfacs
  - Incoming packets dropped in percent on each interfaces
  - Outgoing network packets on each interfaces
  - Outgoing network traffic on each interfaces
### OS
  - Host boot time
  - Host local time
  - Host name
  - Maximum number of opened files
  - Maximum number of processes
  - Number of logged in users
  - System information
  - System uptime
### Processes
  - Number of processes
  - Number of running processes
Security (2 Items)
  - Checksum of `/etc/passwd`
  - Number of logged in users
  - SSH service (1 Item)
  - SSH service is running
### Zabbix agent
  - Agent ping
  - Host name of zabbix_agentd running
  - Version of zabbix_agent(d) running

The installation procedure is described in `INSTALL-UNIzab-version.md`.

## Development

The source is written in shell and changes should be easy to adapt.

## License

This is released under a
[modified BSD License](https://opensource.org/licenses/BSD-3-Clause), but
see LICENSE for zabbix, RedHat and HP copy writed material.

