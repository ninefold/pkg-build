default[:pkg_build][:ruby][:uri_base] = 'http://ftp.ruby-lang.org/pub/ruby/'
default[:pkg_build][:ruby][:versions] = []
default[:pkg_build][:ruby][:version] = '2.1.0'
default[:pkg_build][:ruby][:patchlevel] = ''
default[:pkg_build][:ruby][:install_prefix] = '/usr/local'
default[:pkg_build][:ruby][:rubygems][:version] = 'latest' # or set to rubygems version
default[:pkg_build][:ruby][:suffix_version] = false
default[:pkg_build][:ruby][:package_dependencies] = %w(
  openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev
  libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev
  autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config
)
default[:pkg_build][:ruby][:install_dependencies] = %w(
  ca-certificates libc6 libffi6 libgdbm3 libncursesw5 libreadline6 libssl1.0.0
  libtinfo5 libyaml-0-2 zlib1g
)
default[:pkg_build][:ruby][:extra_configure_args] = []
