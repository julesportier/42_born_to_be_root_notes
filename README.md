# 42_born_to_be_root_notes
Notes for born_to_be_root 42 project

## Submission
- The signature of the virtual machine in a file called signature.txt

## Requirements
- Install latest Debian stable or Rocky) in VirtualBox 
> ! All past notes will be for Debian
- Partition with lvm, encrypt all partitions including swap except /boot
- Set up AppArmor to start at boot (in rocky it's SELinux)
- ssh service running on port 4242, disable root on ssh
- ufw firewall only opens port 4242
- hostname `juportie42`
- configure sudo
    - <= 3 wrong sudo attempts
    - display a message when 3rd wrong sudo password
    - archive each sodu command in /var/log/sudo/
    - tty mode must be enabled
    - sudo paths must be restricted (eg. /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/snap/bin)
- users : `root`, `juportie42` (in groups `user42` `sudo`)
- Passwords :
    - \>= 10 chars, >= 1 uppercase letter, >= 1 lowercase letter, >= 1 number, <= 3 consecutive identical characters
    - must not include name of the user
    - \>= 7 characters different from root password
    - expires every 30 days, warning message 7 days before
    - can be modified at a minimum every 48h
- every 10 minutes monitoring.sh display some infos on screen (pdf page 8)
- check requirements with :
    - `head -n 2 /etc/os-release`
    - `/usr/sbin/aa-status` apparmor
    - `ss -tunlp` sockets state (open port)
    - `/usr/sbin/ufw status` firewall
