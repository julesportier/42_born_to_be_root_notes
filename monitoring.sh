#! /bin/bash

# Some utility functions to append text to file
file=/tmp/monitoring.log
overwrite_file() {
        echo -n "$1" > $file
}
append_text() {
        echo -n "$1" >> $file
}
append_text_nl() {
        echo "$1" >> $file
}

# Append infos to the file
overwrite_file "root talks to you on `date`:"
append_text_nl $'\n'

append_text "	#Architecture: "
append_text_nl "`uname -a`"

append_text "	#CPU physical: "
append_text_nl "`grep "physical id" /proc/cpuinfo | uniq | wc -l`"
append_text "	#vCPU: "
append_text_nl "`nproc --all`"

append_text "	#Memory usage: "
append_text_nl "`free -m | awk '/Mem/ {printf "%d/%dMiB (%.2f)%%", $3, $2, $3/$2*100}'`"

append_text "	#Disk usage: "
append_text_nl "`df -m -t ext4 | grep / | grep -v boot | awk '{ USAGE+=$3 ; TOTAL+=$2 ; I++ } END { printf "%d/%dMiB (%.2f)%%", USAGE, TOTAL, USAGE/TOTAL*100 }'`"

append_text "	#Cpu load: "
append_text_nl "`top -b -d .8 -n 5 | awk -F , '/%Cpu\(s\)/ { ID+=$4 ; RUNS++ } END { printf "%.2f%%", 100-(ID/RUNS) }'`"

append_text "	#Last boot: "
append_text_nl "`uptime -s`"

append_text "	#LVM use: "
append_text_nl "`lsblk | awk '{ I+=($6=="lvm") } END { print (I > 0) ? "yes" : "no" }'`"

append_text "	#TCP connections: "
append_text_nl "`ss -tH state established | wc -l` ESTABLISHED"

append_text "	#Users logged: "
append_text_nl "`users | wc -w`"

append_text "	#Network: "
append_text_nl "IPv4 `hostname -I` MAC `ip link | awk '/ether/ { print $2 }'`"

append_text "	#Sudo commands: "
append_text_nl "`cat /var/log/sudo/sudo.log | grep 'COMMAND' | wc -l`"

# Show the content of the file
wall --nobanner $file
