#!/bin/bash

mkdir -p /var/lib/ceph/radosgw/`hostname -s`

echo "---> Start Honcho"
/usr/local/bin/honcho $*