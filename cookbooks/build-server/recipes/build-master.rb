include_recipe "build-server::cobbler-common"

template "/etc/cobbler/settings" do
  source "etc/cobbler/settings-build-master.erb"
  variables({
    ipaddress: node[:ipaddress]
  })
  notifies :restart, "service[cobblerd]"
  notifies :restart, "service[httpd]"
end

Cobbler_files=%w{modules.conf users.conf users.digest}

Cobbler_files.each do |f|
  cookbook_file "/etc/cobbler/#{f}" do
    source "etc/cobbler/#{f}"
    notifies :restart, "service[cobblerd]"
    notifies :restart, "service[httpd]"
  end
end

bash "cobbler sync" do
  command "cobbler sync"
  action :run
end

# We template this to the master, from whence it gets synced to the clients
# with the rest of /var/lib/cobbler.
remote_directory "/var/lib/cobbler/kickstarts" do
  source "var/lib/cobbler/kickstarts"
  user "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  notifies :run, "bash[cobbler sync]"
end

remote_directory "/var/lib/cobbler/snippets" do
  source "var/lib/cobbler/snippets"
  user "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  notifies :run, "bash[cobbler sync]"
end

directory "/local/1/cobbler/iso" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

cookbook_file '/apps/hft/bin/hftbuild' do
  source 'apps/hft/bin/hftbuild'
  owner 'root'
  group 'root'
  mode '0754'
  action :create
end

cookbook_file '/apps/hft/bin/cobbler-update' do
  source 'apps/hft/bin/cobbler-update'
  owner 'root'
  group 'root'
  mode '0754'
  action :create
end

cookbook_file '/apps/hft/bin/hftbuild-geniso' do
  source 'apps/hft/bin/hftbuild-geniso'
  owner 'root'
  group 'root'
  mode 0754
  action :create
end

# this was a hack from when we needed a separate build strategy for NSD servers
file '/apps/hft/bin/hftbuild-nsd' do
  action :delete
end

cron_d 'cobbler-update-all' do
  hour 23
  minute 0
  command '/apps/hft/bin/cobbler-update --all >/dev/null 2>&1'
  user 'root'
  action :create
end

