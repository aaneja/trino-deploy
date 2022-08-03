#!/bin/bash

### Seed script to automate complete deployment on EC2 for Trino

set -e

tempDir="/tmp/trino-deploy"

# Install Java 17
echo "Installing Azul JDK"
wget -q https://cdn.azul.com/zulu/bin/zulu17.36.13-ca-jdk17.0.4-linux.x86_64.rpm -O /tmp/zulu17.rpm
sudo yum install -y /tmp/zulu17.rpm


#Fetch the 'main' version of deployer from Github
rm -rf "$tempDir" #Delete if still exists
mkdir -p "$tempDir"

wget https://github.com/aaneja/trino-deploy/tarball/main -O "/tmp/deployer.tar.gz"
tar --extract --strip-components=1 -f "/tmp/deployer.tar.gz"  -C "$tempDir"

cd "$tempDir"

#Get Trino tarball
trinoInstallDir='/home/ec2-user/trino'
./fetch.sh --installDir "$trinoInstallDir" --downloadUri 'https://repo1.maven.org/maven2/io/trino/trino-server/391/trino-server-391.tar.gz'

# Configure templates
if [ -f "/home/ec2-user/isCoordinator" ]; then
    ./configure.sh --isCoordinator 'true' --trinoInstallDir "$trinoInstallDir" 
else 
    ./configure.sh --isCoordinator 'false' --trinoInstallDir "$trinoInstallDir" 
fi

#Start Trino
./launcher.sh  --trinoInstallDir "$trinoInstallDir"  --operation 'start'



