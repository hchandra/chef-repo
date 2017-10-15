include_recipe "xinetd::default"

# Cobbler and its dependencies are all in the colo repo, all from EPEL
Cobbler_dep_pkgs = %w{ httpd mod_ssl rsync pykickstart yum-utils dhcp syslinux }
Cobbler_svcs = %w{ cobblerd httpd }

Cobbler_dep_pkgs.each do |p|
  package p do
    action :install
  end
end

# raise because /local/1 should be manually configured, based on local disks
raise "cobbler-common requires /local/1 to exist!" unless File.exist?('/local/1')

# when it's there, make sure the cobbler tree is there
directory '/local/1/cobbler' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
  not_if { File.exist?('/local/1/cobbler') }
end
directory '/local/1/cobbler/iso' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

package "cobbler" do
  version '2.4.0-1.el6'
  action :install
  notifies :run, "bash[update cobbler web content]"
  only_if "test -d /local/1"
end

Cobbler_svcs.each do |s|
  service s do
    action [ :enable, :start ]
  end
end

xinetd_service "rsync" do
  id "rsync"
  socket_type "stream"
  wait false
  user "root"
  server "/usr/bin/rsync"
  server_args "--daemon"
  flags "IPv4"
  log_on_failure "USERID"

  action :enable
end

# Triggered by cobbler RPM update
bash "update cobbler web content" do
  code "rsync -a /var/www/cobbler /local/1"
  action :nothing
end

if node[:platform_version] =~ /^5/ 
  cobbler_file = 'etc/httpd/conf.d/cobbler-5.conf'
elsif node[:platform_version] =~ /^6/
  cobbler_file = 'etc/httpd/conf.d/cobbler.conf'
else
  raise "ERROR: no http cobbler config defined for #{node[:platform_version]}"
end

cookbook_file "/etc/httpd/conf.d/cobbler.conf" do
  source "#{cobbler_file}"
  owner "root"
  group "root"
  mode 0644

  action :create
  notifies :restart, "service[httpd]"
end

