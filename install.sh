#!/bin/bash
PATCH_NAME=iproute_fq-pie.patch
ROOT_PATH=`pwd`

if [ -e /etc/redhat-release ]; then
	#CentOS7 - yum
	yum install bison flex db4-devel libdb-devel -y
elif [ -e /etc/lsb-release ]; then
	#Ubuntu14.04 - apt-get
	apt-get install bison flex libdb5.3 -y
fi

if [ ! -e iproute2 ]; then
	echo "git clone 'iproute2' from git.kernel.org"
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
fi

cd iproute2
git reset --hard HEAD
rm man/man8/tc-fq_pie.8
rm tc/q_fq_pie.c

cp ../pkt_sched.h include/linux/pkt_sched.h
cp ../manMakefile man/man8/Makefile
cp ../tc.8        man/man8/tc.8
cp ../tc-fq_pie.8 man/man8/tc-fq_pie.8
cp ../tcMakefile  tc/Makefile
cp ../q_fq_pie.c  tc/q_fq_pie.c

git add -N man/man8/tc-fq_pie.8
git add -N tc/q_fq_pie.c

git status
#git diff
echo "making patch"
echo "git diff > ${ROOT_PATH}/${PATCH_NAME}"
git diff > ${ROOT_PATH}/${PATCH_NAME}

tc -V
make clean
make
make install
tc -V

# USAGE
# tc qdisc show eth0
# tc qdisc add dev eth0 root fq_pie limit 100 
# tc qdisc change dev eth0 root fq_pie limit 200 target 10ms
# tc qdisc del dev eth0 root
