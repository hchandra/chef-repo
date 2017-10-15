#platform=x86, AMD64, or Intel EM64T

#
# Barclays GTIS-ST - this file is under Chef control
# src: git/hftadmin/chef-repo/cookbooks/build-server/files/default
#

# System authorization information
auth  --useshadow

# Use text mode install
text

# Firewall configuration
firewall --disabled

# Run the Setup Agent on first boot
firstboot --disable

# System keyboard
keyboard us

# System language
lang en_US

# Use network installation
url --url=$tree

# add repos in use for install
$yum_repo_stanza

# Network information
$SNIPPET('network_config')

# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted

# SELinux configuration
selinux --disabled

# Do not configure the X Window System
skipx

# System timezone
# XXX XXX XXX set from site
timezone  America/New_York

# Install OS instead of upgrade
install

# Disk config
$SNIPPET('disk_config-cloud-6-2015.1')

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')

%packages

%post
$SNIPPET('log_ks_post')
# Start yum configuration 
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('download_config_files')
$SNIPPET('cobbler_register')

# get rid of tty-graphical startup screen
/usr/sbin/plymouth-set-default-theme -R details

# Set up Chef
$SNIPPET('chef-cloud-6-2015.1')

# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps

%end
