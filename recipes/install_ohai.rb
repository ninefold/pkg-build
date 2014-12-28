#
# Cookbook Name:: pkg_build
# Recipe:: install_ohai
#

# Installs a custom version of ohai which is required
# until the proper release supports ruby 2.2, we need
# to do this at the start of the run using resource
# available in ninefold_handlers cookbook

ninefold_handlers_gem "ohai" do
  source 'git'
  git_path 'https://github.com/ninefold/ohai'
  git_ref 'nf_hotfix'
  install_type :upgrade
  remove_first true
  action :nothing
end.run_action(:install)
