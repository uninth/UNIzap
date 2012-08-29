:

DIR=`pwd`

/bin/rm -fr SPLAT GaIA precompiled ../src/UNIzab_buildroot/var/opt/UNIzab/precompiled

mkdir -p SPLAT GaIA precompiled/bin precompiled/sbin

cd SPLAT; tar xfpz ../zabbix_agents_2.4.1.linux2_4.i386.tar.gz; rm -fr conf
for f in bin/* sbin/*
do
	mv ${f} $DIR/precompiled/${f}-SPLAT
done

cd $DIR

cd GaIA; tar xfpz ../zabbix_agents_2.4.1.linux2_6.i386.tar.gz; rm -fr conf
for f in bin/* sbin/*
do
	mv ${f} $DIR/precompiled/${f}-GAIA
done

cd $DIR

/bin/rm -fr $DIR/SPLAT $DIR/GaIA

mv $DIR/precompiled ../src/UNIzab_buildroot/var/opt/UNIzab/
