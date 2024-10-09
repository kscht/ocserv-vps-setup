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

Отредактируйте значения конфигурационных опций в файле settings.env

DOMAIN = example.domain
E_MAIL = youremail@example.com
SECRET = secret_key

```
nano settings.env
```

Настройте получение и обновление SSL сертификатов от Let's Encrypt

```bash
make cert
```

Собертите образ контейнера

```bash
make build
```

Запустите контейнер с VPN сервером

```bash
make run
```

Отредактируйте базу пользователей

```bash
make config
```

