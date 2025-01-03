SHELL := /bin/bash
MAKEFLAGS += --silent
ARGS = $(filter-out $@,$(MAKECMDGOALS))
UNAME=$(shell uname -s)

export COMPOSE_PROJECT_NAME=php-docker-boilerplate
export COMPOSER_CACHE=$$(composer config --no-interaction --global cache-dir || echo $$HOME/.cache/composer)

docker-compose=COMPOSER_CACHE=${COMPOSER_CACHE} YARN_CACHE=${YARN_CACHE} NPM_CACHE=${NPM_CACHE} docker-compose

.PHONY: help

help: ## Show available Commands
	@awk 'BEGIN {FS = ":.*##"; printf "\033[33mUsage:\033[0m \n make \033[32m<target>\033[0m \033[32m\"<arguments>\"\033[0m\n\n\033[33mAvailable commands:\033[0m \n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[32m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

banner:
	./shell/.banner.sh

##@ Docker commands
up: ## Start Project
	@make banner
	$(docker-compose) up -d --remove-orphans --force-recreate
	@make urls

down: ## Stop and remove containers, networks, volumes and images
	@make stop
	$(docker-compose) down

stop: ## Stop Project
	$(docker-compose) stop

restart: ## Restart all containers
	$(docker-compose) kill $(ARGS)
	@make up

rebuild: ## Rebuild the app container
	$(docker-compose) rm --force application
	@make build
	@make up

build:
	$(docker-compose) build

state:
	$(docker-compose) ps

logs: ## Get logs from all containers or a specific container e.g make logs frontend
	$(docker-compose) logs -f --tail=100 $(ARGS)

destroy: ## Stop Project
	$(docker-compose) down --rmi all -v

create-certificate:
	openssl genrsa -out cert/key.pem 2048
	openssl req -new -sha256 -key cert/key.pem -out cert/csr.csr
	openssl req -x509 -sha256 -days 365 -key cert/key.pem -in cert/csr.csr -out cert/certificate.pem
	openssl req -in cert/csr.csr -text -noout | grep -i "Signature.*SHA256" && echo "All is well" || echo "This certificate will stop working in 2025! You must update OpenSSL to generate a widely-compatible certificate"

##@ System commands
composer: ## Run composer in the container e.g make composer 'require monolog/monolog'
	$(docker-compose) exec -unobody application composer $(ARGS)

shell: ## Get Bash of app container
	$(docker-compose) exec -unobody application bash

bash: shell

root: ## Get root Bash of app container
	$(docker-compose) exec application bash

## Print Project URIs
urls:
	echo "---------------------------------------------------"
	echo "You can access your project at the following URLS:"
	echo "---------------------------------------------------"
	echo ""
	echo "Application: http://"${COMPOSE_PROJECT_NAME}".docker/"
	echo ""
	echo "---------------------------------------------------"
	echo ""

##@ Mysql commands
mysql-backup: ## Backup MySQL
	bash ./shell/backup.sh mysql

mysql-restore: ## Restore MySQL
	bash ./shell/restore.sh mysql

#############################
# Argument fix workaround
#############################
%:
	@:
