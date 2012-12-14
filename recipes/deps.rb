# These are all the things we want all the time. So load them!

include_recipe 'builder'
include_recipe 'fpm-tng'
include_recipe 'reprepro'

node.default[:pkg_build][:builder] = true
