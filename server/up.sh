#!/bin/bash
set -e

# Note that the --host is needed for IPv4 and IPv6 addresses

# On starting up this will generate log message
#    `/home/singler` is not a directory.
#    Bundler will use `/tmp/bundler/home/unknown' ...
# This is because I am using a readonly file system
# with the only writable areas being tmp and the volume-mount.

bundle exec rackup \
  --warn \
  --host 0.0.0.0 \
  --port 4517 \
  --server thin \
  --env production \
    config.ru
