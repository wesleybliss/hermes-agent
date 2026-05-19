
alias hermes-upgrade='./bin/upgrade.sh'
alias hermes-restart='(cd /root/docker && dcr -d)'
alias hermes-bash='podman exec -it hermes bash'
alias hermes-logs='podman logs -f hermes'
alias hermes-commit='./bin/create-commit.sh'
alias hermes-list-commits='podman images hermes-backup --format "{{.Repository}}:{{.Tag}} \t(Created: {{.Created}})"'
alias hermes-restore-commit='./bin/restore-commit'
