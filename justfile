default:
  @just --list

version_dirty := `[ -z "$(git status -s)" ] || echo "-$(date +"%H%M%S")"`
version := `git describe --tags --dirty --always` + version_dirty

tinyproxy_version := "1.11.2"

version:
  @echo "Using version {{version}} with tinyproxy version {{tinyproxy_version}}"

download:
 curl -L --remote-name https://github.com/tinyproxy/tinyproxy/releases/download/{{tinyproxy_version}}/tinyproxy-{{tinyproxy_version}}.tar.xz

uncompress:
  mkdir workdir
  tar --strip-components=1 -C workdir -xaf tinyproxy-{{tinyproxy_version}}.tar.xz

[working-directory: 'workdir']
compile:
  ./autogen.sh
  ./configure LDFLAGS="-static" --enable-manpage_support=no
  make

[working-directory: 'workdir/src/']
push: && version
  oras push ghcr.io/githedgehog/fabricator/control-proxy:{{version}} tinyproxy

[working-directory: 'workdir/src/']
local-push: && version
  oras push --plain-http 127.0.0.1:30000/githedgehog/fabricator/control-proxy:{{version}} tinyproxy

