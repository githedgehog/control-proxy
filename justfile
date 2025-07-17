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

push: && version
  oras push ghcr.io/githedgehog/fabricator/control-proxy:{{version}} tinyproxy


