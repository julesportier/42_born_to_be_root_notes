# 42_born_to_be_root_notes
Notes for born_to_be_root 42 project

## Submission
- The signature of the virtual machine in a file called signature.txt

## Requirements
- Install latest Debian stable (or Rocky) in VirtualBox 
>  ! All past notes will be for Debian
- Partition with lvm, encrypt all partitions including swap except /boot
- Set up AppArmor to start at boot (in rocky it's SELinux)
- ssh service running on port 4242, disable root on ssh
- ufw firewall only opens port 4242
- hostname `juportie42`
- configure sudo
    - <= 3 wrong sudo attempts
    - display a custom message when wrong sudo password
    - archive each sudo command in /var/log/sudo/
    - tty mode must be enabled
    - sudo paths must be restricted (eg. /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin)
- users : `root`, `42LOGIN` (in groups `user42` `sudo`)
- Passwords :
    - \>= 10 chars, >= 1 uppercase letter, >= 1 lowercase letter, >= 1 number, <= 3 consecutive identical characters
    - must not include name of the user
    - \>= 7 characters different from old password
    - expires every 30 days, warning message 7 days before
    - can be modified at a minimum every 48h
- every 10 minutes monitoring.sh display some infos on screen (pdf page 8)
- check requirements with :
    - `head -n 2 /etc/os-release`
    - `/usr/sbin/aa-status` apparmor
    - `ss -tunlp` sockets state (open port)
    - `/usr/sbin/ufw status` firewall
- TODO bonuses

## Notes
### virtual box
- create a virtual disk
- install distro
- take fresh install snapshot for backups
- open ssh port with NAT

### change console font
- `sudo dpkg-reconfigure console-setup`
### change default editor
- `sudo update-alternatives --config editor`

### luks encryption
- [⭧ show infos and change password](https://www.cyberciti.biz/security/how-to-change-luks-disk-encryption-passphrase-in-linux/)

### apparmor
- [⭧ official doc](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)
- show status `/usr/sbin/aa-status`
- [⭧ security flaws](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/apparmor)
### ufw
- [⭧ digitalocean tuto](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu)
- install `sudo apt install ufw`
- deny incoming connection `sudo ufw default deny incoming`
- allow outgoing connections `sudo ufw default allow outgoing`
- allow port `sudo ufw allow PORTNUMBER`
- start ufw `sudo ufw enable` (now and at boot)
- show all rules `sudo ufw status verbose`
### ssh
- [⭧ debian wiki](https://wiki.debian.org/SSH)
- service status `systemctl status ssh`
- show ssh port `ss -tnlp | grep -i ssh`
- config files in `/etc/ssh/` in `/ssh_config` & `/sshd_config` or the same files in `*/ssh[d]_config.d/*.conf` (not erased by updates)
    - in sshd_config file
        - set `Port 4242`
        - set `PermitRootLogin no` to disable connecting as root
- connect via ssh `ssh USERNAME@localhost -p 4242` (22 before configuration)
    - configure nat port in virtualbox (host and guest ports)
### hostname
- show hostname `hostnamectl` or `hostname`
- modifiy hostname `sudo hostnamectl set-hostname LOGIN42`
### users and groups
- show user infos `id USERNAME`
#### users
- [⭧ arch wiki](https://wiki.archlinux.org/title/Users_and_groups)
- [⭧ tecmint tuto](https://www.tecmint.com/add-users-in-linux/)
- list user `cat /etc/passwd` (ou `getent passwd`)
- remove user, user's home and mail spool `userdel -r USERNAME`
- show default config `useradd -D`
- create user (high level debian compliant command version) `adduser USERNAME`
    - with the low level command `useradd USERNAME` & `passwd USERNAME`
#### passwords
##### PAM
- [⭧ ostechnix tuto](https://ostechnix.com/force-users-use-strong-passwords-debian-ubuntu/)
- [⭧ ostechnix tuto](https://ostechnix.com/how-to-set-password-policies-in-linux/)
- PAM (Pluggable Authentification Module) passwords config file is located at `/etc/pam.d/common-password`
- `man 8 cracklib`
- install pwquality module to set password complexity `sudo apt install libpam-pwquality`
- make a backup before changes `sudo cp /etc/pam.d/common-password /etc/pam.d/common-password.bak`
- add rules at the end of the line containing `pam_pwquality.so` :
    - `minlen=10`
    - uppercase `ucredit=-1`
    - lowercase `lcredit=-1`
    - digit `dcredit=-1`
    - max consecutive characters `maxrepeat=3`
    - don't include user login `reject_username`
    - require minimum characters changes from old password `difok=7`
    - apply same rules for root `enforce_for_root`
- set password expiration period for new users :
    ``` sh
    sudo nvim /etc/login.defs
    # add this lines to the file
    PASS_MAX_DAYS   30
    PASS_MIN_DAYS   2
    PASS_WARN_AGE   7
    ```
- set password expiration period for existing users (must type each users login):
    - max password time `sudo chage -M 30 USERNAME`
    - min password time `sudo chage -m 2 USERNAME`
    - warning before expiration `sudo chage -W 7 USERNAME`
- show passwords policy `chage -l USERNAME`
- change password `passwd`

#### groups
- [⭧ redhat blog](https://www.redhat.com/en/blog/linux-groups)
- show groups which user belongs to `groups [username]`
- create group `sudo groupadd [groupname]`
- delete group `sudo groupdel [groupname]`
- append this group to the user groups belong to `sudo usermod -aG [groupname] [username]`
### sudo
- [⭧ tecmint tuto](https://www.tecmint.com/sudoers-configurations-for-setting-sudo-in-linux/)
- `sudo apt install sudo`
- `sudo usermod -aG sudo [username]`
- >  ! configure /etc/sudoers with `sudo visudo` to avoid errors
- config file in /etc/sudoers
#### config
- `Defaults requiretty` protects running sudo from non interactive shells (eg. scripts, cron...)
- `Defaults passwd_tries=3` only allow 3 consecutive password attempts
- `Defaults badpass_message="[string]"` custom message for password error (`Defaults insults` for random insult message)
- `Defaults logfile=/var/log/sudo/sudo.log` change default logfile location
- `Defaults iolog_dir=/var/log/sudo/sudo-io` change default io logfile location
- `Defaults log_input` & `Defaults log_output` keep all inputs and outputs (even passwords !)
### system infos bash script
- `cd /usr/local/sbin` `touch monitoring.sh`
- copy from local machine to vm :
in host machine `scp -P 4242 monitoring.sh juportie@localhost:~/monitoring.sh`
in VM as root `mv /home/juportie/monitoring.sh /usr/local/bin/monitoring.sh`
- [bash script](./monitoring.sh)
- [⭧ bash cheatsheet](https://devhints.io/bash)
- [⭧ command as function argument](https://www.baeldung.com/linux/bash-pass-function-arg)
- [⭧ awk cheatsheet](https://quickref.me/awk.html)
#### crontab
- [⭧ linuxhandbook tuto](https://linuxhandbook.com/crontab/)
- show crontab infos/status `crontab -l`
- edit the table `crontab -e`

### bonuses
- [⭧ lighttpd install tuto](https://orcacore.com/install-lighttpd-web-server-debian-12/)
- configure mariadb `sudo mariadb_secure_installation`
- open mariadb shell `sudo mariadb -u root -p`
- [⭧ wordpress install tuto](https://www.osradar.com/install-wordpress-with-lighttpd-debian-10/)
