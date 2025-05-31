#!/usr/bin/env bash
# run-ansible.sh - Execute Ansible playbook
set -e

echo "Running Ansible playbook..."
cd ../ansible && ansible-playbook playbooks/serve_config.yml