include_recipe "xinetd::default"

Support_pkgs = {
  'dhcp' => nil,
  'httpd' => nil,
  'livecd-tools' => nil,
  'mod_ssl' => nil,
  'pykickstart' => nil,
  'rsync' => nil,
  'syslinux' => nil,
  'yum-utils' => nil
}.each do |p, v|
  package p do
    version v if v
    action :install
  end
end

directory '/local/1/cobbler' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

directory '/local/1/cobbler/iso' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

package "cobbler" do
  version '2.6.3-1.el6'
  action :install
  notifies :run, "bash[update cobbler web content]"
end

%w{
  httpd
  cobblerd
}.each do |s|
  service s do
    action [ :enable, :start ]
  end
end

# Triggered by cobbler RPM update
bash "update cobbler web content" do
  code "rsync -a /var/www/cobbler /local/1"
  action :nothing
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

cookbook_file "/etc/httpd/conf.d/cobbler.conf" do
  source 'etc/httpd/conf.d/cobbler.conf'
  owner "root"
  group "root"
  mode 0644

  action :create
  notifies :restart, "service[httpd]"
end

