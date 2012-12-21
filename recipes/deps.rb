# These are all the things we want all the time. So load them!

# This is currently ineffective, but left because it should be soon
ruby_block 'reload paths on new ruby' do
  block do
    node.default[:pkg_build][:gems][:exec] = File.join(node.languages.ruby.bin_dir, 'gem')
    node.default[:pkg_build][:passenger][:ruby_bin] = node.languages.ruby.bin_dir
    node.default[:pkg_build][:passenger][:root] = File.dirname(node.languages.ruby.bin_dir)
  end
  action :nothing
  subscribes :create, 'ohai[ruby]', :immediately
end

include_recipe 'builder'
include_recipe 'fpm-tng'

if(node[:pkg_build][:reprepro])
  include_recipe 'reprepro'
end

node.set[:pkg_build][:builder] = true
