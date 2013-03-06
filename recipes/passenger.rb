include_recipe 'pkg-build::deps'

versions = [node[:pkg_build][:passenger][:version]]
versions += node[:pkg_build][:passenger][:versions] if node[:pkg_build][:passenger][:versions]
versions.uniq!

versions.each do |passenger_version|
  build_passenger "passenger-#{passenger_version}" do
    version passenger_version
    repository node[:pkg_build][:repository]
  end
end
