Old project, not up-do-date. Will be redone when got time to do it.

Use at your own risk.

# forticonvert

Forticonvert is a bash tool to convert CSV files containing fortigate configuration such as static routes, filter policy...

You'll need one csv file per configuration types (templates are available in the repo)

Read INSTRUCTIONS.txt in csv_template folder before fill in csv files !!!!

Available configurations for convertion :

- interfaces
- zones
- static routes
- addresses
- adresses groups
- custom services
- services groups
- ip pools
- VIP
- rules (filtering policy)

### Usage
```
git clone https://github.com/Th3CL0wnS3c/forticonvert.git
cd forticonvert && chmod a+x forticonvert.sh
./forticonvert {option} input-csv-file output-script-file {--vdom VDOM_NAME}  #the vdom option is optionnal
```

### Help :

```
forticonvert.sh { -help | -h }  ==> Display this help
forticonvert.sh { --address | -a} input_addresses-csv output-result.txt  ==> Convert CSV file containing Forti Objects to script configuration file
forticonvert.sh { --address-group | -agrp } input_address-group-csv output-result.txt  ==> Convert CSV file containing Forti Adresses Groups to script configuration fil
forticonvert.sh { --interfaces | -i } input_interfaces-csv output-result.txt  ==> Convert CSV file containing Forti Interfaces to script configuration file
forticonvert.sh { --rules | -r } input_rules-csv output-result.txt  ==> Convert CSV file containing Forti Rules to script configuration file
forticonvert.sh { --pools | -p } input_ippools-csv output-result.txt  ==> Convert CSV file containing Forti IP Pools to script configuration file
forticonvert.sh { --vip | -v } input_vip-csv output-result.txt  ==> Convert CSV file containing Forti VIP Objects to script configuration file
forticonvert.sh { --zones | -z } input_zones-csv output-result.txt  ==> Convert CSV file containing Forti Zones to script configuration file
forticonvert.sh { --routes | -rtr } input_routes-csv output-result.txt  ==> Convert CSV file containing Forti Static Routes to script configuration file
forticonvert.sh { --service | -s } input_services-csv output-result.txt  ==> Convert CSV file containing Forti Custom Services to script configuration file
forticonvert.sh { --service-group | -sgrp } input_services-group-csv output-result.txt  ==> Convert CSV file containing Forti  Services Group to script configuration file

Add --vdom VDOM_NAME at the end of the command to convert configuration for specific vdom (VDOM_NAME has to be case sensitive => Space are forbidden in VDOM NAME, prefer use of - or _)
```

Demo Video : Available soon
