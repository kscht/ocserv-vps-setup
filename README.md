# ocserv-vps-setup

Используйте Cisco AnyConnect или OpenConnect VPN:
https://ваш_домен/?secret_key


```bash
git clone --recurse-submodules  https://github.com/kscht/ocserv-vps-setup.git
cd ocserv-vps-setup
./init.sh
cp settings.example settings.env
```

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