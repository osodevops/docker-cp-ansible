# geektechstuff
# using a lot of https://hub.docker.com/r/philm/ansible_playbook/dockerfile/

# Alpine is a lightweight version of Linux.
# apline:latest could also be used
FROM alpine:3.16

RUN apk --no-cache add \
        sudo \
        python3\
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        openssl-dev \
        libressl-dev \
        build-base && \
    pip3 install --upgrade pip wheel && \
    pip3 install --upgrade cryptography cffi && \
    pip3 install ansible-core==2.13 && \
    pip3 install mitogen jmespath && \
    pip3 install --upgrade pywinrm && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

# Makes the Ansible directories
RUN mkdir /etc/ansible /ansible
RUN mkdir ~/.ssh

# Over rides SSH Hosts Checking
RUN echo "host *" >> ~/.ssh/config &&\
    echo "StrictHostKeyChecking no" >> ~/.ssh/config

# Makes a directory for ansible playbooks
RUN mkdir -p /ansible/ansible_collections/confluent/platform

# Makes the playbooks directory the working directory
WORKDIR /ansible/ansible_collections/confluent/platform

# Sets environment variables
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING False
ENV ANSIBLE_RETRY_FILES_ENABLED False
ENV ANSIBLE_COLLECTIONS_PATH /ansible/ansible_collections
ENV ANSIBLE_SSH_PIPELINING True
ENV PATH /ansible/bin:$PATH
ENV PYTHONPATH /ansible/lib
ENV ANSIBLE_INVENTORY /ansible/ansible_collections/confluent/platform/inventories/ansible-inventory.yml

RUN git clone https://github.com/confluentinc/cp-ansible.git
RUN rm -rf /ansible/ansible_collections/confluent/platform/cp-ansible/.git
RUN mv /ansible/ansible_collections/confluent/platform/cp-ansible/* /ansible/ansible_collections/confluent/platform/
RUN mkdir -p /ansible/ansible_collections/confluent/platform/inventories
COPY entrypoint.sh /ansible/ansible_collections/confluent/platform/entrypoint.sh

WORKDIR /ansible/ansible_collections/confluent/platform/

# Install Confluent required Ansible modules :: God knows why they have used this one!!!
RUN ansible-galaxy collection install ansible.posix

# Sets entry point (same as running ansible-playbook)
CMD ["sh", "/ansible/ansible_collections/confluent/platform/entrypoint.sh"]