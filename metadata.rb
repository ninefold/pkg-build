name 'pkg-build'
maintainer 'Heavy Water'
maintainer_email 'support@hw-ops.com'
description 'Recipes for building packages'

version '0.1.9'

supports 'ubuntu'

depends 'builder'
depends 'fpm-tng', '~> 0.1.3'
depends 'reprepro', '~> 0.3.0'
depends 'apt', '>= 1.8.2'
depends 'ohai'
depends 'discovery', '>= 0.2.0'
