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
- users : `root`, `[42login]` (in groups `user42` `sudo`)
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
- install ditro
- take fresh install snapshot for backups
- open ssh port with NAT

### change console font
- `sudo dpkg-reconfigure console-setup`
### change default editor
- `sudo update-alternatives --config editor`
### apparmor
- [⭧ official doc](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)
- show status `/usr/sbin/aa-status`
- [⭧ security flaws](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/apparmor)
### ufw
- [⭧ digitalocean tuto](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu)
- install `sudo apt install ufw`
- deny incoming connection `sudo ufw default deny incoming`
- allow outgoing connections `sudo ufw default allow outgoing`
- allow port `sudo ufw allow [portnumber]`
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
- connect via ssh `ssh [login]@localhost -p 4242` (22 before configuration)
    - configure nat port in virtualbox (host and guest ports)
### hostname
- show hostname `hostnamectl` or `hostname`
- modifiy hostname `sudo hostnamectl set-hostname [login42]`
### users and groups
- show user infos `id [username]`
#### users
- [⭧ arch wiki](https://wiki.archlinux.org/title/Users_and_groups)
- [⭧ tecmint tuto](https://www.tecmint.com/add-users-in-linux/)
- list user `cat /etc/passwd` (ou `getent passwd`)
- remove user, user's home and mail spool `userdel -r [username]`
- show default config `useradd -D`
- create user (high level debian compliant command version) `adduser [username]`
    - with the low level command `useradd [username]` & `passwd [username]`
#### passwords
- show passwords policy `chage -l`
#### groups
- [⭧ redhat blog](https://www.redhat.com/en/blog/linux-groups)
- show groups which user belongs to `groups`
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

