# Trino/Presto helpers
This repo contains a set of scripts that are helpful in generating and deploying Trino/Presto configurations from a set of templates.
These can be used to seed a host with binaries+config (both coordinators and workers), change existing configs, relaunch JVMs etc.

The scripts themselves are agnostic to *how* they are run. See [reference below on how to run scripts parallely on hosts](#parallel-scipt-execution-on-multiple-nodes)


## Example Usage
### Generate configs from templates for a coordinator node
```
./configure.sh --isCoordinator 'true' --trinoInstallDir '/home/ec2-user/trino'
```

### Generate configs from templates for a worker node
```
./configure.sh --isCoordinator 'true' --trinoInstallDir '/home/ec2-user/trino'
```

### Fetch a tarball and extract to an install directory
```
./fetch.sh --installDir '/tmp/trino-server' --downloadUri 'https://repo1.maven.org/maven2/io/trino/trino-server/391/trino-server-391.tar.gz'
```

### Start Trino using it's launcher script
```
./launcher.sh  --trinoInstallDir '/home/ec2-user/trino' --operation 'start'
```


## Parallel scipt execution on multiple nodes

1. On EC2 you can use [AWS Systems Manager : Run Command](https://docs.aws.amazon.com/systems-manager/latest/userguide/walkthrough-cli.html#walkthrough-cli-run-scripts). An example for seeding nodes with Trino : 
```
 aws ssm send-command \
--document-name "AWS-RunShellScript" \
--document-version "1" \
--targets '[{"Key":"tag:Name","Values":["WORKER","COORDINATOR"]}]' \
--parameters '{"workingDirectory":[""],"executionTimeout":["3600"],"commands":["curl -L https://raw.githubusercontent.com/aaneja/trino-deploy/main/trino_ec2_seed.sh |  bash"]}' \
--timeout-seconds 600 \
--max-concurrency "50" \
--max-errors "0" \
--region us-west-2
```

1. [pssh](https://github.com/lilydjwg/pssh)
1. [Parallel-SSH](https://github.com/ParallelSSH/parallel-ssh)


