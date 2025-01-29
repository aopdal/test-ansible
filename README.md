# test-ansible

This is for easy testing Ansible with inventory in NexBox

You need to have a existing NetBox

This is testet with Python 3.10, 3.12 and 3.13

You need to have python3-venv installed.

Do the following:

``` sh
git clone https://github.com/aopdal/test-ansible.git
cd test-ansible
./upgrade.sh
```

create an .env file with:

``` sh
export NETBOX_API=https://xxx
export NETBOX_TOKEN=xx
```

run:

``` sh
source venv/bin/activate
sourve .env
ansible-inventory -i nb_env.yml --list
```
