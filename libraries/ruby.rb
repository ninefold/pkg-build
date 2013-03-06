module PkgBuild
  module Ruby
    class << self
      def ruby_name(node, version)
        name = [node[:pkg_build][:pkg_prefix]]
        if(node[:pkg_build][:ruby][:suffix_version])
          name << "ruby#{version}"
        else
          name << 'ruby'
        end
        name.compact.join('-')
      end

      def ruby_build(node, version, patchlevel)
        patch = patchlevel.to_s.start_with?('p') ? patchlevel : "p#{patchlevel}"
        "#{ruby_name(node, version)}-#{version}-#{patch}"
      end
    end
  end
end
