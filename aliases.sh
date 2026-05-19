
alias hermes-restart='(cd /root/docker && dcr -d)'
alias hermes-bash='podman exec -it hermes bash'
alias hermes-logs='podman logs -f hermes'
alias hermes-checkpoint='./bin/create-checkpoint.sh'
alias hermes-list-checkpoints='ls -alh /root/checkpoints'
alias hermes-restore-checkpoint='./bin/restore-checkpoint'
