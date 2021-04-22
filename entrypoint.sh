#!/bin/bash
cp /root/staging/id_rsa /root/.ssh
cp /root/staging/ansible-inventory.yml /ansible/playbooks/cp-ansible/inventories
chmod 400 /root/.ssh/id_rsa
/ansible/bin/ansible-playbook /ansible/playbooks/cp-ansible/all.yml