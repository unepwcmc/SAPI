#/usr/bin/env bash
# Usage ./docker_config/list_system_dependencies.sh development runtime

##
# Tag dependencies with one or more of the following
#
# @common/base
# @common/build
# @common/runtime
# @develop/base
# @develop/build
# @develop/runtime
# @production/base
# @production/build
# @production/runtime

container_stage="${1:-production}"
container_step=${2:-base}

cat <<EOF | { grep -vE "^ *#" || test $? = 1; } | { grep -E "@$container_stage/$container_step" || test $? = 1; } | { cut -d@ -f1 || test $? = 130; };
#                         Needed to install Node.js from official distribution
#                         archives.
curl                      @common/base
ca-certificates           @common/base
xz-utils                  @common/base
gnupg                     @common/base

#                         Needed by psych native extension (yaml.h) when
#                         bundling on slim images.
libyaml-dev               @common/base

#                         Use jemalloc for long-running Rails/Sidekiq processes
#                         to reduce allocator fragmentation and lower RSS during
#                         memory-heavy jobs such as questionnaire publish loop
#                         expansion.
libjemalloc2              @common/base

#                         Needed for variout library building activities
build-essential           @common/base
pkg-config                @common/base

#                         Do not install Postgres libraries from Debian; use a
#                         specific version:
# postgresql-client         @common/base
# libpq                     @common/base
#                         Do not install Node.js from Debian; use a specific
#                         version:
# nodejs                    @common/base

#                         Install libvips for Active Storage preview support
libvips                   @common/base

#                         Zip for exports
zip                       @common/base

#                         various others
libsodium-dev             @common/base
libgmp3-dev               @common/base
libssl-dev                @common/base

#                         TeX is used for the generation of CITES Checklist PDFs.
texlive-latex-base        @common/runtime
texlive-fonts-recommended @common/runtime
texlive-fonts-extra       @common/runtime
texlive-latex-extra       @common/runtime

#                         Dependencies for building Rails
git                       @common/build
pkg-config                @common/build

#                         socat is just for binding ports within docker, not
#                         needed for the application
socat                     @dev/runtime

EOF
