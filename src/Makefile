#
# $Header: /lan/ssi/shared/software/internal/UNIzab/src/RCS/Makefile,v 1.4 2015/08/19 09:33:36 root Exp root $
#
# Note: Most magic is made in $(RPMS)/$(package), which requires the build
#		root to be populated first, which is done by install_in_buid_root.

# This has to be updated in unizab.spec too:
version		= 1.0
release		= 12

# working catalog. Notice that RPM WD is below /usr/src/redhat/RPMS/i386/

RPMS		= /usr/src/redhat/RPMS/i386/
DIR			= /lan/ssi/shared/software/internal/UNIzab/src/
RPMDIR		= ../RPM
specfile	= unizab.spec
spectmpl	= $(specfile).template

scripts		= check_cciss col2za mk.i2-zabbix-agent-UserParameter limitchk rzup setup.sh
cronfile	= unizab.etc.cron.d
initfile	= unizab.etc.init.d

etcfiles	= zabbix_agentd.conf.tmpl zabbix_agentd.conf zabbix-rpm-version.txt
agentdfiles	= zabbix_agentd.userparams.conf

# pre-compiled Agents and daemon downloaded from http://www.zabbix.com/download.php as pre-compiled binary
zabbix_bin	= zabbix_get zabbix_sender
zabbix_sbin	= zabbix_agentd zabbix_agent
precompiled	= $(zabbix_bin) $(zabbix_sbin)

files		= $(scripts) $(cron) $(init) $(etcfiles)

NAME		= UNIzab
package		= $(NAME)-$(version)-$(release).i386.rpm
INSTALL		= INSTALL-$(NAME)-$(version)-$(release).md
INST_HTML	= INSTALL-$(NAME)-$(version)-$(release).html

BR			= ../UNIzab_buildroot
PREFIX		= /var/opt/UNIzab

DIRS		=	$(BR)/etc/cron.d $(BR)/etc/rc.d/init.d $(BR)/$(PREFIX)/bin $(BR)/$(PREFIX)/sbin	\
				$(BR)/$(PREFIX)/etc/zabbix_agentd $(BR)/$(PREFIX)/log $(BR)/$(PREFIX)/tmp $(BR)/$(PREFIX)/data

default: $(RPMDIR)/$(package)
	@echo "package $(version)-$(release) ready at $(RPMDIR)/$(package)"

#print:
#	@echo $(files)

preinstall: dirs etc bin zbin
	@echo "made $@"

printinfo:
	@echo $(RPMDIR)/$(package)

zbin: $(precompiled)
	@echo bin and sbin from zabbix_agents_2.4.1.linux2_4.i386.tar.gz

bin: $(scripts)  $(precompiled)
	@install -m 555 -g root -o root $(zabbix_sbin) $(BR)/$(PREFIX)/sbin/
	@install -m 555 -g root -o root $(zabbix_bin)  $(scripts) $(BR)/$(PREFIX)/bin
	@echo "made $@"

dirs:
	@install  -m 755 -g root -o root -d	$(DIRS)
	@echo "made $@"

etc: $(etcfiles) dirs $(cronfile) $(initfile)
	@install -g root -o root -m 766 $(etcfiles)		$(initfile) $(cronfile) $(etcfile) $(BR)/$(PREFIX)/etc/
	@install -g root -o root -m 644 $(initfile)		$(BR)/etc/rc.d/init.d/unizab
	@install -g root -o root -m 644 $(initfile)		$(BR)/etc/cron.d/unizab
	@install -g root -o root -m 766 $(agentdfiles)	$(BR)/$(PREFIX)/etc/zabbix_agentd/
	@echo "made $@"

zabbix-rpm-version.txt: Makefile
	@printf "Package:\t%s\nversion:\t%s\nrelease:\t%s\n" "$(NAME)" "$(version)" "$(release)" > $@

$(specfile): $(DIR)/$(spectmpl) Makefile
	sed "s/__VERSION__/$(version)/g; s/__RELEASE__/$(release)/g" < $(spectmpl)  > $(specfile)

$(INSTALL): INSTALL.md
	@sed "									\
		s/__VERSION__/$(version)/g;			\
		s/__RELEASE__/$(release)/g;			\
		s%__TARGET__%$(package)%g;			\
		" < INSTALL.md > $(INSTALL)

$(INST_HTML): $(INSTALL)
		@mkd2html -css i2-Book.css $(INSTALL) && echo "made $@"
	
spec: $(specfile)

$(RPMS)/$(package):	$(specfile)
	$(MAKE) preinstall
	@/bin/rm -f /usr/src/redhat/SPECS/UNIzab*
	@rpmbuild -bb --buildroot=/tmp/UNIzab_buildroot $(specfile)

$(RPMDIR)/$(package): $(RPMS)/$(package) $(INSTALL)
	@/bin/mv $(RPMS)/$(package) $(RPMDIR)
	@/bin/mv $(INSTALL) $(RPMDIR)

info:
	@rpm -qip $(RPMDIR)/$(package)
	@echo
	@echo "copy to host from $(RPMDIR)"
	@echo
	@echo "installation command on host: rpm -Uvh $(package)"

clean:
	@rm -f $(specfile)
