# Чтение настроек из внешнего файла
include settings.env

help:
	@echo "Доступные команды:"
	@echo "  cert    - Получение SSL сертификатов."
	@echo "  build   - Сборка Docker образа."
	@echo "  run     - Инициализация контейнера."
	@echo "  config  - Редактирование списка пользователей."
	@echo "  stop    - Остановка контейнера."
	@echo "  start   - Запуск контейнера."
	@echo "  backup  - Скопировать базу пользователей."
	@echo "  restore - Восстановить базу пользователей."
	@echo "  purge   - Удаление Docker образа."
	@echo "  help    - Вывод этой справки."


cert:
	@echo "Получение сертификата для домена $(DOMAIN), оповещения на $(E_MAIL)."
	sudo certbot certonly --standalone --preferred-challenges http -d $(DOMAIN) \
	--non-interactive --agree-tos --email $(E_MAIL)

build:
	cd docker-ocserv && cp Dockerfile Dockerfile.tmp && \
	sed -i '/&& \.\/configure \\/ s/&& \.\/configure /&--without-gnutls /' Dockerfile.tmp
	cd docker-ocserv && sudo docker build -f Dockerfile.tmp -t $(IMAGE_NAME) . && \
	rm Dockerfile.tmp

run:	build	
	@echo "Запуск контейнера $(CONTAINER_NAME) из образа $(IMAGE_NAME)."
	sudo docker run --name $(CONTAINER_NAME) \
		--sysctl net.ipv4.ip_forward=1 \
		--cap-add NET_ADMIN \
		--security-opt no-new-privileges \
		-p 443:443 \
		-v /etc/letsencrypt/live/$(DOMAIN)/privkey.pem:/etc/ocserv/certs/server-key.pem \
		-v /etc/letsencrypt/live/$(DOMAIN)/cert.pem:/etc/ocserv/certs/server-cert.pem \
		-d $(IMAGE_NAME)
	sudo docker exec $(CONTAINER_NAME) sed -i '/^camouflage = /{s/false/true/}' /etc/ocserv/ocserv.conf
	sudo docker exec $(CONTAINER_NAME) sed -i '/^default-domain = /{s/example.com/$(DOMAIN)/}' /etc/ocserv/ocserv.conf
	sudo docker exec $(CONTAINER_NAME) sed -i '/^camouflage_secret = /{s/mysecretkey/$(SECRET)/}' /etc/ocserv/ocserv.conf
	sudo docker exec $(CONTAINER_NAME) sed -i '/^keepalive = /{s/32400/0/}' /etc/ocserv/ocserv.conf
	sudo docker exec $(CONTAINER_NAME) sed -i '/^tls-priorites=/c\tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-VERS-SSL3.0:-VERS-TLS1.0:-VERS-TLS1.1:+VERS-TLS1.2:+VERS-TLS1.3:+AES-256-GCM:+AES-128-GCM:+CHACHA20-POLY1305"' /etc/ocserv/ocserv.conf
	tr -dc A-Za-z0-9 </dev/urandom | head -c 12|sudo docker exec -i $(CONTAINER_NAME) ocpasswd -c /etc/ocserv/ocpasswd q

stop:
	@echo "Остановка контейнера $(CONTAINER_NAME)."
	sudo docker stop $(CONTAINER_NAME)

start:
	@echo "Запуск контейнера $(CONTAINER_NAME)."
	sudo docker start $(CONTAINER_NAME)
config:
	./user_config.sh

purge:  stop
	@echo "Удаление образа $(IMAGE_NAME)."
	sudo docker rm $(CONTAINER_NAME)
	sudo docker rmi $(CONTAINER_NAME)


backup:
	@read -p "Вы действительно хотите восстановить базу пользователей? (y/n): " CONFIRM; \
	if [ "$$CONFIRM" = "y" ]; then \
		echo "Копируем базу пользователей."; \
		sudo docker cp $(CONTAINER_NAME):/etc/ocserv/ocpasswd ./ocpasswd; \
	else \
		echo "Операция копирования отменена."; \
	fi


restore:
	@read -p "Вы действительно хотите восстановить базу пользователей? (y/n): " CONFIRM; \
	if [ "$$CONFIRM" = "y" ]; then \
		echo "Восстанавливаем базу пользователей."; \
		sudo docker cp ./ocpasswd $(CONTAINER_NAME):/etc/ocserv/ocpasswd; \
	else \
		echo "Операция восстановления отменена."; \
	fi
