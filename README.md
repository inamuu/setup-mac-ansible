# Setup for mac by ansible

### Install homebrew and ansible

```sh
sh init.sh
```

### Dryrun ansible

```sh
ansible-playbook -i ansible/hosts ansible/mac.yml --check --ask-become-pass
```

### Execute ansible

```sh
ansible-playbook -i ansible/hosts ansible/mac.yml --ask-become-pass
```

### Execute ansible specific task

```sh
ansible-playbook -i ansible/hosts ansible/mac.yml --start-at='Change shell to zsh' --ask-become-pass
```
