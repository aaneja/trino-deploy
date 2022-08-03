#!/bin/bash

### Seed script to automate complete deployment on EC2 for Trino

set -e

installDir=${installDir:-"/tmp/trino-deploy"}

# Install Java 17

echo "Installing Azul JDK"
wget -q https://cdn.azul.com/zulu/bin/zulu17.36.13-ca-jdk17.0.4-linux.x86_64.rpm -O /tmp/zulu17.rpm
sudo yum install -y /tmp/zulu17.rpm

#Read in cmd line params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

mkdir -p "$installDir"

wget https://github.com/aaneja/trino-deploy/tarball/main -O "/tmp/deployer.tar.gz"
tar --extract --strip-components=1 -f "/tmp/deployer.tar.gz"  -C "$installDir"

cd "$installDir"

trinoInstallDir='/home/ec2-user/trino'

./fetch.sh
if [ -f "/home/ec2-user/isCoordinator" ]; then
    ./configure.sh --isCoordinator 'true' --trinoInstallDir "$trinoInstallDir" 
else 
    ./configure.sh --isCoordinator 'false' --trinoInstallDir "$trinoInstallDir" 
fi
./launcher.sh  --trinoInstallDir "$trinoInstallDir"  --operation 'start'



