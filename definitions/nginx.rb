define :build_nginx, :version => nil, :repository => nil, :reprepro => nil do

  include_recipe 'pkg-build::deps'

  nginx_name = [node[:pkg_build][:pkg_prefix], 'nginx', params[:version]].compact.join('-')

  node[:pkg_build][:nginx][:pkg_dependencies].each do |pkg|
    package pkg do
      action :upgrade
    end
  end

  builder_remote nginx_name do
    remote_file "#{node[:pkg_build][:nginx][:base_uri]}/nginx-#{params[:version]}.tar.gz"
    suffix_cwd "nginx-#{params[:version]}"
    commands [
      "./configure --prefix=$PKG_DIR/#{node[:pkg_build][:nginx][:sbin_path_prefix]} \
              --with-sha1=/usr/lib \
              --with-sha1-asm \
              --user=#{node[:pkg_build][:nginx][:user]} \
              --group=#{node[:pkg_build][:nginx][:group]} \
              --conf-path=#{node[:pkg_build][:nginx][:conf_path]} \
              --http-log-path=#{node[:pkg_build][:nginx][:http_log_path]} \
              --error-log-path=#{node[:pkg_build][:nginx][:error_log_path]} \
              --pid-path=#{File.join(node[:pkg_build][:nginx][:pid_dir], node[:pkg_build][:nginx][:pid_file])} \
              --lock-path=#{node[:pkg_build][:nginx][:lock_path]} \
              --http-client-body-temp-path=#{node[:pkg_build][:nginx][:http_client_body_temp_path]} \
              --http-proxy-temp-path=#{node[:pkg_build][:nginx][:http_proxy_temp_path]} \
              --http-fastcgi-temp-path=#{node[:pkg_build][:nginx][:http_fastcgi_temp_path]} \
              #{node[:pkg_build][:nginx][:additional_compile_options]}",
      'make',
      'make install',
      'mkdir -p $PKG_DIR/var/lib/nginx',
      'mkdir -p $PKG_DIR/var/log/nginx',
      'mkdir -p $PKG_DIR/etc/nginx',
      'mkdir -p $PKG_DIR/etc/init.d'
    ]
    creates File.join(node[:builder][:build_dir], nginx_name, nginx_name, 'src/nginx.o')
  end

  template File.join(node[:builder][:build_dir], nginx_name, 'preinst') do
    source 'nginx/preinst.erb'
    mode 0755
  end

  template File.join(node[:builder][:build_dir], nginx_name, 'postinst') do
    source 'nginx/postinst.erb'
    mode 0755
  end

  template File.join(node[:builder][:packaging_dir], nginx_name, 'etc/init.d/nginx') do
    source 'nginx/nginx-initd.erb'
    mode 0755
  end

  fpm_tng_package [node[:pkg_build][:pkg_prefix], 'nginx'].compact.join('-') do
    output_type 'deb'
    description "Nginx #{params[:version]}"
    depends %w(libc6 adduser libpcre3 libpcre3-dev)
    after_install File.join(node[:builder][:build_dir], nginx_name, 'postinst')
    before_install File.join(node[:builder][:build_dir], nginx_name, 'preinst')
    version params[:version]
    chdir File.join(node[:builder][:packaging_dir], nginx_name)
    reprepro node[:pkg_build][:reprepro]
    repository params[:repository] if params[:repository]
  end
end
