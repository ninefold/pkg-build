if(node[:pkg_build][:isolate])
  include_recipe 'pkg-build'

  Chef::Log.info "Nginx versions to build: #{[node[:pkg_build][:nginx][:version], node[:pkg_build][:nginx][:versions]].flatten.compact.uniq}"
  [node[:pkg_build][:nginx][:version], node[:pkg_build][:nginx][:versions]].flatten.compact.uniq.each do |ver|
    if ver != ""
      pkg_build_isolate "nginx-#{ver}" do
        container 'ubuntu_1204'
        attributes(
          :pkg_build => {
            :nginx => {
              :version => ver,
              :user => node[:pkg_build][:nginx][:user],
              :group => node[:pkg_build][:nginx][:group]
            }
          }
        )
        run_list %w(recipe[pkg-build::nginx])
        not_if do
          File.exists?(
            File.join(
              node[:fpm_tng][:package_dir],
              "#{[node[:pkg_build][:pkg_prefix], 'nginx', ver].compact.join('-')}.deb"
            )
          )
        end
      end
    end
  end
else
  include_recipe 'pkg-build::deps'
  [node[:pkg_build][:nginx][:version], node[:pkg_build][:nginx][:versions]].flatten.compact.uniq.each do |ver|
    build_nginx ver do
      version ver
      if(node[:pkg_build][:repository])
        repository node[:pkg_build][:repository]
      end
    end
  end
end
