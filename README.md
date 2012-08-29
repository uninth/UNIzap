
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

The installation procedure is described in `INSTALL-UNIzab-version.md`.

## Development

The source is written in shell and changes should be easy to adapt.

## License

This is released under a
[modified BSD License](https://opensource.org/licenses/BSD-3-Clause), but
see LICENSE for zabbix, RedHat and HP copy writed material.

