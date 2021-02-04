# forticonvert

Forticonvert is a bash tool to convert CSV files containing fortigate configuration such as static routes, filter policy...

CSV files must be generate based on the Global.xls example. You'll need one csv file per configuration types. (copy/paste header columns of global file to a new excel file and fill it.

Available configurations for convertion :

- interfaces
- zones
- static routes
- objects
- custom services
- ip pools
- rules (filtering policy)

### Usage
```
chmod a+x forticonvert.sh
./forticonvert {option} input-csv-file output-script-file
```


##Help :

```
 forticonvert.sh { -help | -h }  ==> Display help
 forticonvert.sh { --object | -o} input_object-csv output-result.txt  ==> Convert CSV file containing Forti Objects to script configuration file
 forticonvert.sh { --interfaces | -i } input_interfaces-csv output-result.txt  ==> Convert CSV file containing Forti Interfaces to script configuration file
 forticonvert.sh { --rules | -r } input_rules-csv output-result.txt  ==> Convert CSV file containing Forti Rules to script configuration file
 forticonvert.sh { --pools | -p } input_ippools-csv output-result.txt  ==> Convert CSV file containing Forti IP Pools to script configuration file
 forticonvert.sh { --zones | -z } input_zones-csv output-result.txt  ==> Convert CSV file containing Forti Zones to script configuration file
 forticonvert.sh { --routes | -rtr } input_routes-csv output-result.txt  ==> Convert CSV file containing Forti Static Routes to script configuration file
 forticonvert.sh { --service | -s } input_services-csv output-result.txt  ==> Convert CSV file containing Forti Custom Services to script configuration file``
```
