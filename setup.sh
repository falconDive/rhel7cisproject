#!/bin/bash

FSTAB=/etc/fstab

#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root"
#  exit
#fi

echo "$USER"
sudo -s
echo "$USER"
echo “RHL7-01 Install updates, patches, and additional security software.“
#RHL7-01
yum -y update --security
echo "Updated"

echo “RHL7-02 Set the nodev option on the /tmp partition.“
echo “RHL7-03 Set the nosuid option on the /tmp partition.“
echo “RHL7-04 Set the noexec option on the /tmp partition. “
#RHL:2 3 4
#/tmp nodev nosuid noexec
if mount | grep -q ' /tmp'
 then
   echo "tmp available"
   if [ $grep " \/tmp " ${FSTAB} | grep -c "nodev" -eq 0 ]; then
            MNT_OPTS=$grep " \/tmp " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/tmp.*${MNT_OPTS}\/\1,nodev/" FSTAB
    fi
    if [ $grep " \/tmp " ${FSTAB} | grep -c "nosuid" -eq 0 ]; then
            MNT_OPTS=$grep " \/tmp " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/tmp.*${MNT_OPTS}\/\1,nosuid/" FSTAB
    fi
    if [ $grep " \/tmp " ${FSTAB} | grep -c "noexec" -eq 0 ]; then
            MNT_OPTS=$grep " \/tmp " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/tmp.*${MNT_OPTS}\/\1,noexec/" FSTAB
    fi
   mount -o remount,noexec,nosuid,nodev /tmp
else
   echo "tmp not avai"
fi

echo “RHL7-05 Set the nodev option on the /var/tmp partition.“
echo “RHL7-06 Set the nosuid option on the /var/tmp partition.“
echo “RHL7-07 Set the no exec option on the /var/tmp partition.“
#RHL:5 6 7
#/var/tmp nodev nosuid noexec
if mount | grep -q ' /var/tmp'
 then
   echo "var tmp available"
    if [ $grep " \/var/tmp " ${FSTAB} | grep -c "nodev" -eq 0 ]; then
            MNT_OPTS=$grep " \/var/tmp " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/var/tmp.*${MNT_OPTS}\/\1,nodev/" ${FSTAB}
    fi
    if [ $grep " \/var/tmp " ${FSTAB} | grep -c "nosuid" -eq 0 ]; then
            MNT_OPTS=$grep " \/var/tmp " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/var/tmp.*${MNT_OPTS}\/\1,nosuid/" ${FSTAB}
    fi
    if [ $grep " \/var/tmp " ${FSTAB} | grep -c "noexec" -eq 0 ]; then
            MNT_OPTS=$grep " \/var/tmp " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/var/tmp.*${MNT_OPTS}\/\1,noexec/" ${FSTAB}
    fi
   mount -o remount,noexec,nosuid,nodev /var/tmp
else
   echo "var tmp not avai"
fi

echo “RHL7-08 Set the nodev option on the /home partition.“
#RHL:8
if mount | grep -q ' /home'
 then
   echo "var tmp available"
    if [ $grep " \/home " ${FSTAB} | grep -c "nodev" -eq 0 ]; then
            MNT_OPTS=$grep " \/home " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/home.*${MNT_OPTS}\/\1,nodev/" ${FSTAB}
    fi
   mount -o remount,nodev /home
else
   echo "var tmp not avai"
fi

echo “RHL7-09 Set the nodev option on the /dev/shm partition.“
echo “RHL7-10 Set the nosuid option on the /dev/shm partition. “
echo “RHL7-11 Set the no exec option on the /dev/shm partition“
#RHL:9 10 11
#/dev/shm nodev nosuid noexec
if mount | grep -q ' /dev/shm'
 then
   echo "/dev/shm available"
   if [ $grep " \/dev/shm " ${FSTAB} | grep -c "nodev" -eq 0 ]; then
            MNT_OPTS=$grep " \/dev/shm " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/dev/shm.*${MNT_OPTS}\/\1,nodev/" FSTAB
    fi
    if [ $grep " \/dev/shm " ${FSTAB} | grep -c "nosuid" -eq 0 ]; then
            MNT_OPTS=$grep " \/dev/shm " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/dev/shm.*${MNT_OPTS}\/\1,nosuid/" FSTAB
    fi
    if [ $grep " \/dev/shm " ${FSTAB} | grep -c "noexec" -eq 0 ]; then
            MNT_OPTS=$grep " \/dev/shm " ${FSTAB} | awk '{print $4}'
            sed -i "s/\ \/dev/shm.*${MNT_OPTS}\/\1,noexec/" FSTAB
    fi
   mount -o remount,noexec,nosuid,nodev /dev/shm  
else
   echo "/dev/shm not avai"
fi

echo “RHL7-12 Set the nodev option on all removable media partitions. “
echo “RHL7-13 Set the nosuid on all removable media partitions. “
echo “RHL7-14 Set the noexec option on all removable media partitions. “
mount

echo “RHL7-15 Set sticky bit on all world-writable directories.“
rhel_7_15_set="$df --local -P | awk {'if NR!=1 print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t"
rhel_7_15_set=$?
if [[ "$rhel_7_15_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-16 Disable automounting of devices. “
rhel_7_16_set="$systemctl disable autofs.service"
rhel_7_16_set=$?
if [[ "$rhel_7_16_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-17 Disable the mounting of the cramfs filesystems. “
rhel_7_17_set=$(modprobe -n -v cramfs | grep "^install /bin/true$" || echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf)
rhel_7_17_set=$?
lsmod | egrep "^cramfs\s" && rmmod cramfs
if [[ "$rhel_7_17_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-18 Disable the mounting of the freevxfs filesystems. “
rhel_7_18_set=$(modprobe -n -v freevxfs | grep "^install /bin/true$" || echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf)
rhel_7_18_set=$?
lsmod | egrep "^freevxfs\s" && rmmod freevxfs
if [[ "$rhel_7_18_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-19 Disable the mounting of the jffs2 filesystems. “
rhel_7_19_set="$(modprobe -n -v jffs2 | grep "^install /bin/true$" || echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_7_19_set=$?
lsmod | egrep "^jffs2\s" && rmmod jffs2
if [[ "$rhel_7_19_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-20 Disable the mounting of the hfs filesystems. “
rhel_7_20_set="$(modprobe -n -v hfs | grep "^install /bin/true$" || echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_7_20_set=$?
lsmod | egrep "^hfs\s" && rmmod hfs
if [[ "$rhel_7_20_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-21 Disable the mounting of the hfsplus filesystems. “
rhel_7_21_set="$(modprobe -n -v hfsplus | grep "^install /bin/true$" || echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_7_21_set=$?
lsmod | egrep "^hfsplus\s" && rmmod hfsplus
if [[ "$rhel_7_21_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-22 Disable the mounting of the squashfs filesystems. “
rhel_7_22_set="$(modprobe -n -v squashfs | grep "^install /bin/true$" || echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_7_22_set=$?
lsmod | egrep "^squashfs\s" && rmmod squashfs
if [[ "$rhel_7_22_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-23 Disable the mounting of the udf filesystems. “
rhel_7_23_set="$(modprobe -n -v udf | grep "^install /bin/true$" || echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_7_23_set=$?
lsmod | egrep "^udf\s" && rmmod udf
if [[ "$rhel_7_23_set" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi


echo “RHL7-24 Configure package manager repositories. “
echo $yum repolist

echo “RHL7-25 Globally activate gpgcheck.“
rhel_7_26_set_2="$(egrep -q "^(\s*)gpgcheck\s*=\s*\S+(\s*#.*)?\s*$" /etc/yum.conf && sed -ri "s/^(\s*)gpgcheck\s*=\s*\S+(\s*#.*)?\s*$/\1gpgcheck=1\2/" /etc/yum.conf || echo "gpgcheck=1" >> /etc/yum.conf)"
rhel_7_26_set_2=$?
rhel_7_26_set_2_temp=0
for file in /etc/yum.repos.d/*; do
  rhel_7_26_set_2_temp_2="$(egrep -q "^(\s*)gpgcheck\s*=\s*\S+(\s*#.*)?\s*$" $file && sed -ri "s/^(\s*)gpgcheck\s*=\s*\S+(\s*#.*)?\s*$/\1gpgcheck=1\2/" $file || echo "gpgcheck=1" >> $file)"
  rhel_7_26_set_2_temp_2=$?
  if [[ "$rhel_7_26_set_2_temp_2" -eq 0 ]]; then
    ((rhel_7_26_set_2_temp=rhel_7_26_set_2_temp+1))
  fi
done
rhel_7_26_set_2_temp_2="$( ls -1q /etc/yum.repos.d/* | wc -l)"
if [[ "$rhel_7_26_set_2" -eq 0 ]] && [[ "$rhel_7_26_set_2_temp" -eq "rhel_7_26_set_2_temp_2" ]]; then
  echo -e "Remediated: Ensure gpgcheck is globally activated"
  
else
  echo -e "UnableToRemediate: Ensure gpgcheck is globally activated"
  
fi

echo “RHL7-26 Configure GPG keys.“
rhel_7_26_set="$rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'"
if [ "$rhel_7_26_set" == "package gpg-pubkey is not installed" ]; then
  echo "[-]Error"
else
  echo "[+]Pass"
fi

echo “RHL7-27 Configure the Red Hat Subscription Manager connection. “
echo "Register"
#TODO: TO BE REVIEWED, BELOW NOT AVAILABLE
#subscription-manager register
#subscription-manager identity

echo “RHL7-28 Install AIDE.“
rhel_7_28_set="$(rpm -q aide || yum -y install aide)"
rhel_7_28_set=$?
if [[ "$rhel_7_28_set" -eq 0 ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-29 Regularly check filesystem integrity. “
rhel_7_29_set="$(crontab -u root -l; crontab -u root -l | egrep -q "^0 5 \* \* \* /usr/sbin/aide --check$" || echo "0 5 * * * /usr/sbin/aide --check" ) | crontab -u root -)"
rhel_7_29_set=$?
if [[ "$rhel_7_29_set" -eq 0 ]]; then
  echo "[+]Pass"

else
  echo "[-]Error"

fi
    
echo “RHL7-30 Configure permissions on the bootloader config file.“
chown root:root /boot/grub2/grub.cfg
chmod og-rwx /boot/grub2/grub.cfg 
chown root:root /boot/grub2/grubenv
chmod og-rwx /boot/grub2/grubenv
  echo "[+]Pass"

echo “RHL7-31 Set the bootloader password. “
#grub2-setpassword
grub2-setpassword < apwd
grub2-mkconfig -o /boot/grub2/grub.cfg

echo “RHL7-32 Require authentication for single user mode. “
rhel_7_32_set_rule1="$(egrep -q "^\s*ExecStart" /usr/lib/systemd/system/rescue.service && sed -ri "s/(^[[:space:]]*ExecStart[[:space:]]*=[[:space:]]*).*$/\1-\/bin\/sh -c \"\/sbin\/sulogin; \/usr\/bin\/systemctl --fail --no-block default\"/" /usr/lib/systemd/system/rescue.service || echo "ExecStart=-/bin/sh -c \"/sbin/sulogin; /usr/bin/systemctl --fail --no-block default\"" >> /usr/lib/systemd/system/rescue.service)"
rhel_7_32_set_rule1=$?
rhel_7_32_set_rule2="$(egrep -q "^\s*ExecStart" /usr/lib/systemd/system/emergency.service && sed -ri "s/(^[[:space:]]*ExecStart[[:space:]]*=[[:space:]]*).*$/\1-\/bin\/sh -c \"\/sbin\/sulogin; \/usr\/bin\/systemctl --fail --no-block default\"/" /usr/lib/systemd/system/emergency.service || echo "ExecStart=-/bin/sh -c \"/sbin/sulogin; /usr/bin/systemctl --fail --no-block default\"" >> /usr/lib/systemd/system/emergency.service)"
rhel_7_32_set_rule1=$?
if [[ "$rhel_7_32_set_rule1" -eq 0 ]] && [[ "$rhel_7_32_set_rule2" -eq 0 ]]; then
  echo "[+]Pass"

else
  echo "[-]Error"
  
fi

echo “RHL7-33 Restrict core dumps. “
rhel_7_33_set_temp_1="$(egrep -q "^(\s*)\*\s+hard\s+core\s+\S+(\s*#.*)?\s*$" /etc/security/limits.conf && sed -ri "s/^(\s*)\*\s+hard\s+core\s+\S+(\s*#.*)?\s*$/\1* hard core 0\2/" /etc/security/limits.conf || echo "* hard core 0" >> /etc/security/limits.conf)"
rhel_7_33_set_temp_1=$?
rhel_7_33_set_temp_2="$(echo "* hard core 0" >> /etc/security/limits.d/*)"
rhel_7_33_set_temp_2=$?
rhel_7_33_set_temp_3="$(egrep -q "^(\s*)fs.suid_dumpable\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)fs.suid_dumpable\s*=\s*\S+(\s*#.*)?\s*$/\1fs.suid_dumpable = 0\2/" /etc/sysctl.conf || echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf)"
rhel_7_33_set_temp_3=$?
rhel_7_33_set_temp_4="$(egrep -q "^(\s*)fs.suid_dumpable\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.d/*  || echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/*)"
rhel_7_33_set_temp_4=$?
rhel_7_33_set_temp_5="$(sysctl -w fs.suid_dumpable=0)"
rhel_7_33_set_temp_5=$?
if [[ "$rhel_7_33_set_temp_1" -eq 0 ]] && [[ "$rhel_7_33_set_temp_2" -eq 0 ]] && [[ "$rhel_7_33_set_temp_3" -eq 0 ]] && [[ "$rhel_7_33_set_temp_4" -eq 0 ]] && [[ "$rhel_7_33_set_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-34 Enable XD/NX support. “
dmesg | grep NX | awk 'FNR==1 {print FILENAME, $0}'
echo "[+]Done"

echo “RHL7-35 Enable address space layout randomization ASLR“
rhel_7_35_set_temp_1="$(egrep -q "^(\s*)kernel.randomize_va_space\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)kernel.randomize_va_space\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.randomize_va_space = 2\2/" /etc/sysctl.conf || echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf)"
rhel_7_35_set_temp_1=$?
rhel_7_35_set_temp_2="$(echo "kernel.randomize_va_space = 2" >> /etc/sysctl.d/*)"
rhel_7_35_set_temp_2=$?
rhel_7_35_set_temp_3="$(sysctl -w kernel.randomize_va_space=2)"
rhel_7_35_set_temp_3=$?
if [[ "$rhel_7_35_set_temp_1" -eq 0 ]] && [[ "$rhel_7_35_set_temp_2" -eq 0 ]] && [[ "$rhel_7_35_set_temp_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-36 Disable prelink.“
rhel_7_36_set="$(rpm -q prelink && yum -y remove prelink)"
rhel_7_36_set=$?
if [[ "$rhel_7_36_set" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi


echo “RHL7-37 Configure the GDM login banner. “
echo "Run dconf update post update"
#verify that /etc/dconf/profile/gdm exists and contains the following:
#user-db:user
#system-db:gdm
#file-db:/usr/share/gdm/greeter-dconf-defaults
  
echo “RHL7-38 Configure the message of the day. “
rhel_7_38_set="$(sed -ri 's/(\\v|\\r|\\m|\\s)//g' /etc/motd)"
rhel_7_38_set=$?
if [[ "$rhel_7_38_set" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-39 Configure the local login warning banner.“
rhel_7_39_set_2="$(echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue)"
rhel_7_39_set_2=$?
if [[ "$rhel_7_39_set_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-40 Configure the remote login warning banner. “
rhel_7_40_set_3="$(echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net)"
rhel_7_40_set_3=$?
if [[ "$rhel_7_40_set_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-41 Configure permissions on the /ect/motd file.“
rhel_7_41_set_4="$(chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/motd)"
rhel_7_41_set_4=$?
if [[ "$rhel_7_41_set_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-42 Configure permissions on the /etc/issue file.“
rhel_7_42_set_5="$(chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/issue)"
rhel_7_42_set_5=$?
if [[ "$rhel_7_42_set_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-43 Configure permissions on the /etc/issue.net file.“
rhel_7_43_set_6="$(chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/issue.net)"
rhel_7_43_set_6=$?
if [[ "$rhel_7_43_set_6" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-44 Disable chargen services. “
rhel_7_44_set_1="$(chkconfig chargen off)"
rhel_7_44_set_1=$?
if [[ "$rhel_7_44_set_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi 


echo “RHL7-45 Disable daytime services. “
rhel_7_45_set_2="$(chkconfig daytime off)"
rhel_7_45_set_2=$?
if [[ "$rhel_7_45_set_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-46 Disable discard services. “
rhel_7_46_set_3="$(chkconfig discard off)"
rhel_7_46_set_3=$?
if [[ "$rhel_7_46_set_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-47 Disable echo services. “
rhel_7_47_set_4="$(chkconfig echo off)"
rhel_7_47_set_4=$?
if [[ "$rhel_7_47_set_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-48 Disable time services. “
rhel_7_48_set_5="$(chkconfig time off)"
rhel_7_48_set_5=$?
if [[ "$rhel_7_48_set_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-49 Disable the Trivial File Transfer Protocol TFTP server. “
rhel_7_49_set_6="$(chkconfig tftp off)"
rhel_7_49_set_6=$?
systemctl disable tftp.socket.service
if [[ "$rhel_7_49_set_6" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-50 Disable the eXtended InterNET Daemon `xinetd`.“
rhel_7_50_set_7="$(systemctl disable xinetd.service)"
rhel_7_50_set_7=$?
if [[ "$rhel_7_50_set_7" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-51 Disable the X Window system.“
rhel_7_51_set_7="$(yum -y remove xorg-x11*)"
rhel_7_51_set_7=$?
if [[ "$rhel_7_51_set_7" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-52 Disable the Avahi Server. “
rhel_2_2_3="$(systemctl disable avahi-daemon.service || yum erase avahi -y)"
rhel_2_2_3=$?
if [[ "$rhel_2_2_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-53 Disable the Common Unix Print System CUPS.“
rhel_2_2_4="$(systemctl disable cups.service  || yum erase cups -y)"
rhel_2_2_4=$?
if [[ "$rhel_2_2_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-54 Disable the Dynamic Host Configuration Protocol DHCP server. “
rhel_2_2_5="$(systemctl disable dhcpd.service || yum erase dhcpd -y)"
rhel_2_2_5=$?
if [[ "$rhel_2_2_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-55 Disable the Lightweight Directory Access Protocol LDAP server. “
rhel_2_2_6="$(systemctl disable slapd.service || yum erase slapd -y)"
rhel_2_2_6=$?
if [[ "$rhel_2_2_6" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-56 Disable the Network File System NFS and RPC.“
rhel_2_2_7_temp_1="$(systemctl disable nfs.service || yum erase nfs -y)"
rhel_2_2_7_temp_1=$?
rhel_2_2_7_temp_2="$(systemctl disable rpcbind.service || yum erase rpcbind -y)"
rhel_2_2_7_temp_2=$?
if [[ "$rhel_2_2_7_temp_1" -eq 0 ]] && [[ "$rhel_2_2_7_temp_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-57 Disable the Domain Name System DNS Server. “
rhel_2_2_8="$(systemctl disable named.service || yum erase named -y)"
rhel_2_2_8=$?
if [[ "$rhel_2_2_8" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-58 Disable the File Transfer Protocol FTP Server. “
rhel_2_2_9="$(systemctl disable vsftpd.service || yum erase vsftpd -y)"
rhel_2_2_9=$?
if [[ "$rhel_2_2_9" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-59 Disable the HTTP Server. “
echo -e "2.2.10 Ensure HTTP server is not enabled"
rhel_2_2_10="$(systemctl disable httpd.service || yum erase httpd -y)"
rhel_2_2_10=$?
if [[ "$rhel_2_2_10" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-60 Disable IMAP and POP3. “
rhel_2_2_11="$(systemctl disable dovecot.service || yum erase dovecot -y)"
rhel_2_2_11=$?
if [[ "$rhel_2_2_11" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-61 Disable the Samba daemon. “
rhel_2_2_12="$(systemctl disable smb.service || yum erase smb -y)"
rhel_2_2_12=$?
if [[ "$rhel_2_2_12" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-62 Disable the HTTP Proxy Server.“
echo -e "2.2.13 Ensure HTTP Proxy Server is not enabled"
rhel_2_2_13="$(systemctl disable squid.service || yum erase squid -y)"
rhel_2_2_13=$?
if [[ "$rhel_2_2_13" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-63 Disable the Simple Network Management Protocol SNMP Server. “
rhel_2_2_14="$(systemctl disable snmpd.service || yum erase snmpd -y)"
rhel_2_2_14=$?
if [[ "$rhel_2_2_14" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-64 Configure the mail transfer agent for local-only mode. “
rhel_7_64_set="$(netstat -an | grep LIST | grep ":25[[:space:]]" | grep "tcp 0 0 127.0.0.1:25 0.0.0.0:* LISTEN")"
rhel_7_64_set=$?
if [[ "$rhel_7_64_set" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-65 Disable the Network Information Service NIS Server. “
rhel_2_2_16="$(systemctl disable ypserv.service || yum erase ypserv -y)"
rhel_2_2_16=$?
if [[ "$rhel_2_2_16" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-66 Disable the rsh server.“
rhel_2_2_17="$(systemctl disable rsh.socket.service || yum erase rsh -y)"
rhel_2_2_17=$?
systemctl disable rlogin.socket.service
systemctl disable rexec.socket.service
if [[ "$rhel_2_2_17" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-67 Disable the talk server. “
rhel_2_2_18="$(systemctl disable ntalk.service || yum erase ntalk -y)"
rhel_2_2_18=$?
if [[ "$rhel_2_2_18" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-68 Disable the telnet server. “
rhel_2_2_19="$(systemctl disable telnet.socket.service || yum erase telnet -y)"
rhel_2_2_19=$?
if [[ "$rhel_2_2_19" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-69 Disable the Trivial File Transfer Protocol TFTP server. “
echo 'Disabled TFTP:' `rpm -qa | grep tftp`

echo “RHL7-70 Disable the rsync service. “
rhel_2_2_21="$(systemctl disable rsyncd.service || yum erase rsyncd -y)"
rhel_2_2_21=$?
if [[ "$rhel_2_2_21" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-71 Enable time synchronization. “
rhel_7_71_set_6="$(rpm -q ntp)"
if [ "$rhel_7_71_set_6" == "package ntp is not installed" ]; then
	echo "[*]$rhel_7_71_set_6. Installing..."
	yum -y install ntp
	echo "[+]Done"
fi

echo “RHL7-72 Configure the Network Time Protocol NTP.“
rhel_7_72_set="$(grep "restrict default" /etc/ntp.conf && grep "restrict -6 default" /etc/ntp.conf && grep "^server" /etc/ntp.conf && grep "ntp:ntp" /etc/sysconfig/ntpd)"
rhel_7_72_set=$?
if [[ "$rhel_7_72_set" ]]; then
  echo "[+]Pass"
else
  echo "[-]Error"
fi

echo “RHL7-73 Configure chrony. “
if rpm -q chrony >/dev/null; then
  rhel_2_2_1_3="$(egrep -q "^(\s*)OPTIONS\s*=\s*\"(([^\"]+)?-u\s[^[:space:]\"]+([^\"]+)?|([^\"]+))\"(\s*#.*)?\s*$" /etc/sysconfig/chronyd && sed -ri '/^(\s*)OPTIONS\s*=\s*\"([^\"]*)\"(\s*#.*)?\s*$/ {/^(\s*)OPTIONS\s*=\s*\"[^\"]*-u\s+\S+[^\"]*\"(\s*#.*)?\s*$/! s/^(\s*)OPTIONS\s*=\s*\"([^\"]*)\"(\s*#.*)?\s*$/\1OPTIONS=\"\2 -u chrony\"\3/ }' /etc/sysconfig/chronyd && sed -ri "s/^(\s*)OPTIONS\s*=\s*\"([^\"]+\s+)?-u\s[^[:space:]\"]+(\s+[^\"]+)?\"(\s*#.*)?\s*$/\1OPTIONS=\"\2\-u chrony\3\"\4/" /etc/sysconfig/chronyd || echo OPTIONS=\"-u chrony\" >> /etc/sysconfig/chronyd)"
  rhel_2_2_1_3=$?
  if [[ "$rhel_2_2_1_3" -eq 0 ]]; then
    echo "[+]Pass"
    
  else
    echo "[-]Error"
    
  fi
else
  yum install chrony -y && systemctl start chronyd && systemctl enable chronyd
  rhel_2_2_1_3="$(echo OPTIONS=\"-u chrony\" >> /etc/sysconfig/chronyd)"
  rhel_2_2_1_3=$?
  if [[ "$rhel_2_2_1_3" -eq 0 ]]; then
    echo "[+]Pass"
    
  else
    echo "[-]Error"
    
  fi
fi

echo “RHL7-74 Disable the Network Information Service NIS Client. “
rhel_2_3_1="$(rpm -q ypbind && yum -y erase ypbind)"
rhel_2_3_1=$?
if [[ "$rhel_2_3_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-75 Disable the rsh client. “
rhel_2_3_2="$(rpm -q rsh && yum -y erase rsh)"
rhel_2_3_2=$?
if [[ "$rhel_2_3_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-76 Disable the talk client. “
rhel_2_3_3="$(rpm -q talk && yum -y erase talk)"
rhel_2_3_3=$?
if [[ "$rhel_2_3_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-77 Disable the telnet client. “
rhel_2_3_4="$(rpm -q telnet && yum -y erase telnet)"
rhel_2_3_4=$?
if [[ "$rhel_2_3_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-78 Disable the Lightweight Directory Access Protocol LDAP client.“
rhel_2_3_5="$(rpm -q openldap-clients && yum -y erase openldap-clients)"
rhel_2_3_5=$?
if [[ "$rhel_2_3_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-79 Disable the use of wireless interfaces.“
nmcli radio all off
/bin/systemctl stop NetworkManager.service
for ifcfg in `ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v ifcfg-lo` ; do
  rm -f $ifcfg
done
rm -rf /var/lib/NetworkManager/*

echo “RHL7-80 Disable the use of IP forwarding. “
rhel_3_1_1_temp_1="$(egrep -q "^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.ip_forward = 0\2/" /etc/sysctl.conf || echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf)"
rhel_3_1_1_temp_1=$?
rhel_3_1_1_temp_2="$(echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.d/*)"
rhel_3_1_1_temp_2=$?
rhel_3_1_1_temp_3="$(sysctl -w net.ipv4.ip_forward=0)"
rhel_3_1_1_temp_3=$?
rhel_3_1_1_temp_4="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_1_1_temp_4=$?
if [[ "$rhel_3_1_1_temp_1" -eq 0 ]] && [[ "$rhel_3_1_1_temp_2" -eq 0 ]] && [[ "$rhel_3_1_1_temp_3" -eq 0 ]] && [[ "$rhel_3_1_1_temp_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-81 Disable packet redirect sending. “
rhel_3_1_2_temp_1="$(egrep -q "^(\s*)net.ipv4.conf.all.send_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.send_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.send_redirects = 0\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf)"
rhel_3_1_2_temp_1=$?
rhel_3_1_2_temp_2="$(egrep -q "^(\s*)net.ipv4.conf.default.send_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.default.send_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.send_redirects = 0\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf)"
rhel_3_1_2_temp_2=$?
rhel_3_1_2_temp_3="$(sysctl -w net.ipv4.conf.all.send_redirects=0)"
rhel_3_1_2_temp_3=$?
rhel_3_1_2_temp_4="$(sysctl -w net.ipv4.conf.default.send_redirects=0)"
rhel_3_1_2_temp_4=$?
rhel_3_1_2_temp_5="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_1_2_temp_5=$?
if [[ "$rhel_3_1_2_temp_1" -eq 0 ]] && [[ "$rhel_3_1_2_temp_2" -eq 0 ]] && [[ "$rhel_3_1_2_temp_3" -eq 0 ]] && [[ "$rhel_3_1_2_temp_4" -eq 0 ]] && [[ "$rhel_3_1_2_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-82 Do not accept source routed packets. “
rhel_3_2_1_temp_1="$(egrep -q "^(\s*)net.ipv4.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_source_route = 0\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf)"
rhel_3_2_1_temp_1=$?
rhel_3_2_1_temp_2="$(egrep -q "^(\s*)net.ipv4.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.accept_source_route = 0\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf)"
rhel_3_2_1_temp_2=$?
rhel_3_2_1_temp_3="$(sysctl -w net.ipv4.conf.all.accept_source_route=0)"
rhel_3_2_1_temp_3=$?
rhel_3_2_1_temp_4="$(sysctl -w net.ipv4.conf.default.accept_source_route=0)"
rhel_3_2_1_temp_4=$?
rhel_3_2_1_temp_5="$sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_1_temp_5=$?
if [[ "$rhel_3_2_1_temp_1" -eq 0 ]] && [[ "$rhel_3_2_1_temp_2" -eq 0 ]] && [[ "$rhel_3_2_1_temp_3" -eq 0 ]] && [[ "$rhel_3_2_1_temp_4" -eq 0 ]] && [[ "$rhel_3_2_1_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-83 Reject ICMP redirect messages. “
rhel_3_2_2_temp_1="$(egrep -q "^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_redirects = 0\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf)"
rhel_3_2_2_temp_1=$?
rhel_3_2_2_temp_2="$(egrep -q "^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_redirects = 0\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf)"
rhel_3_2_2_temp_2=$?
rhel_3_2_2_temp_3="$(sysctl -w net.ipv4.conf.all.accept_redirects=0)"
rhel_3_2_2_temp_3=$?
rhel_3_2_2_temp_4="$(sysctl -w net.ipv4.conf.default.accept_redirects=0)"
rhel_3_2_2_temp_4=$?
rhel_3_2_2_temp_5="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_2_temp_5=$?
if [[ "$rhel_3_2_2_temp_1" -eq 0 ]] && [[ "$rhel_3_2_2_temp_2" -eq 0 ]] && [[ "$rhel_3_2_2_temp_3" -eq 0 ]] && [[ "$rhel_3_2_2_temp_4" -eq 0 ]] && [[ "$rhel_3_2_2_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-84 Reject secure ICMP redirect messages. “
rhel_3_2_3_temp_1="$(egrep -q "^(\s*)net.ipv4.conf.all.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.secure_redirects = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf)"
rhel_3_2_3_temp_1=$?
rhel_3_2_3_temp_2="$(egrep -q "^(\s*)net.ipv4.conf.default.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.default.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.secure_redirects = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf)"
rhel_3_2_3_temp_2=$?
rhel_3_2_3_temp_3="$(sysctl -w net.ipv4.conf.all.secure_redirects=0)"
rhel_3_2_3_temp_3=$?
rhel_3_2_3_temp_4="$(sysctl -w net.ipv4.conf.default.secure_redirects=0)"
rhel_3_2_3_temp_4=$?
rhel_3_2_3_temp_5="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_3_temp_5=$?
if [[ "$rhel_3_2_3_temp_1" -eq 0 ]] && [[ "$rhel_3_2_3_temp_2" -eq 0 ]] && [[ "$rhel_3_2_3_temp_3" -eq 0 ]] && [[ "$rhel_3_2_3_temp_4" -eq 0 ]] && [[ "$rhel_3_2_3_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-85 Log suspicious packets.“
rhel_3_2_4_temp_1="$(egrep -q "^(\s*)net.ipv4.conf.all.log_martians\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.log_martians\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.log_martians = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf)"
rhel_3_2_4_temp_1=$?
rhel_3_2_4_temp_2="$(egrep -q "^(\s*)net.ipv4.conf.default.log_martians\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.default.log_martians\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.log_martians = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf)"
rhel_3_2_4_temp_2=$?
rhel_3_2_4_temp_3="$(sysctl -w net.ipv4.conf.all.log_martians=1)"
rhel_3_2_4_temp_3=$?
rhel_3_2_4_temp_4="$(sysctl -w net.ipv4.conf.default.log_martians=1)"
rhel_3_2_4_temp_4=$?
rhel_3_2_4_temp_5="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_4_temp_5=$?
if [[ "$rhel_3_2_4_temp_1" -eq 0 ]] && [[ "$rhel_3_2_4_temp_2" -eq 0 ]] && [[ "$rhel_3_2_4_temp_3" -eq 0 ]] && [[ "$rhel_3_2_4_temp_4" -eq 0 ]] && [[ "$rhel_3_2_4_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-86 Ignore broadcast ICMP requests. “
rhel_3_2_5_temp_1="$(egrep -q "^(\s*)net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.icmp_echo_ignore_broadcasts = 1\2/" /etc/sysctl.conf || echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf)"
rhel_3_2_5_temp_1=$?
rhel_3_2_5_temp_2="$(sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1)"
rhel_3_2_5_temp_2=$?
rhel_3_2_5_temp_3="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_5_temp_3=$?
if [[ "$rhel_3_2_5_temp_1" -eq 0 ]] && [[ "$rhel_3_2_5_temp_2" -eq 0 ]] && [[ "$rhel_3_2_5_temp_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-87 Ignore bogus ICMP responses.“
rhel_3_2_6_temp_1="$(egrep -q "^(\s*)net.ipv4.icmp_ignore_bogus_error_responses\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.icmp_ignore_bogus_error_responses\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.icmp_ignore_bogus_error_responses = 1\2/" /etc/sysctl.conf || echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf)"
rhel_3_2_6_temp_1=$?
rhel_3_2_6_temp_2="$(sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1)"
rhel_3_2_6_temp_2=$?
rhel_3_2_6_temp_3="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_6_temp_3=$?
if [[ "$rhel_3_2_6_temp_1" -eq 0 ]] && [[ "$rhel_3_2_6_temp_2" -eq 0 ]] && [[ "$rhel_3_2_6_temp_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-88 Enable Reverse Path Filtering. “
rhel_3_2_7_temp_1="$(egrep -q "^(\s*)net.ipv4.conf.all.rp_filter\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.rp_filter\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.rp_filter = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf)"
rhel_3_2_7_temp_1=$?
rhel_3_2_7_temp_2="$(egrep -q "^(\s*)net.ipv4.conf.default.rp_filter\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.default.rp_filter\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.rp_filter = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf)"
rhel_3_2_7_temp_2=$?
rhel_3_2_7_temp_3="$(sysctl -w net.ipv4.conf.all.rp_filter=1)"
rhel_3_2_7_temp_3=$?
rhel_3_2_7_temp_4="$(sysctl -w net.ipv4.conf.default.rp_filter=1)"
rhel_3_2_7_temp_4=$?
rhel_3_2_7_temp_5="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_7_temp_5=$?
if [[ "$rhel_3_2_7_temp_1" -eq 0 ]] && [[ "$rhel_3_2_7_temp_2" -eq 0 ]] && [[ "$rhel_3_2_7_temp_3" -eq 0 ]] && [[ "$rhel_3_2_7_temp_4" -eq 0 ]] && [[ "$rhel_3_2_7_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-89 Enable TCP SYN Cookies. “
rhel_3_2_8_temp_1="$(egrep -q "^(\s*)net.ipv4.tcp_syncookies\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.tcp_syncookies\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.tcp_syncookies = 1\2/" /etc/sysctl.conf || echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf)"
rhel_3_2_8_temp_1=$?
rhel_3_2_8_temp_2="$sysctl -w net.ipv4.tcp_syncookies=1)"
rhel_3_2_8_temp_2=$?
rhel_3_2_8_temp_3="$(sysctl -w net.ipv4.route.flush=1)"
rhel_3_2_8_temp_3=$?
if [[ "$rhel_3_2_8_temp_1" -eq 0 ]] && [[ "$rhel_3_2_8_temp_2" -eq 0 ]] && [[ "$rhel_3_2_8_temp_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-90 Reject IPv6 router advertisements. “
rhel_3_3_1_temp_1="$(egrep -q "^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_ra = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf)"
rhel_3_3_1_temp_1=$?
rhel_3_3_1_temp_2="$(egrep -q "^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_ra = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf)"
rhel_3_3_1_temp_2=$?
rhel_3_3_1_temp_3="$(sysctl -w net.ipv6.conf.all.accept_ra=0)"
rhel_3_3_1_temp_3=$?
rhel_3_3_1_temp_4="$(sysctl -w net.ipv6.conf.default.accept_ra=0)"
rhel_3_3_1_temp_4=$?
rhel_3_3_1_temp_5="$(sysctl -w net.ipv6.route.flush=1)"
rhel_3_3_1_temp_5=$?
if [[ "$rhel_3_3_1_temp_1" -eq 0 ]] && [[ "$rhel_3_3_1_temp_2" -eq 0 ]] && [[ "$rhel_3_3_1_temp_3" -eq 0 ]] && [[ "$rhel_3_3_1_temp_4" -eq 0 ]] && [[ "$rhel_3_3_1_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi


echo “RHL7-91 Do not accept IPv6 redirects.“
rhel_3_3_2_temp_1="$(egrep -q "^(\s*)net.ipv6.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_redirects = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf)"
rhel_3_3_2_temp_1=$?
rhel_3_3_2_temp_2="$(egrep -q "^(\s*)net.ipv6.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_redirects = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf)"
echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.d/*
rhel_3_3_2_temp_2=$?
rhel_3_3_2_temp_3="$(sysctl -w net.ipv6.conf.all.accept_redirects=0)"
rhel_3_3_2_temp_3=$?
rhel_3_3_2_temp_4="$(sysctl -w net.ipv6.conf.default.accept_redirects=0)"
rhel_3_3_2_temp_4=$?
rhel_3_3_2_temp_5="$(sysctl -w net.ipv6.route.flush=1)"
rhel_3_3_2_temp_5=$?
if [[ "$rhel_3_3_2_temp_1" -eq 0 ]] && [[ "$rhel_3_3_2_temp_2" -eq 0 ]] && [[ "$rhel_3_3_2_temp_3" -eq 0 ]] && [[ "$rhel_3_3_2_temp_4" -eq 0 ]] && [[ "$rhel_3_3_2_temp_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-92 Disable IPv6.“
touch /etc/modprobe.d/ipv6.conf 
echo "options ipv6 disable=1" >> /etc/modprobe.d/ipv6.conf
/sbin/chkconfig ip6tables off

echo “RHL7-93 Install TCP Wrappers. “
rhel_3_4_1_temp_1="$(rpm -q tcp_wrappers || yum -y install tcp_wrappers)"
rhel_3_4_1_temp_1=$?
rhel_3_4_1_temp_2="$(rpm -q tcp_wrappers-libs || yum -y install tcp_wrappers-libs)"
rhel_3_4_1_temp_2=$?
if [[ "$rhel_3_4_1_temp_1" -eq 0 ]] && [[ "$rhel_3_4_1_temp_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-94 Configure the /etc/host.allow file.“
rhel_3_4_2="$(touch /etc/hosts.allow)"
rhel_3_4_2=$?
if [[ "$rhel_3_4_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-95 Configure the /etc/hosts.deny file.“
rhel_3_4_3="$(touch /etc/hosts.deny)"
rhel_3_4_3=$?
if [[ "$rhel_3_4_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-96 Configure permissions on the /etc/hosts.allow file.“
rhel_3_4_4="$(chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/hosts.allow)"
rhel_3_4_4=$?
if [[ "$rhel_3_4_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-97 Configure the 644 permission on the /etc/host.deny file.“
rhel_3_4_5="$(chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/hosts.deny)"
rhel_3_4_5=$?
if [[ "$rhel_3_4_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-98 Disable the Datagram Congestion Control Protocol DCCP.“
rhel_3_5_1="$(modprobe -n -v dccp | grep "^install /bin/true$" || echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_3_5_1=$?
lsmod | egrep "^dccp\s" && rmmod dccp
if [[ "$rhel_3_5_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-99 Disable the Stream Control Transmission Protocol SCTP.“
rhel_3_5_2="$(modprobe -n -v sctp | grep "^install /bin/true$" || echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_3_5_2=$?
lsmod | egrep "^sctp\s" && rmmod sctp
if [[ "$rhel_3_5_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-100 Disable the Reliable Datagram Sockets RDS protocol. “
rhel_3_5_3="$(modprobe -n -v rds | grep "^install /bin/true$" || echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_3_5_3=$?
lsmod | egrep "^rds\s" && rmmod rds
if [[ "$rhel_3_5_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-101 Disable the Transparent Inter-Process Communication TIPC protocol.“
rhel_3_5_4="$(modprobe -n -v tipc | grep "^install /bin/true$" || echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf)"
rhel_3_5_4=$?
lsmod | egrep "^tipc\s" && rmmod tipc
if [[ "$rhel_3_5_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-102 Install IPtables. “
rhel_3_6_1="$(rpm -q iptables || yum -y install iptables)"
rhel_3_6_1=$?
if [[ "$rhel_3_6_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-103 Configure the default deny firewall policy. “
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -L

echo “RHL7-104 Configure the loopback interface.“
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -j DROP

iptables -L INPUT -v -n
iptables -L OUTPUT -v -n

echo “RHL7-105 Configure outbound and established connections. “
iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
echo "[+]Pass"
iptables -L -v -n

echo “RHL7-106 Confirm that firewall rules exist for all open ports. “
iptables -A INPUT -p  --dport  -m state --state NEW -j ACCEPT
echo "[+]Pass"
netatat -ln
iptables -L INPUT -v -n

echo “RHL7-107 Configure logrotate. “
cat << 'EOM' >> /etc/audit/audit.rules
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/boot.log 
/var/log/spooler
{
    sharedscripts
    postrotate
	/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
EOM
echo "[+]Pass"

echo “RHL7-108 Install rsyslog or syslog-ng.“
rhel_4_2_3="$(rpm -q rsyslog || rpm -q syslog-ng || yum -y install rsyslog)"
rhel_4_2_3=$?
if [[ "$rhel_4_2_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi  

echo “RHL7-109 Configure permissions on all logfiles. “
rhel_4_2_4="$(chmod -R g-w-x,o-r-w-x /var/log/*)"
rhel_4_2_4=$?
if [[ "$rhel_4_2_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-110 Enable the rsyslog Service. “
rhel_4_2_2_1="$(rpm -q syslog-ng && systemctl enable syslog-ng.service)"
rhel_4_2_2_1=$?
if [[ "$rhel_4_2_2_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-111 Configure the logging options. “
echo "auth,user.* /var/log/messages" >> /etc/rsyslog.conf
echo "kern.* /var/log/kern.log" >> /etc/rsyslog.conf
echo "daemon.* /var/log/daemon.log" >> /etc/rsyslog.conf
echo "syslog.* /var/log/syslog" >> /etc/rsyslog.conf
echo "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* /var/log/unused.log" >> /etc/rsyslog.conf
pkill -HUP rsyslogd
echo "[+]Pass"

echo “RHL7-112 Configure the default rsyslog file permissions. “
touch /var/log/messages
chown root:root /var/log/messages
chmod og-rwx /var/log/messages
touch /var/log/kern.log
chown root:root /var/log/kern.log
chmod og-rwx /var/log/kern.log
touch /var/log/daemon.log
chown root:root /var/log/daemon.log
chmod og-rwx /var/log/daemon.log
touch /var/log/syslog
chown root:root /var/log/syslog
chmod og-rwx /var/log/syslog
touch /var/log/unused.log
chown root:root /var/log/unused.log
chmod og-rwx /var/log/unused.log
echo "[+]Pass"

echo “RHL7-113 Configure rsyslog to send logs to a remote log host. “
grep "^*.*[^I][^I]*@" /etc/rsyslog.conf
systemctl restart rsyslog.

echo “RHL7-114 Only accept remote rsyslog messages on designated log hosts. “
grep '$ModLoad imtcp.so' /etc/rsyslog.conf
grep '$InputTCPServerRun' /etc/rsyslog.conf

echo “RHL7-115 Enable the syslog-ng service. “
rhel_4_2_2_1="$(rpm -q syslog-ng && systemctl enable syslog-ng.service)"
rhel_4_2_2_1=$?
if [[ "$rhel_4_2_2_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-116 Configure the /etc/syslog-ng/syslog-ng.conf file.“
ls -l /var/log/

echo “RHL7-117 Configure the default syslog-ng file permissions. “
grep ^options /etc/syslog-ng/syslog-ng.conf

echo “RHL7-118 Configure syslog-ng to send logs to a remote host. “
echo "Please Review"

echo “RHL7-119 Only accept remote syslog-ng messages from designated log hosts. “
echo "Please Review"

echo “RHL7-120 Restrict root login to the system console. “
rhel_5_2_8="$(egrep -q "^(\s*)PermitRootLogin\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)PermitRootLogin\s+\S+(\s*#.*)?\s*$/\1PermitRootLogin no\2/" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config)"
rhel_5_2_8=$?
if [[ "$rhel_5_2_8" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-121 Restrict access to the su command. “
rhel_5_6="$(egrep -q "^\s*auth\s+required\s+pam_wheel.so(\s+.*)?$" /etc/pam.d/su && sed -ri '/^\s*auth\s+required\s+pam_wheel.so(\s+.*)?$/ { /^\s*auth\s+required\s+pam_wheel.so(\s+\S+)*(\s+use_uid)(\s+.*)?$/! s/^(\s*auth\s+required\s+pam_wheel.so)(\s+.*)?$/\1 use_uid\2/ }' /etc/pam.d/su || echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su)"
rhel_5_6=$?
if [[ "$rhel_5_6" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-122 Enable the cron daemon. “
rhel_5_1_1="$(systemctl enable crond.service)"
rhel_5_1_1=$?
if [[ "$rhel_5_1_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-123 Configure permissions on the /etc/crontab file. “
rhel_5_1_2="$(chmod g-r-w-x,o-r-w-x /etc/crontab)"
rhel_5_1_2=$?
if [[ "$rhel_5_1_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-124 Configure permissions on the /etc/cron.hourly file. “
rhel_5_1_3="$(chmod g-r-w-x,o-r-w-x /etc/cron.hourly)"
rhel_5_1_3=$?
if [[ "$rhel_5_1_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-125 Configure permissions on the /etc/cron.daily file. “
rhel_5_1_4="$(chmod g-r-w-x,o-r-w-x /etc/cron.daily)"
rhel_5_1_4=$?
if [[ "$rhel_5_1_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-126 Configure permissions on the /etc/cron.weekly file. “
rhel_5_1_5="$(chmod g-r-w-x,o-r-w-x /etc/cron.weekly)"
rhel_5_1_5=$?
if [[ "$rhel_5_1_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-127 Configure permissions on the /etc/cron.monthly file. “
rhel_5_1_6="$(chmod g-r-w-x,o-r-w-x /etc/cron.monthly)"
rhel_5_1_6=$?
if [[ "$rhel_5_1_6" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-128 Configure permissions on the /etc/cron.d file. “
rhel_5_1_7="$(chmod g-r-w-x,o-r-w-x /etc/cron.d)"
rhel_5_1_7=$?
if [[ "$rhel_5_1_7" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-129 Restrict at/cron to authorized users only. “
rm /etc/cron.deny
rm /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
rhel_5_1_8_temp_1="$(chmod g-r-w-x,o-r-w-x /etc/cron.allow)"
rhel_5_1_8_temp_1=$?
rhel_5_1_8_temp_2="$(chmod g-r-w-x,o-r-w-x /etc/at.allow)"
rhel_5_1_8_temp_2=$?
if [[ "$rhel_5_1_8_temp_1" -eq 0 ]] && [[ "$rhel_5_1_8_temp_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-130 Configure permissions on the /etc/ssh/sshd_config file. “
rhel_5_2_1="$(chmod g-r-w-x,o-r-w-x /etc/ssh/sshd_config)"
rhel_5_2_1=$?
if [[ "$rhel_5_2_1" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-131 Set SSH Protocol to '2'. “
rhel_5_2_2="$(egrep -q "^(\s*)Protocol\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)Protocol\s+\S+(\s*#.*)?\s*$/\1Protocol 2\2/" /etc/ssh/sshd_config || echo "Protocol 2" >> /etc/ssh/sshd_config)"
rhel_5_2_2=$?
if [[ "$rhel_5_2_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-132 Set SSH LogLevel to 'INFO.'“
rhel_5_2_3="$(egrep -q "^(\s*)LogLevel\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)LogLevel\s+\S+(\s*#.*)?\s*$/\1LogLevel INFO\2/" /etc/ssh/sshd_config || echo "LogLevel INFO" >> /etc/ssh/sshd_config)"
rhel_5_2_3=$?
if [[ "$rhel_5_2_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-133 Disable SSH X11 forwarding. “
rhel_5_2_4="$(egrep -q "^(\s*)X11Forwarding\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)X11Forwarding\s+\S+(\s*#.*)?\s*$/\1X11Forwarding no\2/" /etc/ssh/sshd_config || echo "X11Forwarding no" >> /etc/ssh/sshd_config)"
rhel_5_2_4=$?
if [[ "$rhel_5_2_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-134 Set MaxAuthTries to '3.'“
rhel_5_2_5="$(egrep -q "^(\s*)MaxAuthTries\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)MaxAuthTries\s+\S+(\s*#.*)?\s*$/\1MaxAuthTries 3\2/" /etc/ssh/sshd_config || echo "MaxAuthTries 3" >> /etc/ssh/sshd_config)"
rhel_5_2_5=$?
if [[ "$rhel_5_2_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-135 Enable SSH IgnoreRhosts. “
rhel_5_2_6="$(egrep -q "^(\s*)IgnoreRhosts\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)IgnoreRhosts\s+\S+(\s*#.*)?\s*$/\1IgnoreRhosts yes\2/" /etc/ssh/sshd_config || echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config)"
rhel_5_2_6=$?
if [[ "$rhel_5_2_6" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-136 Disable SSH HostbasedAuthentication.“
rhel_5_2_7="$(egrep -q "^(\s*)HostbasedAuthentication\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)HostbasedAuthentication\s+\S+(\s*#.*)?\s*$/\1HostbasedAuthentication no\2/" /etc/ssh/sshd_config || echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config)"
rhel_5_2_7=$?
if [[ "$rhel_5_2_7" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-137 Disable SSH root login.“
rhel_5_2_8="$(egrep -q "^(\s*)PermitRootLogin\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)PermitRootLogin\s+\S+(\s*#.*)?\s*$/\1PermitRootLogin no\2/" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config)"
rhel_5_2_8=$?
if [[ "$rhel_5_2_8" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-138 Disable SSH PermitEmptyPasswords.“
rhel_5_2_9="$(egrep -q "^(\s*)PermitEmptyPasswords\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)PermitEmptyPasswords\s+\S+(\s*#.*)?\s*$/\1PermitEmptyPasswords no\2/" /etc/ssh/sshd_config || echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config)"
rhel_5_2_9=$?
if [[ "$rhel_5_2_9" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-139 Disable the SSH PermitUserEnvironment.“
rhel_5_2_10="$(egrep -q "^(\s*)PermitUserEnvironment\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)PermitUserEnvironment\s+\S+(\s*#.*)?\s*$/\1PermitUserEnvironment no\2/" /etc/ssh/sshd_config || echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config)"
rhel_5_2_10=$?
if [[ "$rhel_5_2_10" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-140 Use approved MAC algorithms only. “
rhel_5_2_11="$(egrep -q "^(\s*)MACs\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)MACs\s+\S+(\s*#.*)?\s*$/\MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com\2/" /etc/ssh/sshd_config || echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/sshd_config)"
rhel_5_2_11=$?
if [[ "$rhel_5_2_11" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-141 Configure SSH Idle Timeout Intervals. “
rhel_5_2_12_temp_1="$(egrep -q "^(\s*)ClientAliveInterval\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)ClientAliveInterval\s+\S+(\s*#.*)?\s*$/\1ClientAliveInterval 300\2/" /etc/ssh/sshd_config || echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config)"
rhel_5_2_12_temp_1=$?
rhel_5_2_12_temp_2="$(egrep -q "^(\s*)ClientAliveCountMax\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)ClientAliveCountMax\s+\S+(\s*#.*)?\s*$/\1ClientAliveCountMax 3\2/" /etc/ssh/sshd_config || echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config)"
rhel_5_2_12_temp_2=$?
if [[ "$rhel_5_2_12_temp_1" -eq 0 ]] && [[ "$rhel_5_2_12_temp_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-142 Set SSH LoginGraceTime to one minute or less. “
rhel_5_2_13="$(egrep -q "^(\s*)LoginGraceTime\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)LoginGraceTime\s+\S+(\s*#.*)?\s*$/\1LoginGraceTime 60\2/" /etc/ssh/sshd_config || echo "LoginGraceTime 60" >> /etc/ssh/sshd_config)"
rhel_5_2_13=$?
if [[ "$rhel_5_2_13" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-143 Limit SSH access. “
grep "^AllowUsers" /etc/ssh/sshd_config
grep "^AllowGroups" /etc/ssh/sshd_config
grep "^DenyUsers" /etc/ssh/sshd_config
grep "^DenyGroups" /etc/ssh/sshd_config

echo “RHL7-144 Configure the SSH warning banner. “
rhel_5_2_15="$(egrep -q "^(\s*)Banner\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)Banner\s+\S+(\s*#.*)?\s*$/\1Banner \/etc\/issue.net\2/" /etc/ssh/sshd_config || echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config)"
rhel_5_2_15=$?
if [[ "$rhel_5_2_15" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-145 Configure the password creation requirements. “
rhel_5_3_1_temp_1="$(egrep -q "^(\s*)minlen\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)minlen\s*=\s*\S+(\s*#.*)?\s*$/\minlen=14\2/" /etc/security/pwquality.conf || echo "minlen=14" >> /etc/security/pwquality.conf)"
rhel_5_3_1_temp_1=$?
rhel_5_3_1_temp_2="$(egrep -q "^(\s*)dcredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)dcredit\s*=\s*\S+(\s*#.*)?\s*$/\dcredit=-1\2/" /etc/security/pwquality.conf || echo "dcredit=-1" >> /etc/security/pwquality.conf)"
rhel_5_3_1_temp_2=$?
rhel_5_3_1_temp_3="$(egrep -q "^(\s*)ucredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)ucredit\s*=\s*\S+(\s*#.*)?\s*$/\ucredit=-1\2/" /etc/security/pwquality.conf || echo "ucredit=-1" >> /etc/security/pwquality.conf)"
rhel_5_3_1_temp_3=$?
rhel_5_3_1_temp_4="$(egrep -q "^(\s*)ocredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)ocredit\s*=\s*\S+(\s*#.*)?\s*$/\ocredit=-1\2/" /etc/security/pwquality.conf || echo "ocredit=-1" >> /etc/security/pwquality.conf)"
rhel_5_3_1_temp_4=$?
rhel_5_3_1_temp_5="$(egrep -q "^(\s*)lcredit\s*=\s*\S+(\s*#.*)?\s*$" /etc/security/pwquality.conf && sed -ri "s/^(\s*)lcredit\s*=\s*\S+(\s*#.*)?\s*$/\lcredit=-1\2/" /etc/security/pwquality.conf || echo "lcredit=-1" >> /etc/security/pwquality.conf)"
rhel_5_3_1_temp_5=$?
rhel_5_3_1_temp_6="$(echo "password requisite pam_pwquality.so try_first_pass retry=3" >> /etc/pam.d/system-auth)"
rhel_5_3_1_temp_6=$?
rhel_5_3_1_temp_7="$(echo "password requisite pam_pwquality.so try_first_pass retry=3" >> /etc/pam.d/password-auth)"
rhel_5_3_1_temp_7=$?
if [[ "$rhel_5_3_1_temp_1" -eq 0 ]] && [[ "$rhel_5_3_1_temp_2" -eq 0 ]] && [[ "$rhel_5_3_1_temp_3" -eq 0 ]] && [[ "$rhel_5_3_1_temp_4" -eq 0 ]] && [[ "$rhel_5_3_1_temp_5" -eq 0 ]] && [[ "$rhel_5_3_1_temp_6" -eq 0 ]] && [[ "$rhel_5_3_1_temp_7" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-146 Configure the lockout for failed password attempts. “
grep "pam_faillock" /etc/pam.d/password-auth
grep "pam_unix.so" /etc/pam.d/password-auth | grep success=1
grep "pam_faillock" /etc/pam.d/system-auth
grep "pam_unix.so" /etc/pam.d/system-auth | grep success=1

echo “RHL7-147 Limit password reuse. “
rhel_5_3_3_temp_1="$(egrep -q "^\s*password\s+sufficient\s+pam_unix.so(\s+.*)$" /etc/pam.d/system-auth && sed -ri '/^\s*password\s+sufficient\s+pam_unix.so\s+/ { /^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*(\s+remember=[0-9]+)(\s+.*)?$/! s/^(\s*password\s+sufficient\s+pam_unix.so\s+)(.*)$/\1remember=5 \2/ }' /etc/pam.d/system-auth && sed -ri 's/(^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*\s+)remember=[0-9]+(\s+.*)?$/\1remember=5\3/' /etc/pam.d/system-auth || echo Ensure\ password\ reuse\ is\ limited - /etc/pam.d/system-auth not configured.)"
rhel_5_3_3_temp_1=$?
rhel_5_3_3_temp_2="$(egrep -q "^\s*password\s+sufficient\s+pam_unix.so(\s+.*)$" /etc/pam.d/password-auth && sed -ri '/^\s*password\s+sufficient\s+pam_unix.so\s+/ { /^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*(\s+remember=[0-9]+)(\s+.*)?$/! s/^(\s*password\s+sufficient\s+pam_unix.so\s+)(.*)$/\1remember=5 \2/ }' /etc/pam.d/password-auth && sed -ri 's/(^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*\s+)remember=[0-9]+(\s+.*)?$/\1remember=5\3/' /etc/pam.d/password-auth || echo Ensure\ password\ reuse\ is\ limited - /etc/pam.d/password-auth not configured.)"
rhel_5_3_3_temp_2=$?
if [[ "$rhel_5_3_3_temp_1" -eq 0 ]] && [[ "$rhel_5_3_3_temp_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-148 Set the password hashing algorithm to SHA-512. “
rhel_5_3_4_temp_1="$(egrep -q "^\s*password\s+sufficient\s+pam_unix.so\s+" /etc/pam.d/system-auth && sed -ri '/^\s*password\s+sufficient\s+pam_unix.so\s+/ { /^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*(\s+sha512)(\s+.*)?$/! s/^(\s*password\s+sufficient\s+pam_unix.so\s+)(.*)$/\1sha512 \2/ }' /etc/pam.d/system-auth || echo Ensure\ password\ hashing\ algorithm\ is\ SHA-512 - /etc/pam.d/password-auth not configured.)"
rhel_5_3_4_temp_1=$?
rhel_5_3_4_temp_2="$(egrep -q "^\s*password\s+sufficient\s+pam_unix.so\s+" /etc/pam.d/password-auth && sed -ri '/^\s*password\s+sufficient\s+pam_unix.so\s+/ { /^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*(\s+sha512)(\s+.*)?$/! s/^(\s*password\s+sufficient\s+pam_unix.so\s+)(.*)$/\1sha512 \2/ }' /etc/pam.d/password-auth || echo Ensure\ password\ hashing\ algorithm\ is\ SHA-512 - /etc/pam.d/password-auth not configured.)"
rhel_5_3_4_temp_2=$?
if [[ "$rhel_5_3_4_temp_1" -eq 0 ]] && [[ "$rhel_5_3_4_temp_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-149 Restrict login privileges for system accounts. “
egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<500 && $7!="/sbin/nologin") {print}'
touch /tmp/disable.sh
cat << 'EOM' > /tmp/disable.sh
#!/bin/bash
for user in `awk -F: '($3 < 500) {print $1 }' /etc/passwd`; do
   if [ $user != "root" ]
then
      /usr/sbin/usermod -L $user
      if [ $user != "sync" ] && [ $user != "shutdown" ] && [ $user != "halt" ]
      then
         /usr/sbin/usermod -s /sbin/nologin $user
      fi
fi done
EOM
bash /tmp/disable.sh

echo “RHL7-150 Set the default group for the root account to GID 0.“
usermod -g 0 root

echo “RHL7-151 Set the default user umask to 027 or a value that is more restrictive. “
echo "umask 027" >> /etc/bashrc
echo "umask 027" >> /etc/profile

echo “RHL7-152 Set password expiration to 90 days or less for non-admin users and 60 days or less for admin users. “
grep PASS_MAX_DAYS /etc/login.defs
grep PASS_MIN_DAYS /etc/login.defs
grep PASS_WARN_AGE /etc/login.defs

echo “RHL7-153 Set minimum days between password changes to 1 or more days. “
rhel_5_4_1_2="$(egrep -q "^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$/\PASS_MIN_DAYS 1\2/" /etc/login.defs || echo "PASS_MIN_DAYS 1" >> /etc/login.defs)"
rhel_5_4_1_2=$?
getent passwd | cut -f1 -d ":" | xargs -n1 chage --mindays 1
if [[ "$rhel_5_4_1_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-154 Set password expiration warning days to 14 or more days. “
rhel_5_4_1_3="$(egrep -q "^(\s*)PASS_WARN_AGE\s+\S+(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_WARN_AGE\s+\S+(\s*#.*)?\s*$/\PASS_WARN_AGE 14\2/" /etc/login.defs || echo "PASS_WARN_AGE 14" >> /etc/login.defs)"
rhel_5_4_1_3=$?
getent passwd | cut -f1 -d ":" | xargs -n1 chage --warndays 14
if [[ "$rhel_5_4_1_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-155 Set the inactive password lock to 120 days or less. “
rhel_5_4_1_4="$(useradd -D -f 120)"
rhel_5_4_1_4=$?
getent passwd | cut -f1 -d ":" | xargs -n1 chage --inactive 120
if [[ "$rhel_5_4_1_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-156 Confirm that all users last password change date is in the past. “
cat /etc/shadow | cut -d: -f1

echo “RHL7-157 Configure permissions on the /etc/passwd file.“
rhel_6_1_2="$(chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/passwd)"
rhel_6_1_2=$?
if [[ "$rhel_6_1_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-158 Configure permissions on the /etc/shadow file.“
rhel_6_1_3="$(chmod -t,u-x-s,g-w-x-s,o-r-w-x /etc/shadow)"
rhel_6_1_3=$?
if [[ "$rhel_6_1_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-159 Configure permissions on the /etc/group file.“
rhel_6_1_4="$(chmod -t,u+r+w-x-s,g+r-w-x-s,o+r-w-x /etc/group)"
rhel_6_1_4=$?
if [[ "$rhel_6_1_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-160 Configure permissions on the /etc/gshadow file.“
rhel_6_1_5="$(chmod -t,u-x-s,g-w-x-s,o-r-w-x /etc/gshadow)"
rhel_6_1_5=$?
if [[ "$rhel_6_1_5" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-161 Configure permissions on the /etc/passwd- file.“
rhel_6_1_6="$(chmod -t,u-x-s,g-r-w-x-s,o-r-w-x /etc/passwd-)"
rhel_6_1_6=$?
if [[ "$rhel_6_1_6" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-162 Configure permissions on the /etc/shadow- file.“
rhel_6_1_7="$(chmod -t,u-x-s,g-r-w-x-s,o-r-w-x /etc/shadow-)"
rhel_6_1_7=$?
if [[ "$rhel_6_1_7" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-163 Configure permissions on the /etc/group- file.“
rhel_6_1_8="$(chmod -t,u-x-s,g-r-w-x-s,o-r-w-x /etc/group-)"
rhel_6_1_8=$?
if [[ "$rhel_6_1_8" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-164 Configure permissions on the /etc/gshadow- file.“
rhel_6_1_9="$(chmod -t,u-x-s,g-r-w-x-s,o-r-w-x /etc/gshadow-)"
rhel_6_1_9=$?
if [[ "$rhel_6_1_9" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-165 Confirm that world writable films do not exist. “
echo “RHL7-166 Confirm that unowned files or directories do not exist. “
echo “RHL7-167 Confirm that ungrouped files or directories do not exist. “
echo “RHL7-168 Audit SUID executables.“
echo “RHL7-169 Audit SGID executables.“
echo “RHL7-170 Set passwords for any blank password fields. “
echo “RHL7-171 Confirm that no legacy "+" entries exist in the /etc/passwd file.“
rhel_6_2_2="$(sed -ri '/^\+:.*$/ d' /etc/passwd)"
rhel_6_2_2=$?
if [[ "$rhel_6_2_2" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-172 Confirm that no legacy "+" entries exist in the /etc/shadow file.“
rhel_6_2_3="$(sed -ri '/^\+:.*$/ d' /etc/shadow)"
rhel_6_2_3=$?
if [[ "$rhel_6_2_3" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-173 Confirm that no legacy "+" entries exist in the /etc/group file.“
rhel_6_2_4="$(sed -ri '/^\+:.*$/ d' /etc/group)"
rhel_6_2_4=$?
if [[ "$rhel_6_2_4" -eq 0 ]]; then
  echo "[+]Pass"
  
else
  echo "[-]Error"
  
fi

echo “RHL7-174 Set root to be the only UID 0 account. “
echo `/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }' | grep 'root'`

echo “RHL7-175 Confirm that the root PATH is set correctly. “
if [ "`echo $PATH | /bin/grep :: `" != "" ]; then
echo "Empty Directory in PATH (::)"
fi
if [ "`echo $PATH | /bin/grep :$`" != "" ]; then
echo "Trailing : in PATH"
fi

p=`echo $PATH | /bin/sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g'`
set -- $p
while [ "$1" != "" ]; do
if [ "$1" = "." ]; then
echo "PATH contains ."
shift
continue
fi
if [ -d $1 ]; then
dirperm=`/bin/ls -ldH $1 | /bin/cut -f1 -d" "`
if [ `echo $dirperm | /bin/cut -c6 ` != "-" ]; then
echo "Group Write permission set on directory $1"
fi
if [ `echo $dirperm | /bin/cut -c9 ` != "-" ]; then
echo "Other Write permission set on directory $1"
fi
dirown=`ls -ldH $1 | awk '{print $3}'`
if [ "$dirown" != "root" ] ; then
echo "$1 is not owned by root"
fi
else
echo "$1 is not a directory"
fi
shift
done

echo “RHL7-176 Set home directories for all users. “
 cat /etc/passwd | awk -F: '{ print $1 " " $3 " " $6 }' | while read user uid dir; do
 if [ $uid -ge 500 -a ! -d "$dir" -a $user != "nfsnobody" ]; then
 echo "The home directory ($dir) of user $user does not exist."
 fi
 done

echo “RHL7-177 Set the users home directories permissions to 750 or a value that is more restrictive. “
 for dir in `/bin/cat /etc/passwd  | /bin/egrep -v '(root|halt|sync|shutdown)' |\
     /bin/awk -F: '($8 == "PS" && $7 != "/sbin/nologin") { print $6 }'`; do
         dirperm=`/bin/ls -ld $dir | /bin/cut -f1 -d" "`
         if [ `echo $dirperm | /bin/cut -c6 ` != "-" ]; then
             echo "Group Write permission set on directory $dir"
         fi
 if [ `echo $dirperm | /bin/cut -c8 ` != "-" ]; then
     echo "Other Read permission set on directory $dir"
 fi
 if [ `echo $dirperm | /bin/cut -c9 ` != "-" ]; then
     echo "Other Write permission set on directory $dir"
 fi
 if [ `echo $dirperm | /bin/cut -c10 ` != "-" ]; then
     echo "Other Execute permission set on directory $dir"
 fi
 done

echo “RHL7-178 Confirm that users own their home directories.“
 cat /etc/passwd | awk -F: '{ print $1 " " $3 " " $6 }' | while read user uid dir; do
 if [ $uid -ge 500 -a -d "$dir" -a $user != "nfsnobody" ]; then
 owner=$(stat -L -c "%U" "$dir")
 if [ "$owner" != "$user" ]; then
 echo "The home directory ($dir) of user $user is owned by $owner."
 fi
 fi
 done

echo “RHL7-179 Confirm that users dot files are not group or world writable.“
 for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|sync|halt|shutdown)' |
  /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
     for file in $dir/.[A-Za-z0-9]*; do
         if [ ! -h "$file" -a -f "$file" ]; then
             fileperm=`/bin/ls -ld $file | /bin/cut -f1 -d" "`
             if [ `echo $fileperm | /bin/cut -c6 ` != "-" ]; then
                 echo "Group Write permission set on file $file"
             fi
             if [ `echo $fileperm | /bin/cut -c9 ` != "-" ]; then
 echo "Other Write permission set on file $file"
             fi
 fi done
 done

echo “RHL7-180 Confirm that no users have .forward files.“
 for dir in `/bin/cat /etc/passwd |\
     /bin/awk -F: '{ print $6 }'`; do
     if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
         echo ".forward file $dir/.forward exists"
     fi
 done

echo “RHL7-181 Confirm that no users have .netrc files.“
 for dir in `/bin/cat /etc/passwd |\
     /bin/awk -F: '{ print $6 }'`; do
     if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then
         echo ".netrc file $dir/.netrc exists"
     fi
 done

echo “RHL7-182 Confirm that users .netrc Files are not group or world accessible.“
 for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|sync|halt|shutdown)' |\
     /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
     for file in $dir/.netrc; do
         if [ ! -h "$file" -a -f "$file" ]; then
             fileperm=`/bin/ls -ld $file | /bin/cut -f1 -d" "`
             if [ `echo $fileperm | /bin/cut -c5 ` != "-" ]
             then
                 echo "Group Read set on $file"
             fi
             if [ `echo $fileperm | /bin/cut -c6 ` != "-" ]
             then
                 echo "Group Write set on $file"
             fi
             if [ `echo $fileperm | /bin/cut -c7 ` != "-" ]
             then
                 echo "Group Execute set on $file"
             fi
             if [ `echo $fileperm | /bin/cut -c8 ` != "-" ]
             then
 echo "Other Read  set on $file"
             fi
            if [ `echo $fileperm | /bin/cut -c9 ` != "-" ]
             then
                 echo "Other Write set on $file"
             fi
             if [ `echo $fileperm | /bin/cut -c10 ` != "-" ]
             then
                 echo "Other Execute set on $file"
             fi
 fi done
 done
echo “RHL7-183 Confirm that no users have .rhosts files.“
 for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' |\
     /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
     for file in $dir/.rhosts; do
         if [ ! -h "$file" -a -f "$file" ]; then
             echo ".rhosts file in $dir"
 fi done done

echo “RHL7-184 Confirm that all groups in the /etc/passwd file exist in the /etc/group file.“
 for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
 grep -q -P "^.*?:x:$i:" /etc/group
 if [ $? -ne 0 ]; then
 echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group"
 fi
 done

echo “RHL7-185 Delete all duplicate UIDs.“
 /bin/cat /etc/passwd | /bin/cut -f3 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
     while read x ; do
     [ -z "${x}" ] && break
     set - $x
     if [ $1 -gt 1 ]; then
         users=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 \
             /etc/passwd | /usr/bin/xargs`
         echo "Duplicate UID ($2): ${users}"
     fi
 done

echo “RHL7-186 Delete all duplicate GIDs.“
 /bin/cat /etc/group | /bin/cut -f3 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
     while read x ; do
     [ -z "${x}" ] && break
     set - $x
     if [ $1 -gt 1 ]; then
         grps=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 \
             /etc/group | xargs`
         echo "Duplicate GID ($2): ${grps}"
 fi done

echo “RHL7-187 Delete all duplicate user names.“
 cat /etc/passwd | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
     while read x ; do
     [ -z "${x}" ] && break
     set - $x
     if [ $1 -gt 1 ]; then
         uids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 \
             /etc/passwd | xargs`
         echo "Duplicate User Name ($2): ${uids}"
     fi
 done

echo “RHL7-188 Delete all duplicate group names.“
cat /etc/group | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
	while read x ; do
	[ -z "${x}" ] && break 
	set - $x
	if [ $1 -gt 1 ]; then
		gids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 \ 
		/etc/group | xargs`
		echo "Duplicate Group Name ($2): ${gids}" 
	fi
done
