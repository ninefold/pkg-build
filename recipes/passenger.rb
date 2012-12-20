include_recipe 'pkg-build::deps'

ruby_block 'Detect omnibus ruby' do
  block do
    if(node[:languages][:ruby][:ruby_bin].include?('/opt/chef'))
      raise 'Cannot build passenger against omnibus Chef Ruby installation!'
    end
  end
  not_if do
    node[:pkg_build][:passenger][:allow_omnibus_chef_ruby]
  end
end

if(node[:pkg_build][:use_pkg_build_ruby])
  node.set[:pkg_build][:passenger][:ruby_dependency] = [
    node[:pkg_build][:pkg_prefix], 
    "ruby#{node[:pkg_build][:ruby][:version]}"
  ].compact.join('-')
end

%w(libcurl4-gnutls-dev apache2 apache2-prefork-dev).each do |dep_pkg|
  package dep_pkg
end

libpassenger_name = [node[:pkg_build][:pkg_prefix], 'libapache2-mod-passenger'].compact.join('-')
passenger_gem_name = [node[:pkg_build][:pkg_prefix], 'rubygem-passenger'].compact.join('-')

builder_gem libpassenger_name do
  gem_name 'passenger'
  gem_version '3.0.18'
  suffix_cwd 'passenger-3.0.18'
  commands [
    "#{node[:pkg_build][:passenger][:ruby_bin]}/rake apache2",
    'mkdir -p $PKG_DIR/etc/apache2/mods-available',
    'mkdir -p $PKG_DIR/usr/lib/apache2/modules',
    'cp ext/apache2/mod_passenger.so $PKG_DIR/usr/lib/apache2/modules',
    "echo \"<IfModule mod_passenger.c>\\n  PassengerRoot #{node[:pkg_build][:passenger][:root]}\n  PassengerRuby #{node[:pkg_build][:passenger][:ruby_bin]}/ruby\\n</IfModule>\\n\" > $PKG_DIR/etc/apache2/mods-available/passenger.conf",
    "echo \"LoadModule passenger_module /usr/lib/apache2/modules/mod_passenger.so\" > $PKG_DIR/etc/apache2/mods-available/passenger.load"
  ]
end

fpm_tng_package passenger_gem_name do
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
  depends [
    'apache2', 'apache2-mpm-prefork', passenger_gem_name, node[:pkg_build][:passenger][:ruby_dependency]
  ].compact
  reprepro true
end

if(node[:pkg_build][:passenger][:dummy_rake_install])
  rake_name = [node[:pkg_build][:pkg_prefix], 'rubygem', 'rake'].compact.join('-')

  builder_dir rake_name do
  end

  reprepro_deb rake_name do
    action :remove
  end

  fpm_tng_package rake_name do
    output_type 'deb'
    description 'Empty rake installation to prevent conflicts with ruby provided rake'
    chdir File.join(node[:builder][:packaging_dir], rake_name)
    reprepro true
  end
end
