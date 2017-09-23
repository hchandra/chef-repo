# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "hchandra"
client_key               "#{current_dir}/hchandra.pem"
chef_server_url          "https://api.chef.io/organizations/barcap"
cookbook_path            ["#{current_dir}/../cookbooks"]
cache_type 		 'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums")
