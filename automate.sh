#!/bin/bash

bash forticonvert.sh -i csv_input/interfaces.csv scripts_output/int-script.txt
bash forticonvert.sh -o csv_input/objects.csv scripts_output/obj-script.txt
bash forticonvert.sh -p csv_input/pools.csv scripts_output/pools-script.txt
bash forticonvert.sh -rtr csv_input/routes.csv scripts_output/routes-script.txt
bash forticonvert.sh -r csv_input/rules.csv scripts_output/rules-script.txt
bash forticonvert.sh -z csv_input/zones.csv scripts_output/zones-script.txt
bash forticonvert.sh -s csv_input/services.csv scripts_output/services-script.txt
