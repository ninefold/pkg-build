node[:pkg_build][:meta_mappings].each do |meta_name, dependencies|
  fpm_tng_package meta_name do
    output_type 'deb'
    description "Meta package #{meta_name}"
    depends Array(dependencies)
    respository node[:pkg_build][:repository]
    reprepro node[:pkg_build][:reprepro]
  end
end
