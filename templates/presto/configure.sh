#!/bin/bash
set -exuo

templatesDir=${templatesDir:-"."}
isCoordinator=${isCoordinator:-false}
installDir=${installDir:-"/home/ec2-user/software"}
coordinatorIsWorker=${coordinatorIsWorker:-"false"}

#Read in cmd line params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TEMPLATES_DIR="$templatesDir"

#Create and do initial copy to OUT_DIR
OUT_DIR="$SCRIPT_DIR/out"
mkdir -p "$OUT_DIR"
cp -R "$TEMPLATES_DIR/." "$OUT_DIR"

#Setup vars to substitute
ETC_DIR="$TEMPLATES_DIR/etc"
#Note : NodeID for a worker is setup randomly. On cloud envs, using some sort of instanceId is recommended
NODE_ID=$([ "$isCoordinator" == "true" ] && echo "coordinator" || echo "worker-$RANDOM")
export NODE_ID 
export DATA_DIR="$installDir/data"
export IS_COORDINATOR="$isCoordinator"
export COORDINATOR_IS_WORKER="$coordinatorIsWorker"

totalramkb=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
jvmXmx=$(($totalramkb*1024*90/100)) #90% of total ram
export JVM_XMX="$jvmXmx"

#Special care needed for below coordinator only properties
if [ "$isCoordinator" == "true" ]; then
    export DISCOVERY_SERVER_ENABLED="discovery-server.enabled=true"
else
    #Can't output this property key at all for workers
    export DISCOVERY_SERVER_ENABLED=""
fi

#Create dirs needed
mkdir -p "$DATA_DIR"

#Substitute vars
envsubst < "$ETC_DIR"/node.properties > "$OUT_DIR"/etc/node.properties
envsubst < "$ETC_DIR"/config.properties > "$OUT_DIR"/etc/config.properties
envsubst < "$ETC_DIR"/jvm.config > "$OUT_DIR"/etc/jvm.config

#Copy the out dir to install location
cp -Rf "$OUT_DIR/." "$installDir/"
