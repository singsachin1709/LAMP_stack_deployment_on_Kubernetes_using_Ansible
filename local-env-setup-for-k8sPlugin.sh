
# Install community.docker collection
ansible-galaxy collection install community.docker

# make sure Docker SDK is also installed:
# This ensures Python can interact with Docker on the host.
pip3 install docker


# Install Kubernetes-related Python packages
pip3 install openshift pyyaml kubernetes

# Install Ansible k8s plugin
ansible-galaxy collection install kubernetes.core


