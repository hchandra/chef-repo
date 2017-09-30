
  node['mlp-eq']['packages'].each do |mlpeqpkg|
    package mlpeqpkg do
      action :install
    end
  end

