#!/bin/bash
#Purpose: Point in time enumeration of Linux and Solaris systems.

linux_survey() {
	echo "[+] Process listing"
	ps -aux
	echo "[+] Package listing"
	apt list --installed || yum list installed
	echo "[+] Enabled services"
	system_type=$(ps --no-header -o comm 1 | grep - -n 1 systemd)
	if [[ "system_type" == "systemd" ]]; then
		systemctl is-enabled
	else
		service --status-all | grep +
	fi
	echo "[+] Interface listing"
	ifconfig -a
	echo "[+] Routing"
	netstat -rn
	echo "[+] hosts"
	cat etc/hosts
	echo "[+] ARP cache"
	arp -a
	echo "[+] DNS server"
	cat /etc/resolv.conf | awk '{ print $1 }'
	echo "[+] Network listing"
	netstat -tna
	echo "[+] Open file listing"
	lsof 
	echo "[+] Grabbing password data"
	cat /etc/passwd
	cat /etc/shadow
}

solaris_survey() {
	echo "[+] Process listing via"
	ps -ef
	echo "[+] Package listing"
	pkginfo
	echo "[+] Enabled services"
	system_type=$(sbin/init)
	if [[ "system_type" = "systemd" ]]; then
		systemctl is-enabled
	else
		svcs -a | grep online
	fi
	echo "[+] Interface listing"
	ifconfig -a
	echo "[+] Routing"
	netstat -rn
	echo "[+] hosts"
	cat /etc/hosts
	echo "[+] ARP cache"
	arp -a
	echo "[+] DNS server"
	cat /etc/resolv.conf | awk '{ print $1 }'
	echo "[+] Network listing"
	netstat
	echo "[+] Ope file listing"
	ps -A | awk '{ print $1 }' | xargs pfiles
	echo "[+] Grabbing password data"
	cat /etc/passwd
	cat /etc/shadow
}

while getopts ":o:" opt; do
	case $opt in
	o)
		output_file=$OPTARG
		;;
	esac
done

regex="^(Linux|SunOS)"
line=$(uname -mrs)
if [[ "$line" =~ $regex ]]; then
	os=$(echo ${BASH_REMATCH[1]})
	case $os in
	
		Linux)
			if(($#==0));
			then
			linux_survey
			else
			linux_survey 1> $output_file 2> /dev/null
			fi
		;;
		
		SunOS)
			if(($#==0));
			then
			linux_survey
			else
			linux_survey 1> $output_file 2> /dev/null
			fi
		;;
		
		*)
			echo -n "unknown"
			;;
		esac
else
		echo "No match"
fi
