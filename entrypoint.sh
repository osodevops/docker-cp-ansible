#!/bin/bash
cp /root/staging/id_rsa /root/.ssh
cp /root/staging/ansible-inventory.yml /ansible/ansible_collections/confluent/platform/inventories
chmod 400 /root/.ssh/id_rsa
/usr/bin/ansible-playbook -i /ansible/ansible_collections/confluent/platform/inventories/ansible-inventory.yml confluent.platform.all