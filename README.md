# Setup for mac by ansible

### Install homebrew and ansible

```sh
sh setup.sh
```

### Dryrun ansible

```sh
ansible-playbook -i ansible/hosts ansible/mac.yml -K -C
```

### Execute ansible

```sh
ansible-playbook -i ansible/hosts ansible/mac.yml -K
```

### Execute ansible specific task

```sh
ansible-playbook -i ansible/hosts ansible/mac.yml --start-at='Change shell to zsh' -K
```

### Execute ansible specific tags

```sh
ansible-playbook -i ansible/hosts ansiblle/mac.yml --tags gem -K
```
