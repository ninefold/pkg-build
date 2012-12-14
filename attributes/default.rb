default[:pkg_build][:builder] = false
default[:pkg_build][:pkg_prefix] = 'hw'
default[:pkg_build][:use_pkg_build_ruby] = false
default[:pkg_build][:passenger][:ruby_bin] = RbConfig::CONFIG['bindir']
default[:pkg_build][:passenger][:version] = '3.0.18'
default[:pkg_build][:gems][:exec] = File.join(RbConfig::CONFIG['bindir'], 'gem')
default[:pkg_build][:ruby][:uri_base] = 'http://ftp.ruby-lang.org/pub/ruby/stable/'
default[:pkg_build][:ruby][:version] = '1.9.3'
default[:pkg_build][:ruby][:patchlevel] = 'p327'
default[:pkg_build][:ruby][:install_prefix] = '/usr/local'

