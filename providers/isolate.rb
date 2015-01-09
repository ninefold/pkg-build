action :build do

  run_context.include_recipe 'lxc'

  dna_json = ::File.join(node[:pkg_build][:isolate_solo_dir], "#{rand(99999999)}-solo-dna.json")

  directory ::File.dirname(dna_json) do
    recursive true
  end
  
  file dna_json do
    mode 0644
    content JSON.pretty_generate(
      Mixin::DeepMerge.merge({
          :pkg_build => {
            :pkg_prefix => node[:pkg_build][:pkg_prefix],
            :reprepro => false,
            :isolate => false,
            :replace_deprecated => node[:pkg_build][:replace_deprecated],
            :vendor => node[:pkg_build][:vendor],
            :maintainer => node[:pkg_build][:maintainer]
          },
          :fpm_tng => {
            :vendor => node[:pkg_build][:vendor],
            :maintainer => node[:pkg_build][:maintainer]
          },
          :run_list => ['recipe[apt]'] + new_resource.run_list
        }, new_resource.attributes
      )
    )
  end

  Chef::Log.info("Ruby node: " + node[:languages][:ruby].to_json)

  log "Isolated lxc/chef build about to start for #{new_resource.name}. Chef logs will appear once complete."

  lxc_ephemeral "Isolated: #{new_resource.name}" do
    command "chef-solo -l #{Chef::Config[:log_level].to_s} -j #{dna_json}"
    base_container new_resource.container
  end
end
