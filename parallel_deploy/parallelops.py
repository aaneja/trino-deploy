import json
from argparse import ArgumentParser

from gevent import joinall, Timeout
from pssh.clients import ParallelSSHClient
from pssh.config import HostConfig


def build_hosts(hosts_file: str):
    # read hosts.json file and builds the list of hosts to be used in the deployment
    with open(hosts_file) as f:
        data = json.load(f)
        hosts_map = data['hosts_map']
        host_aliases = list(hosts_map.keys())
        host_names = list(hosts_map.values())
        common_private_key = bytes(data['common_props']['private_key'], 'utf-8')
        common_user = data['common_props']['user']
        host_configs = [HostConfig(user=common_user, private_key=common_private_key)] * len(host_names)
        return host_aliases, host_names, host_configs


def copy_to_remote(client: ParallelSSHClient, src: str, dest: str):
    # copies the src file to the dest file on the remote host
    cmds = client.copy_file(src, dest, recurse=True)
    joinall(cmds, raise_error=True)


def run_remote_cmd(client: ParallelSSHClient, cmd: str):
    # runs the cmd on the remote host, with a 5min timeout
    output = client.run_command(cmd, read_timeout=300, use_pty=True)
    for host_out in output:
        try:
            for line in host_out.stdout:
                print(line)
            for line in host_out.stderr:
                print(line)
        except Timeout:
            pass


def get_parser() -> ArgumentParser:
    # Parse arguments
    import argparse
    parser = argparse.ArgumentParser(description='Deploys the application to the remote hosts')
    parser.add_argument('-f', '--hosts', help='The file containing the hosts to be deployed', required=False)
    subparsers = parser.add_subparsers(help='sub-command help', dest='command')
    subparsers.required = True
    copy_to_remote_parser = subparsers.add_parser('copy_to_remote', help='copy_to_remote help')
    copy_to_remote_parser.add_argument('src', help='The source file to be copied', type=str)
    copy_to_remote_parser.add_argument('dest', help='The destination file to be copied to', type=str)
    run_remote_cmd_parser = subparsers.add_parser('run_remote_cmd', help='run_remote_cmd help')
    run_remote_cmd_parser.add_argument('cmd', help='The command to run on the remote host', type=str)
    return parser


def main():
    parser = get_parser()
    args = parser.parse_args()
    hosts_file = args.hosts if args.hosts else 'hosts.json'
    host_aliases, host_names, host_configs = build_hosts(hosts_file)
    client = ParallelSSHClient(host_names, host_config=host_configs)
    match args.command:
        case 'copy_to_remote':
            copy_to_remote(client, args.src, args.dest)
        case 'run_remote_cmd':
            run_remote_cmd(client, args.cmd)
        case _:
            parser.print_help()
            exit(1)
    exit(0)


if __name__ == '__main__':
    main()

# Examples
# output = run_remote_cmd(client, 'uname -a')
# copy_to_remote(client, '/home/anant/Work/oss/aaneja/trino-deploy/parallel_deploy/hosts.json', '/tmp/hosts.json')
