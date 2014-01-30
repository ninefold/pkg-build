if(node[:pkg_build][:isolate])
  pkg_build_isolate "meta-packages" do
    container 'ubuntu_1204'
    attributes(
      :pkg_build => {
        :meta_mappings => node[:pkg_build][:meta_mappings]
      }
    )
    run_list %w(recipe[pkg-build::meta_packages])
    not_if do
      to_process = []
      node[:pkg_build][:meta_mappings].map do |meta_name, info|
        if info[:versions]
          info[:versions].each do |version|
            to_process << Mash.new(
              :version => version
            )
          end
          to_process.map do |pkg_info|
            File.exists?(File.join(node[:fpm_tng][:package_dir], "#{meta_name}-#{pkg_info[:version]}.deb")) ? nil : meta_name
          end
        end
      end.flatten.compact.empty?
    end
  end
else
  include_recipe 'pkg-build::deps'

  directory '/tmp/meta-dir'

  node[:pkg_build][:meta_mappings].map do |meta_name, info|
    to_process = []
    info[:versions].each do |version|
      to_process << Mash.new(
        :version => version,
        :dependencies => "#{info[:new_package_name]} = #{version}"
      )
    end
    to_process.each do |pkg_info|
      pkg_info = Mash.new(pkg_info)
      %w(version dependencies).each do |key|
        unless(pkg_info[key])
          raise ArgumentError.new("Missing required information for meta package: #{key}")
        end
      end
      fpm_tng_package meta_name do
        output_type 'deb'
        description "Meta package #{meta_name}"
        version pkg_info[:version]
        chdir '/tmp/meta-dir'
        depends Array(pkg_info[:dependencies])
        repository node[:pkg_build][:repository]
        reprepro node[:pkg_build][:reprepro]
      end
    end
  end
end
