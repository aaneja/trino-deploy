#!/bin/bash
set -e

installDir=${installDir:-"/home/ec2-user/trino"}
downloadUri=${downloadUri:-'https://repo1.maven.org/maven2/io/trino/trino-server/391/trino-server-391.tar.gz'}
#Presto : https://repo1.maven.org/maven2/com/facebook/presto/presto-server/0.275/presto-server-0.275.tar.gz

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

echo "Fetching tarball"
wget -q "$downloadUri" -O "/tmp/binary.tar.gz"

echo "Extracting to $installDir"

#Strip components to get rid of top level directory (default in Trino/Presto)
tar --extract --strip-components=1 -f "/tmp/binary.tar.gz"  -C "$installDir"

#Cleanup
rm  -f "/tmp/binary.tar.gz"

echo "Done"


