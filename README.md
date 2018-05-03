# Setup for mac by ansible

Install homebrew and ansible

```sh
sh init.sh
```

Dryrun playbook 

```sh
ansible-playbook -i playbook/hosts playbook/mac.yml --check
```

Execute playbook

```sh
ansible-playbook -i playbook/hosts playbook/mac.yml
```
