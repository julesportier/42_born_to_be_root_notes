#! /bin/bash

# Create the file to store monitoring data
if [[ ! -e monitoring.txt ]]; then
        touch monitoring.txt
fi
file=monitoring.txt

# Some utility functions to append text to file
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
overwrite_file "	#Architecture: "
append_text_nl "`uname -a`"

append_text "	#CPU physical: "
append_text_nl "`grep "physical id" /proc/cpuinfo | uniq | wc -l`"
append_text "	#vCPU: "
append_text_nl "`nproc --all`"

append_text "	#Memory available: "
available_ram=`free -m | grep "Mem" | awk '{print $7}'`
total_ram=`free -m | grep "Mem" | awk '{print $2}'`
rate_ram=`free | grep "Mem" | awk '{printf("%.2f"), $7/$2*100}'`
append_text_nl "${available_ram}/${total_ram}MiB (${rate_ram}%)"

append_text "	#Disk space available: "
available_disk=`df -m -t ext4 | grep / | grep -v boot | awk '{ SUM+=$4 } END { print SUM }'`
total_disk=`df -m -t ext4 | grep / | grep -v boot | awk '{ SUM+=$2 } END { print SUM }'`
rate_disk=`df -m -t ext4 | grep / | grep -v boot | awk '{ SUM+=$5 ; I++ } END { printf("%.2f"), 100-(SUM/I) ; print I }'`
append_text_nl "${available_disk}/${total_disk}MiB (${rate_disk}%)"

append_text "	#Cpu load: "
append_text_nl "`top -b -n 1 | grep '%Cpu(s)' | awk '{ print ($2+$4+$6) }'`%"

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
wall monitoring.txt
