include_recipe 'apt'

unless(node[:pkg_build][:builder])
  apt_node = search(:node, 'builder:true').first
end

# TODO: Update this once reprepro can do ssl automagically
if(apt_node)
  gem_gem node[:pkg_build][:gems][:exec]
  apt_url = "http://#{apt_node[:ipaddress]}:#{apt_node[:reprepro][:listen_port]}"
  apt_repository 'pkg_build_repository' do
    uri apt_url
    distribution node[:lsb][:codename]
    components apt_node[:reprepro][:pulls][:component].split
    key ::File.join(apt_url, "#{apt_node[:gpg][:name][:email]}.gpg.key")
    action :add
  end
else
  Chef::Log.warn 'Failed to locate pkg-build node. No apt repository added!'
end
