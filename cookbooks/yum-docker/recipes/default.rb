#
# Cookbook Name:: yum-docker
# Recipe:: default
#
#  Installs & configures the yum Docker repostories.  Any attribute supported by
#  the [yum cookbook](https://github.com/chef-cookbooks/yum#parameters) is
#  supported by this cookbook and can be used to override attributes in this
#  cookbook.

# check is platform is supported
platform_family = node['platform_family']
platform = node['platform']
platform_version = node['platform_version']

fail("#{platform_family}/#{platform}/#{platform_version} is not supported by the default recipe") \
 unless node['yum-docker']['supported-families'][platform_family]
        .select { |_version, is_included| is_included }
        .keys
        .include?(platform_version.to_i.to_s)

# install GPG key
cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-Docker' do
  source 'RPM-GPG-KEY-Docker'
  mode '644'
  owner 'root'
  group 'root'
end

# install repos
node['yum-docker']['repos'].each do |repo, value|
  yum_repository repo do
    # define all attributes even though we are not using them all so that the
    #  values can be passed through to override yum repository definitions

    # Attribute Sources:
    #  https://github.com/chef-cookbooks/yum
    #  https://github.com/chef-cookbooks/yum/blob/master/resources/repository.rb

    baseurl value['baseurl'] if value['baseurl']
    cost value['cost'] if value['cost']
    description value['description'] if value['description']
    enabled value['enabled'] if value['enabled']
    enablegroups value['enablegroups'] if value['enablegroups']
    exclude value['exclude'] if value['exclude']
    failovermethod value['failovermethod'] if value['failovermethod']
    fastestmirror_enabled value['fastestmirror_enabled'] if value['fastestmirror_enabled']
    gpgcheck value['gpgcheck'] if value['gpgcheck']
    gpgkey value['gpgkey'] if value['gpgkey']
    http_caching value['http_caching'] if value['http_caching']
    includepkgs value['includepkgs'] if value['includepkgs']
    keepalive value['keepalive'] if value['keepalive']
    make_cache value['make_cache'] if value['make_cache']
    max_retries value['max_retries'] if value['max_retries']
    metadata_expire value['metadata_expire'] if value['metadata_expire']
    mirror_expire value['mirror_expire'] if value['mirror_expire']
    mirrorlist value['mirrorlist'] if value['mirrorlist']
    mirrorlist_expire value['mirrorlist_expire'] if value['mirrorlist_expire']
    mode value['mode'] if value['mode']
    options value['options'] if value['options']
    password value['password'] if value['password']
    priority value['priority'] if value['priority']
    proxy value['proxy'] if value['proxy']
    proxy_username value['proxy_username'] if value['proxy_username']
    proxy_password value['proxy_password'] if value['proxy_password']
    report_instanceid value['report_instanceid'] if value['report_instanceid']
    repositoryid value['repositoryid'] if value['repositoryid']
    skip_if_unavailable value['skip_if_unavailable'] if value['skip_if_unavailable']
    source value['source'] if value['source']
    sslcacert value['sslcacert'] if value['sslcacert']
    sslclientcert value['sslclientcert'] if value['sslclientcert']
    sslclientkey value['sslclientkey'] if value['sslclientkey']
    sslverify value['sslverify'] if value['sslverify']
    timeout value['timeout'] if value['timeout']
    username value['username'] if value['username']
  end if value['managed']
end
