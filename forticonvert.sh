#!/bin/bash

help()
{
	echo -e "\nForticonvert is a shell tool used to convert csv files containing objects,rules or interfaces to fortigate script configuration format\n"
	echo -e "Usage : \n"
	echo -e " forticonvert.sh { -help | -h }  ==> Display this help\n"
	echo -e " forticonvert.sh { --address | -a} input_object-csv output-result.txt  ==> Convert CSV file containing Forti Objects to script configuration file\n"
	echo -e " forticonvert.sh { --interfaces | -i } input_interfaces-csv output-result.txt  ==> Convert CSV file containing Forti Interfaces to script configuration file\n"
	echo -e " forticonvert.sh { --rules | -r } input_rules-csv output-result.txt  ==> Convert CSV file containing Forti Rules to script configuration file\n"
	echo -e " forticonvert.sh { --pools | -p } input_ippools-csv output-result.txt  ==> Convert CSV file containing Forti IP Pools to script configuration file\n"
	echo -e " forticonvert.sh { --vip | -v } input_vip-csv output-result.txt  ==> Convert CSV file containing Forti VIP Objects to script configuration file\n"
	echo -e " forticonvert.sh { --zones | -z } input_zones-csv output-result.txt  ==> Convert CSV file containing Forti Zones to script configuration file\n"
	echo -e " forticonvert.sh { --routes | -rtr } input_routes-csv output-result.txt  ==> Convert CSV file containing Forti Static Routes to script configuration file\n"
	echo -e " forticonvert.sh { --service | -s } input_services-csv output-result.txt  ==> Convert CSV file containing Forti Custom Services to script configuration file\n\n"
}

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
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $vdomname" >> $dstfile
		echo "config firewall address" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall address" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi	
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3 #f4
	do
		case $f1 in
			"subnet"|"host")
							echo "edit $f2"  >> $dstfile
							echo "set type ipmask" >> $dstfile
	        				echo "set subnet $f3" >> $dstfile
	        				# Optional Associated interface to object --> Not working
	        				# if [ -z "$f4" ];then
	        				# 	echo ""
	        				# else
	        				# 	echo "set associated-interface $f4" >> $dstfile
	        				# fi
	        				echo "next" >> $dstfile;;
	    	"fqdn") 
					echo "edit $f2"  >> $dstfile
	        		echo "set type $f1" >> $dstfile
	        		echo "set fqdn $f3" >> $dstfile
	        		# Optional Associated interface to object --> Not working
	        		# if [ ! -z $f4 ];then
	        		# 	echo "set associated-interface $f4" >> $dstfile
	        		# else
	        		# 	echo "No associated-interface" > /dev/null
	        		# fi	        		
	        		echo "next" >> $dstfile;;
			*)
				echo "$f1 is a Bad type, object not converted" > /dev/null;;
		esac	
	done
	echo "end" >> $dstfile
}

convert-services() 
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $vdomname" >> $dstfile
		echo "config firewall service custom" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall service custom" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3
	do
		echo "edit $f1"  >> $dstfile
		echo "set protocol TCP/UDP/SCTP" >> $dstfile
		if [ "$f2" == "TCP" ];then
			echo "set tcp-portrange $f3" >> $dstfile
		elif [ "$f2 == ¨UDP" ];then
			echo "set udp-portrange $f3" >> $dstfile
		else
			echo "Value not available" > /dev/null
		fi
		echo "next" >> $dstfile
	done
	echo "end" >> $dstfile
}

convert-rules()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $vdomname" >> $dstfile
		echo "config firewall policy" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall policy" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
	do
		echo "	edit $f1"  >> $dstfile
		echo "		set srcintf $f2" >> $dstfile
		echo "		set dstintf $f3" >> $dstfile
    	echo "		set srcaddr $f4" >> $dstfile
		echo "		set dstaddr $f5" >> $dstfile
		echo "		set service $f6" >> $dstfile
		echo "		set schedule $f7" >> $dstfile
		if [ "$f8" == "enable" ];then
		echo "		set nat enable" >> $dstfile
			if [ ! -z $f9 ]; then
				echo "		set ippool enable" >> $dstfile
				echo "		set poolname $f9" >> $dstfile
			else
				echo "Default outgoing pool by default" >> /dev/null
			fi
		else
			echo "Nat disabled by default" > /dev/null
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
		echo "edit $vdomname" >> $dstfile
		echo "config system interface" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config system interface" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3 f4 f5 f6 f7
	do
		case $f1 in 
			"interface")
	       		echo "edit $f2"  >> $dstfile
	        	echo "set mode static" >> $dstfile
				echo "set ip $f3" >> $dstfile
				echo "next" >> $dstfile;;
			"vlan")
				echo "edit $f2"  >> $dstfile
	        	echo "set type $f1" >> $dstfile
	       		echo "set ip $f3" >> $dstfile
	        	echo "set vlanid $f7" >> $dstfile
	        	echo "set vdom $f6" >> $dstfile
	        	echo "set interface $f5" >> $dstfile
	        	echo "next" >> $dstfile;;
	     	"aggregate")
				echo "edit $f2" >> $dstfile
	        	echo "set type $f1" >> $dstfile
	        	echo "set member $f4" >> $dstfile
	        	echo "set vdom $f6" >> $dstfile
	        	echo "next" >> $dstfile;;
	    	*) 
				echo "$f1 is a Bad type, interface not converted"> /dev/null;;
		esac

	done
	echo "end" >> $dstfile
}

convert-ippools()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $vdomname" >> $dstfile
		echo "config firewall ippool" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall ippool" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3 f4 f5 f6 
	do
		echo "edit $f1"  >> $dstfile
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
		echo "edit $vdomname" >> $dstfile
		echo "config firewall vip" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall vip" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3
	do
		echo "edit $f1"  >> $dstfile
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
		echo "edit $vdomname" >> $dstfile
		echo "config system zone" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config system zone" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3  
	do
		echo "edit $f1"  >> $dstfile
		echo "set interface $f2" >> $dstfile
		echo "set intrazone $f3" >> $dstfile
		echo "next" >> $dstfile
		done
		echo "end" >> $dstfile	
}

convert-addrgrp()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $vdomname" >> $dstfile
		echo "config firewall addrgrp" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config firewall addrgrp" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2
	do
		echo "edit $f1"  >> $dstfile
		echo "set member $f2" >> $dstfile
		echo "next" >> $dstfile
	done
	echo "end" >> $dstfile	
}

convert-routes()
{
	if [ $enablevdom == "1" ];then
		echo "config vdom" > $dstfile
		echo "edit $vdomname" >> $dstfile
		echo "config router static" >> $dstfile
	elif [ $enablevdom == "0" ];then
		echo "config router static" > $dstfile
	else
		echo "BAD VDOM return value, stop" > /dev/null
	fi
	IFS=";"
	sed '1d' $srcfile | while read f1 f2 f3 f4 f5 f6
	do
		echo "edit $f1"  >> $dstfile
		echo "set dst $f2" >> $dstfile
		echo "set gateway $f3" >> $dstfile
		echo "set device $f4" >> $dstfile
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

srcfile=$2
dstfile=$3
vdomoption=$4
vdomname=$5

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
	*) echo -e "Bad Option, please retry (use -h or --help to display usage\n";;
esac

