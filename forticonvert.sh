#!/bin/bash

##########################################################################################################################################################
#																																						 #
#	Author: TheCL0wnS3C																																	 #
#																																						 #
#   Description : Forticonvert is a bash tool used to convert csv files containing objects,rules or interfaces to fortigate script configuration format  #
#   Use case : When migration from another brand firewall																								 #
# 																																						 #
#   Version = 1.0																																		 #
#																																						 #
##########################################################################################################################################################

# Variables

srcfile=$2
dstfile=$3
vdomoption=$4
vdomname=$5
version="1.0"

# Functions
help()
{
	echo -e "\n"
	echo -e " forticonvert.sh { -help | -h }  ==> Display this help\n"
	echo -e " forticonvert.sh { --address | -a} input_address-csv output-result.txt  ==> Convert CSV file containing Forti Addresses to script configuration file\n"
	echo -e " forticonvert.sh { --address-group | -agrp } input_address-group-csv output-result.txt  ==> Convert CSV file containing Forti Adresses Groups to script configuration file\n"
	echo -e " forticonvert.sh { --interfaces | -i } input_interfaces-csv output-result.txt  ==> Convert CSV file containing Forti Interfaces to script configuration file\n"
	echo -e " forticonvert.sh { --rules | -r } input_rules-csv output-result.txt  ==> Convert CSV file containing Forti Rules to script configuration file\n"
	echo -e " forticonvert.sh { --pools | -p } input_ippools-csv output-result.txt  ==> Convert CSV file containing Forti IP Pools to script configuration file\n"
	echo -e " forticonvert.sh { --vip | -v } input_vip-csv output-result.txt  ==> Convert CSV file containing Forti VIP Objects to script configuration file\n"
	echo -e " forticonvert.sh { --zones | -z } input_zones-csv output-result.txt  ==> Convert CSV file containing Forti Zones to script configuration file\n"
	echo -e " forticonvert.sh { --routes | -rtr } input_routes-csv output-result.txt  ==> Convert CSV file containing Forti Static Routes to script configuration file\n"
	echo -e " forticonvert.sh { --service | -s } input_services-csv output-result.txt  ==> Convert CSV file containing Forti Custom Services to script configuration file\n"
	echo -e " forticonvert.sh { --service | -s } input_services-group-csv output-result.txt  ==> Convert CSV file containing Forti  Services Group to script configuration file\n\n"
}

# If --vdom VDOM enable is set, set enablevdom var to 1, else set to 0
define-vdom()
{
	if [ ! -z $vdomoption ];then
		echo "vdom option activated" > /dev/null
		eval enablevdom="1"
	else
		echo "no vdom" > /dev/null
		eval enablevdom="0"
	fi
}

convert-address() 
{
	# Check if vdom option has been activated, if so, add vdom config to start of script file, else add only config XX to script file
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config firewall address" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall address" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi	
	IFS=";"
	# the use of tr is aim to remove the 0x0d that windows add when csv cell is empty
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3 f4 f5
	do
		case $f1 in
			"subnet"|"host")
							# sed used to add double quotes to name
							echo "edit $(echo $f2 | sed 's/^/"/;s/$/"/')"  >> $dstfile
							echo "set type ipmask" >> $dstfile
	        				echo "set subnet $f3" >> $dstfile
	        				# if associated-interface is empty, proceed else add set ass.. with cell value to script file
	        				 if [ "$f4" == "" ] ;then
	        				 	echo "no associated-interface, proceed"  > /dev/null
	        				 else
	        				 	echo "set associated-interface $f4" >> $dstfile
	        				 fi
	        				# if comment is empty, proceed else add add doubles quotes to value before appening to script file	        				 
	        				 if [ "$f5" == "" ];then
	        				 	echo "no object description, proceed" > /dev/null
	        				 else
	        				 	echo "set comment $(echo $f5 | sed 's/^/"/;s/$/"/')"  >> $dstfile
	        				 fi
	        				echo "next" >> $dstfile;;
	    	"fqdn") 
					echo "edit  $(echo $f2 | sed 's/^/"/;s/$/"/')"  >> $dstfile
	        		echo "set type $f1" >> $dstfile
	        		echo "set fqdn $f3" >> $dstfile
	        		# if associated-interface is empty, proceed else add set ass.. with cell value to script file
	        		if [ "$f4" == "" ] ;then
	        			echo "no associated-interface, nothing else to do"  > /dev/null
	        		else
	        			echo "set associated-interface $f4" >> $dstfile
	        		fi	        	
	        		# if comment is empty, proceed else add add doubles quotes to value before appening to script file
	        		if [ "$f5" == "" ];then
	        			echo "no object description, proceed" > /dev/null
	        		else
	        			echo "set comment $(echo $f5 | sed 's/^/"/;s/$/"/')"  >> $dstfile
	        		fi	        		
	        		echo "next" >> $dstfile;;
			*)
				echo "$f1 is a Bad type, object not converted" >> errors.log;;
		esac	
	done
	echo "end" >> $dstfile
}

convert-services() 
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config firewall service custom" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall service custom" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3
	do
		echo "edit $(echo $f1 | sed 's/^/"/;s/$/"/')"  >> $dstfile
		echo "set protocol TCP/UDP/SCTP" >> $dstfile
		if [ "$f2" == "TCP" ];then
			echo "set tcp-portrange $f3" >> $dstfile
		elif [ "$f2 == ¨UDP" ];then
			echo "set udp-portrange $f3" >> $dstfile
		else
			echo "Value $f2 not available" >> errors.log
		fi
		echo "next" >> $dstfile
	done
	echo "end" >> $dstfile
}

convert-rules()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config firewall policy" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall policy" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11
	do
		echo "	edit $f1"  >> $dstfile
		echo "		set srcintf $(echo $f2 | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "		set dstintf $(echo $f3 | sed 's/^/"/;s/$/"/')" >> $dstfile
    	echo "		set srcaddr $(echo $f4 | awk -vOFS=' ' '{for (k=1; k<=NF; ++k) $k="\""$k"\""; print}')" >> $dstfile
		echo "		set dstaddr $(echo $f5 | awk -vOFS=' ' '{for (k=1; k<=NF; ++k) $k="\""$k"\""; print}')" >> $dstfile
		echo "		set service $(echo $f6 | awk -vOFS=' ' '{for (k=1; k<=NF; ++k) $k="\""$k"\""; print}')" >> $dstfile
		echo "		set schedule $f7" >> $dstfile
		# Check if nat cell is empty, proceed to next action, else echo nat enable in script file, then check if there is a ippool value, if so add pool options to rule in script file, else proceed to next action	
		if [ "$f8" == "enable" ];then
		echo "		set nat enable" >> $dstfile
			if [ ! -z $f9 ]; then
				echo "		set ippool enable" >> $dstfile
				echo "		set poolname $(echo $f9 | sed 's/^/"/;s/$/"/')" >> $dstfile
			else
				echo "Default outgoing pool by default" >> /dev/null
			fi
		else
			echo "Nat disabled by default" > /dev/null
		fi
		# Check if name cell is empty, proceed to next action, else add double quotes to name then appened value to script file		
		if [[ "$f11" == "" ]];then
			echo "No name given for the rule, skipping" > /dev/null
		else
			echo "		set name $(echo $f11 | sed 's/^/"/;s/$/"/')" >> $dstfile
		fi
		echo "		set action $f10" >> $dstfile
		echo "		next" >> $dstfile
	done
	echo "end" >> $dstfile
}

convert-interfaces()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config system interface" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config system interface" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3 f4 f5 f6 f7
	do
		case $f1 in 
			"interface")
	       		echo "edit $(echo $f2 | sed 's/^/"/;s/$/"/')"  >> $dstfile
	        	echo "set mode static" >> $dstfile
				echo "set ip $f3" >> $dstfile
				echo "next" >> $dstfile;;
			"vlan")
				echo "edit $(echo $f2 | sed 's/^/"/;s/$/"/')"  >> $dstfile
	        	echo "set type $f1" >> $dstfile
	       		echo "set ip $f3" >> $dstfile
	        	echo "set vlanid $f7" >> $dstfile
	        	echo "set vdom $f6" >> $dstfile
	        	echo "set interface (echo $f5 | sed 's/^/"/;s/$/"/')" >> $dstfile
	        	echo "next" >> $dstfile;;
	     	"aggregate")
				echo "edit $(echo $f2 | sed 's/^/"/;s/$/"/')" >> $dstfile
	        	echo "set type $f1" >> $dstfile
	        	echo "set member $(echo $f4 | awk -vOFS=' ' '{for (k=1; k<=NF; ++k) $k="\""$k"\""; print}')" >> $dstfile
	        	echo "set vdom $f6" >> $dstfile
	        	echo "next" >> $dstfile;;
	    	*) 
				echo "$f1 is a Bad type, interface not converted" >> errors.log;;
		esac

	done
	echo "end" >> $dstfile
}

convert-ippools()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config firewall ippool" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall ippool" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3 f4 f5 f6 
	do
		echo "edit $(echo $f1 | sed 's/^/"/;s/$/"/')"  >> $dstfile
		echo "set type $f2" >> $dstfile
		echo "set startip $f3" >> $dstfile
		echo "set endip $f4" >> $dstfile
		if [ "$f2" == "fixed-port-range" ];then
			echo "set source-startip $f5" >> $dstfile
			echo "set source-endip $f6" >> $dstfile
		else
			echo "Not fixed-port-range, nothing else to do" > /dev/null
		fi
		echo "next" >> $dstfile
	done
	echo "end" >> $dstfile
}

convert-vip()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config firewall vip" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall vip" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3
	do
		echo "edit $(echo $f1 | sed 's/^/"/;s/$/"/')"  >> $dstfile
		echo "set extip $f2" >> $dstfile
		echo 'set extintf "any"' >> $dstfile
		echo "set mappedip $f3" >> $dstfile
		echo "next" >> $dstfile
	done
	echo "end" >> $dstfile
}

convert-zones()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config system zone" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config system zone" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3  
	do
		echo "edit $(echo $f1 | sed 's/^/"/;s/$/"/')"  >> $dstfile
		echo "set interface $(echo $f2 | awk -vOFS=' ' '{for (k=1; k<=NF; ++k) $k="\""$k"\""; print}')" >> $dstfile
		echo "set intrazone $f3" >> $dstfile
		echo "next" >> $dstfile
		done
		echo "end" >> $dstfile	
}

convert-routes()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config router static" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config router static" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2 f3 f4 f5 f6
	do
		echo "edit $f1"  >> $dstfile
		echo "set dst $f2" >> $dstfile
		echo "set gateway $f3" >> $dstfile
		echo "set device $(echo $f4 | sed 's/^/"/;s/$/"/')" >> $dstfile
		# If distance and/or priority value is a number, add corresponding lines to script file, else do not set it
		if [[ "$f5" == *[0-9]* ]];then
				echo "set distance $f5" >> $dstfile
		else
				echo "distance not set" > /dev/null
		fi		
		if [[ "$f6" == *[0-9]* ]];then
				echo "set priority $f6" >> $dstfile
		else
				echo "priority not set" > /dev/null
		fi
		echo "next" >> $dstfile
		done
		echo "end" >> $dstfile
}

convert-addrgrp()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config firewall addrgrp" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall addrgrp" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2  
	do
		echo "edit $(echo $f1 | sed 's/^/"/;s/$/"/')"  >> $dstfile
		echo "set member $(echo $f2 | awk -vOFS=' ' '{for (k=1; k<=NF; ++k) $k="\""$k"\""; print}')" >> $dstfile
		echo "next" >> $dstfile
	done
		echo "end" >> $dstfile		
}

convert-servicesgrp()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $(echo $vdomname | sed 's/^/"/;s/$/"/')" >> $dstfile
		echo "config firewall service group" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall service group" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	tr -d '\r' < $srcfile | sed '1d' | while read f1 f2  
	do
		echo "edit $(echo $f1 | sed 's/^/"/;s/$/"/')"  >> $dstfile
		echo "set member $(echo $f2 | awk -vOFS=' ' '{for (k=1; k<=NF; ++k) $k="\""$k"\""; print}')" >> $dstfile
		echo "next" >> $dstfile
	done
		echo "end" >> $dstfile	
}

# Main 

define-vdom
case $1 in
	--help|-h) help;;
	--address|-a) convert-address;;
	--address-group|-agrp) convert-addrgrp;;
	--rules|-r) convert-rules;;
	--interfaces|-i) convert-interfaces;;
	--pools|-p) convert-ippools;;
	--vip|-v) convert-vip;;
	--zones|-z) convert-zones;;
	--routes|-rtr) convert-routes;;
	--service|-s) convert-services;;
	--service-group|-sgrp) convert-servicesgrp;;
	--version) echo -e "forticonvert v$version\n";;
	*) echo -e "Bad Option, please retry (use -h or --help to display usage\n";;
esac

