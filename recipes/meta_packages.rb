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
      node[:pkg_build][:meta_mappings].keys.map do |pkg_name|
        File.exists?(File.join(node[:fpm_tng][:package_dir], "#{pkg_name}-1.0.0.deb")) ? nil : pkg_name
      end.compact.empty?
    end
  end
else
  include_recipe 'pkg-build::deps'

  directory '/tmp/meta-dir'
  
  node[:pkg_build][:meta_mappings].each do |meta_name, dependencies|
    fpm_tng_package meta_name do
      output_type 'deb'
      description "Meta package #{meta_name}"
      chdir '/tmp/meta-dir'
      depends Array(dependencies)
      repository node[:pkg_build][:repository]
      reprepro node[:pkg_build][:reprepro]
    end
  end
end
