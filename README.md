## Trino Deploy script
Simple bash script to take a set of config templates to deploy on an existing Trino installation
Requires 
1. Trino directory passed in as the `--trinoInstallDir` parameter
1. [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) to be present on PATH

### Usage examples
Start a coordinator node with coordinator as worker:
```
./configure.sh --isCoordinator 'true' --trinoInstallDir '/home/anant/temp/trino-test/trino-server-391' --coordinatorIsWorker 'true'
```