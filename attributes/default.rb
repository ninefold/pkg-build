default[:pkg_build][:builder] = false
default[:pkg_build][:pkg_prefix] = 'hw'
default[:pkg_build][:use_pkg_build_ruby] = false
default[:pkg_build][:gems][:exec] = node.languages.ruby.gem_bin
default[:pkg_build][:reprepro] = true
