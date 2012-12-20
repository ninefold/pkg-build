include_recipe 'pkg-build::deps'

%w(
  openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev 
  libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev 
  autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config
).each do |r_dep|
  package r_dep
end

ruby_name = [node[:pkg_build][:pkg_prefix], "ruby#{node[:pkg_build][:ruby][:version]}"].compact.join('-')

builder_remote ruby_name do
  remote_file ::File.join(node[:pkg_build][:ruby][:uri_base], "ruby-#{node[:pkg_build][:ruby][:version]}-#{node[:pkg_build][:ruby][:patchlevel]}.tar.gz")
  suffix_cwd "ruby-#{node[:pkg_build][:ruby][:version]}-#{node[:pkg_build][:ruby][:patchlevel]}"
  commands [
    'autoconf',
    "./configure --prefix=#{node[:pkg_build][:ruby][:install_prefix]} --disable-install-doc --enable-shared --with-baseruby=#{RbConfig.ruby} --program-suffix=#{node[:pkg_build][:ruby][:version]}",
    "make",
    "make install DESTDIR=$PKG_DIR"
  ]
end

template File.join(node[:builder][:build_dir], ruby_name, 'postinst') do
  source 'ruby-postinst.erb'
  mode 0755
end

fpm_tng_package ruby_name do
  output_type 'deb'
  description "Ruby language - #{node[:pkg_build][:ruby][:version]}-#{node[:pkg_build][:ruby][:patchlevel]}"
  version "#{node[:pkg_build][:ruby][:version]}-#{node[:pkg_build][:ruby][:patchlevel]}"
  chdir File.join(node[:builder][:packaging_dir], ruby_name)
  after_install File.join(node[:builder][:build_dir], ruby_name, 'postinst')
  depends %w(
    ca-certificates libc6 libffi6 libgdbm3 libncursesw5 libreadline6 libssl1.0.0 
    libtinfo5 libyaml-0-2 zlib1g
  )
  provides %w(
    ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 ruby-interpreter irb1.9.1 libdbm-ruby1.9.1 
    libgdbm-ruby1.9.1 libopenssl-ruby1.9.1 libreadline-ruby1.9.1 hw-rubygem-rake
  )
  conflicts %w(
    ruby1.9.1 ruby1.9.1-dev ruby1.9.1-full irb1.8 libdbm-ruby1.9.1 libgdbm-ruby1.9.1
    libopenssl-ruby1.9.1 libreadline-ruby1.9.1 rdoc1.8
  )
  replaces %w(
    irb1.8 libdbm-ruby1.9.1 libgdbm-ruby-1.9.1 libopenssl-ruby1.9.1
    libreadline-ruby1.9.1 rdoc1.8 ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 ruby1.9.1-full
  )
  reprepro true
end

if(node[:pkg_build][:use_pkg_build_ruby])

  include_recipe 'ohai'

  ohai "ruby" do
    action :nothing
  end

  execute 'refresh apt' do
    command 'apt-get update'
#    action :nothing
#    subscribes :run, "fpm_tng_package[#{ruby_name}]", :immediately
  end

  package ruby_name do
    notifies :reload, resources(:ohai => 'ruby'), :immediately
  end
  
  # NOTE: What would be nice would be to reload these values automagically
  # by subscribing to the ohai reload. However, that happens at execution time
  # and the resources using these already have their values. So, it might be
  # something to default them into the resource setup in the provider. Or having
  # block value attributes to make attribute values execution time discoverable. heh.
  node.default[:pkg_build][:gems][:exec] = '/usr/bin/gem'
  node.default[:pkg_build][:passenger][:ruby_bin] = '/usr/bin'
  node.default[:pkg_build][:passenger][:root] = '/usr'

  gem_package 'custom ruby fpm' do
    package_name 'fpm'
    notifies :create, 'ruby_block[update fpm path]', :immediately
    gem_binary '/usr/bin/gem'
  end
  
  ruby_block 'update fpm path' do
    action :nothing
    block do
      node.set[:fpm_tng][:exec] = '/usr/local/bin/fpm'
    end
  end
end
