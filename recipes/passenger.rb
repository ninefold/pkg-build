include_recipe 'pkg-build::deps'

libpassenger_dependencies = %w(apache2 apache2-mpm-prefork) + [[node[:pkg_build][:pkg_prefix], 'rubygem-passenger'].compact.join('-')]

if(node[:pkg_build][:use_pkg_build_ruby])
  libpassenger_dependencies << [node[:pkg_build][:pkg_prefix], "ruby#{node[:pkg_build][:ruby][:version]}"].compact.join('-')
end

%w(libcurl4-gnutls-dev apache2 apache2-prefork-dev).each do |dep_pkg|
  package dep_pkg
end

libpassenger_name = [node[:pkg_build][:pkg_prefix], 'libapache2-mod-passenger'].compact.join('-')

builder_gem libpassenger_name do
  gem_name 'passenger'
  gem_version '3.0.18'
  suffix_cwd 'passenger-3.0.18'
  commands [
    "#{node[:pkg_build][:passenger][:ruby_bin]}/rake apache2",
    'mkdir -p $PKG_DIR/etc/apache2/mods-available',
    'mkdir -p $PKG_DIR/usr/lib/apache2/modules',
    'cp ext/apache2/mod_passenger.so $PKG_DIR/usr/lib/apache2/modules',
    "echo \"<IfModule mod_passenger.c>\\n  PassengerRoot /usr\n  PassengerRuby #{node[:pkg_build][:passenger][:ruby_bin]}/ruby\\n</IfModule>\\n\" > $PKG_DIR/etc/apache2/mods-available/passenger.conf",
    "echo \"LoadModule passenger_module /usr/lib/apache2/modules/mod_passenger.so\" > $PKG_DIR/etc/apache2/mods-available/passenger.load"
  ]
end

fpm_tng_package [node[:pkg_build][:pkg_prefix], 'rubygem-passenger'].compact.join('-') do
  input_type 'gem'
  output_type 'deb'
  description 'Passenger gem installation'
  version '3.0.18'
  gem_package_name_prefix [node[:pkg_build][:pkg_prefix], 'rubygem'].compact.join('-')
  gem_fix_name false
  gem_gem node[:pkg_build][:gems][:exec]
  input_args 'passenger'
  reprepro true
end

fpm_tng_gemdeps 'passenger' do
  gem_package_name_prefix [node[:pkg_build][:pkg_prefix], 'rubygem'].compact.join('-')
  gem_gem node[:pkg_build][:gems][:exec]
  reprepro true
  version '3.0.18'
end

fpm_tng_package libpassenger_name do
  output_type 'deb'
  description 'Passenger apache module installation'
  chdir File.join(node[:builder][:packaging_dir], libpassenger_name)
  depends libpassenger_dependencies
  reprepro true
end
