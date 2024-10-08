# Чтение настроек из внешнего файла
include settings.env

help:
	@echo "Доступные команды:"
	@echo "  build  - Сборка Docker образа."
	@echo "  run    - Запуск контейнера."
	@echo "  stop   - Остановка контейнера."
	@echo "  clean  - Удаление Docker образа."
	@echo "  help   - Вывод этой справки."

cert:
	@echo "Получение сертификата для домена $(DOMAIN), оповещения на $(E_MAIL)."
	sudo certbot certonly --standalone --preferred-challenges http -d $(DOMAIN) \
	--non-interactive --agree-tos --email $(E_MAIL)

build:
	cd docker-ocserv && cp Dockerfile Dockerfile.tmp && \
	sed -i '/&& \.\/configure \\/ s/&& \.\/configure /&--without-gnutls /' Dockerfile.tmp
	cd docker-ocserv && sudo docker build -f Dockerfile.tmp -t $(IMAGE_NAME) . && \
	rm Dockerfile.tmp
run:
	@echo "Запуск контейнера $(CONTAINER_NAME) из образа $(IMAGE_NAME)."
	sudo docker run --name $(CONTAINER_NAME) \
		--sysctl net.ipv4.ip_forward=1 \
		--cap-add NET_ADMIN \
		--security-opt no-new-privileges \
		-p 443:443 \
		-p 443:443/udp \
		-v /etc/letsencrypt/live/$(DOMAIN)/privkey.pem:/etc/ocserv/certs/server-key.pem \
		-v /etc/letsencrypt/live/$(DOMAIN)/cert.pem:/etc/ocserv/certs/server-cert.pem \
		-d $(IMAGE_NAME)

init:
	docker exec ocserv sed -i '/^camouflage = /{s/false/true/}' /etc/ocserv/ocserv.conf
	docker exec ocserv sed -i '/^default-domain = /{s/example.com/$(DOMAIN)/}' /etc/ocserv/ocserv.conf
	docker exec ocserv sed -i '/^camouflage_secret = /{s/mysecretkey/$(SECRET)/}' /etc/ocserv/ocserv.conf
	docker exec ocserv sed -i '/^keepalive = /{s/32400/0/}' /etc/ocserv/ocserv.conf

stop:
	@echo "Остановка контейнера $(CONTAINER_NAME)."
	sudo docker stop $(CONTAINER_NAME)

start:
	@echo "Запуск контейнера $(CONTAINER_NAME)."
	sudo docker start $(CONTAINER_NAME)

purge:
	@echo "Удаление образа $(IMAGE_NAME)."
	sudo docker rmi $(CONTAINER_NAME)

