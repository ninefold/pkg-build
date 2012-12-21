include_recipe 'pkg-build::deps'

sphinx_name = "sphinx-#{node[:pkg_build][:sphinx][:version]}"

builder_remote sphinx_name do
  remote_file "http://sphinxsearch.com/files/sphinx-#{node[:pkg_build][:sphinx][:version]}-release.tar.gz"
  suffix_cwd "sphinx-#{node[:sphinx][:version]}-release"
  depends %w(libc libexpat1 libgcc1 libmysqlclient18 libpq5 libstdc++6 libstemmer0d zlib1g)
  commands [
    './configure --prefix=/usr/local',
    'make'
    'make install DISTDIR=$PKG_DIR'
  ]
  # creates 
end

fpm_tng_package 'sphinxsearch' do
  output_type 'deb'
  description 'Sphinx search'
  version node[:sphinx][:version]
  chdir File.join(node[:builder][:packaging_dir], sphinx_name)
  reprepro node[:pkg_build][:reprepro]
end
