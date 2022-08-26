#!/bin/bash

parallel_deploy="python parallel_deploy/parallelops.py -f parallel_deploy/hosts.json"

function pcopy {
 $parallel_deploy copy_to_remote "$@"
}
function prun {
 $parallel_deploy run_remote_cmd "$@"
}
#prun 'mkdir -p /home/ec2-user/software'
#prun 'tar --extract --strip-components=1 -f "/tmp/binary.tar.gz"  -C "/home/ec2-user/software/"'
#prun 'sudo yum install -y java-1.8.0-openjdk-devel || true'
#Copy templates
pcopy '/home/anant/Work/oss/aaneja/trino-deploy/templates/presto' '/tmp/templates'

prun 'bash -E /tmp/templates/configure.sh --templatesDir "/tmp/templates/template" --isCoordinator $([ -f "/home/ec2-user/isCoordinator" ] && echo true || echo false) --installDir "/home/ec2-user/software/"'
prun './software/bin/launcher -v status'