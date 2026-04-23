set -ue;
node_version="${NODE_VERSION:-$1}"
target_arch="${TARGETARCH:-${2:-$(uname -m)}}"

case $target_arch \
  in \
    amd64) node_arch=x64 ;; \
    x86_64) node_arch=x64 ;; \
    arm64) node_arch=arm64 ;; \
    *) echo "Unsupported architecture: '$target_arch'"; exit 1 ;; \
  esac \
  && echo https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-$node_arch.tar.xz
  # && curl -fsSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-$node_arch.tar.xz \
  #  | tar -xJ -C /usr/local --strip-components=1
