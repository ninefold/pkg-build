default[:pkg_build][:passenger][:ruby_bin] = node.languages.ruby.ruby_bin
default[:pkg_build][:passenger][:rake_bin] = 'rake'
default[:pkg_build][:passenger][:ruby_bin_dir] = node.languages.ruby.bin_dir
default[:pkg_build][:passenger][:root] = File.dirname(node.languages.ruby.bin_dir)
default[:pkg_build][:passenger][:version] = '3.0.18'
default[:pkg_build][:passenger][:ruby_dependency] = nil
default[:pkg_build][:passenger][:allow_omnibus_chef_ruby] = false
