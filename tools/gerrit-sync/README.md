# Sync gerrits

Required: connection from root on prod to root on dev.

` $ ansible-playbook -i inventory site.yml -e "gerrit_user=<your_gerrit_user>"`
