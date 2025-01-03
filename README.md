# PHP Docker Boilerplate

A lightweight and modular PHP boilerplate for seamless Docker-based development.

## Features
- **PHP Support**: Includes the latest stable PHP version with custom configuration.
- **Database Integration**: Pre-configured for MySQL/PostgreSQL support.
- **Web Server**: Nginx setup for handling requests.
- **Development Tools**: Xdebug, Composer, and other utilities pre-installed.
- **Modular Architecture**: Easily extendable for various project requirements.

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Prerequisites](#prerequisites)
3. [Usage](#usage)
4. [Environment Configuration](#environment-configuration)
5. [Services Overview](#services-overview)
6. [Development Workflow](#development-workflow)
7. [Troubleshooting](#troubleshooting)
8. [Contributing](#contributing)
9. [License](#license)

---

## Getting Started
Follow these instructions to set up the project on your local machine.

### Clone the Repository
```bash
git clone git@github.com:kevinkoerber95/php-docker-boilerplate.git
cd php-docker-boilerplate
make up
```

## Prerequisites
Ensure you have the following installed on your machine:

- Docker 
- Docker Compose (>= v2)
- Dnsmasq (optional)

### Setting up Dnsmasq on Mac

#### Create docker resolver file
```shell
mkdir /etc/resolver
echo "nameserver 127.0.0.1" >> /etc/resolver/docker
echo "port 19322" >> /etc/resolver/docker
```

#### Start dinghy http proxy
```shell
docker run -d --restart=always \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  -v ~/.dinghy/certs:/etc/nginx/certs \
  -p 80:80 -p 443:443 -p 19322:19322/udp \
  -e DNS_IP=127.0.0.1 -e CONTAINER_NAME=http-proxy \
  --name http-proxy \
  codekitchen/dinghy-http-proxy
```

#### Install dnsmasq

```shell
brew install dnsmasq
```

#### Configure dnsmasq
```shell
echo "listen-address=127.0.0.1" >> /opt/homebrew/etc/dnsmasq.conf
echo "address=/.docker/127.0.0.1" >> /opt/homebrew/etc/dnsmasq.conf 
```

### Starting dnsmasq service

```shell
sudo brew services start dnsmasq
```

## Usage

### Running the Application

1. Adjust `COMPOSE_PROJECT_NAME` in `Makefile`

2. Start the Docker containers:

```shell
make up
```

3. Access the application in your browser under `http://${COMPOSE_PROJECT_NAME}.docker`

### Stopping Containers
```shell
make stop
```

### Rebuilding containers
```shell
make rebuild
```

## Environment configuration
Environment configurations can be done in `.env` files inside the `etc/` folder.

## Services overview

### Web Server
- Pre-configured with Apache
- Pre-configured with Xdebug for debugging

### Database
- Choose between MySQL or PostgreSQL for storage

### Mailing
- Pre-configured mailhog service

## Development Workflow

### Installing dependencies

Setting up a new application can be easily done, by replacing the `app/` folder or it's contents.

E.g. creating a new Symfony application.
```shell
rm -rf app/
composer create-project symfony/skeleton app
```

## Troubleshooting

### Common Issues
- Port Already in Use: Modify `docker-compose.yml` to use different ports
- Database Connection Issues: Verify setup in `etc/*.env` files

### Logs

Issues inside containers can be logged by running:

```shell
make logs ${CONTAINER_NAME}
```

## Contributing:

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Submit a pull request with clear description

## License

This project is licensed under the MIT License
