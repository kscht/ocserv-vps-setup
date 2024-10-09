# ocserv-vps-setup

Используйте Cisco AnyConnect или OpenConnect VPN:
https://ваш_домен/?secret_key


```bash
git clone --recurse-submodules  https://github.com/kscht/ocserv-vps-setup.git
cd ocserv-vps-setup
./system_update.sh
./prebuild_setup.sh
cp settings.example settings.env
```

Отредактируй  значения конфигурационных опций в файле settings.env

DOMAIN = example.domain
E_MAIL = youremail@example.com
SECRET = secret_key


```
nano settings.env
```


```bash
make cert
```

```bash
make build
```

```bash
make run
```

```bash
make config
```