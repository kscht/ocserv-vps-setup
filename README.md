# ocserv-vps-setup

Используйте Cisco AnyConnect или OpenConnect VPN:
https://ваш_домен/?secret_key

Для настройки сервера необходима VPS с Ubuntu 22.x или 20.x, а также доменное имя любого уровня, указывающее на IP-адрес VPS.

Выполните эти инструкции, чтобы подготовить VPS к дальнейшей настройке

```bash
git clone https://github.com/kscht/ocserv-vps-setup.git
cd ocserv-vps-setup
./system_update.sh
./prebuild_setup.sh
cp settings.example settings.env
```

Отредактируйте значения конфигурационных опций в файле settings.env

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

