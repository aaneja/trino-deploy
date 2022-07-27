#!/bin/bash
set -e

trinoInstallDir=${trinoInstallDir:-"/home/ec2-user/trino"}
operation=${operation:-"status"}


#Read in cmd line params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

cd "$trinoInstallDir/bin"

echo "Execution 'launcher $operation'"

./launcher -v "$operation"

echo "Done"


