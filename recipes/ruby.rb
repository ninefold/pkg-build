
versions = node[:pkg_build][:ruby][:versions]
if(node[:pkg_build][:ruby][:version])
  versions << "#{node[:pkg_build][:ruby][:version]}-#{node[:pkg_build][:ruby][:patchlevel]}"
end
versions.uniq!
comparable_versions = []

versions.uniq.each do |r_ver|
  version, patchlevel = r_ver.split('-')
  if(node[:pkg_build][:use_pkg_build_ruby])
    comparable_versions << [Gem::Version.new(version), patchlevel[1,patchlevel.length].to_i]
  end
  
  build_ruby r_ver do
    version version
    patchlevel patchlevel
    if(node[:pkg_build][:repository])
      repository node[:pkg_build][:repository]
    end
  end
end

# TODO: If we get proper execution time attribute resolution, we can
#       make this work in a single converge. Until then, kill the run
#       and let it re-run so we are assured proper ruby bin is used
# TODO: Got this in chef11. delayed attribute cookbook will provide
#       backport. Find time and get things lazy in here
if(node[:pkg_build][:use_pkg_build_ruby])
  install_version = comparable_versions.sort do |a,b|
    unless(a.first == b.first)
      a.first <=> b.first
    else
      a.last <=> b.last
    end
  end.last

  ruby_name = PkgBuild::Ruby.ruby_name(node, install_version.first.version)
  ruby_build = PkgBuild::Ruby.ruby_build(node, install_version.first.version, install_version.last)

  if(node[:pkg_build][:reprepro])
    service 'pkg-build-apache2' do
      action :nothing
      service_name 'apache2'
    end
  end

  execute "install custom ruby - #{ruby_build}" do
    command "dpkg -i #{File.join(node[:fpm_tng][:package_dir], "#{ruby_build}.deb")}"
    if(node[:pkg_build][:reprepro])
      notifies :restart, 'service[pkg-build-apache2]', :immediately 
    end
    not_if do
      begin
        %x{ruby -v}.split(' ')[1].strip == "#{install_version.first.version}p#{install_version.last}"
      rescue
        false
      end
    end
    notifies :create, 'ruby_block[New ruby kills chef run!]', :immediately
  end

  ruby_block 'New ruby kills chef run!' do
    action :nothing
    block do
      raise "New ruby installed (#{ruby_name})! Re-run chef so proper ruby is used"
    end
  end
end
