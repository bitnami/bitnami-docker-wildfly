[![CircleCI](https://circleci.com/gh/bitnami/bitnami-docker-wildfly/tree/master.svg?style=shield)](https://circleci.com/gh/bitnami/bitnami-docker-wildfly/tree/master)
[![Docker Hub Automated Build](http://container.checkforupdates.com/badges/bitnami/wildfly)](https://hub.docker.com/r/bitnami/wildfly/)

# What is Wildfly?

> [Wildfly](http://wildfly.org), formerly known as JBoss AS, or simply JBoss, is an application server authored by JBoss, now developed by Red Hat. WildFly is written in Java, and implements the Java Platform, Enterprise Edition (Java EE) specification.

# TLDR

```bash
docker run --name wildfly bitnami/wildfly:latest
```

## Docker Compose

```yaml
version: '2'

services:
  wildfly:
    image: 'bitnami/wildfly:latest'
    ports:
      - '8080:8080'
      - '9990:9990'
```

# Supported tags and respective `Dockerfile` links

 - [`11`, `11.0.0-r0`, `latest` (11/Dockerfile)](https://github.com/bitnami/bitnami-docker-wildfly/blob/master/11/Dockerfile)
 - [`10`, `10.1.0-r7` (10/Dockerfile)](https://github.com/bitnami/bitnami-docker-wildfly/blob/master/10/Dockerfile)

Subscribe to project updates by watching the [bitnami/php-fpm GitHub repo](https://github.com/bitnami/bitnami-docker-wildfly).

# Get this image

The recommended way to get the Bitnami Wildfly Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/bitnami/wildfly).

```bash
docker pull bitnami/wildfly:latest
```

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://hub.docker.com/r/bitnami/wildfly/tags/) in the Docker Hub Registry.

```bash
docker pull bitnami/wildfly:[TAG]
```

If you wish, you can also build the image yourself.

```bash
docker build -t bitnami/wildfly:latest https://github.com/bitnami/bitnami-docker-wildfly.git
```

# Persisting Wildfly configurations and deployments

If you remove the container all your Wildfly configurations and application deployments will be lost. To avoid this you should mount a volume that will persist even after the container is removed.

**Note!**
If you have already started using your Wildfly deployment, follow the steps on
[backing up](#backing-up-your-container) and [restoring](#restoring-a-backup) to pull the data from your running container down to your host.

The image exposes a volume at `/bitnami/wildfly` for the Wildfly configurations and application deployments. For persistence you can mount a directory at this location from your host. If the mounted directory is empty, it will be initialized on the first run.

```bash
docker run -v /path/to/wildfly-persistence:/bitnami/wildfly bitnami/wildfly:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  wildfly:
    image: 'bitnami/wildfly:latest'
    ports:
      - '8080:8080'
      - '9990:9990'
    volumes:
      - /path/to/wildfly-persistence:/bitnami/wildfly
```

# Deploying web applications on Wildfly

The `/bitnami/wildfly/data` directory is configured as the Wildfly webapps deployment directory. At this location, you either copy a so-called *exploded web application*, i.e. non-compressed, or a compressed web application resource (`.WAR`) file and it will automatically be deployed by Wildfly.

Additionally a helper symlink `/app` is present that points to the webapps deployment directory which enables us to deploy applications on a running Wildfly instance by simply doing:

```bash
docker cp /path/to/app.war wildfly:/app
```

**Note!**
You can also deploy web applications on a running Wildfly instance using the Wildfly management interface.

# Accessing your Wildfly server from the host

The image exposes the application server on port `8080` and the management console on port `9990`. To access your web server from your host machine you can ask Docker to map random ports on your host to the ports `8080` and `9990` of the container.

```bash
docker run --name wildfly -P bitnami/wildfly:latest
```

Run `docker port` to determine the random ports Docker assigned.

```bash
$ docker port wildfly
8080/tcp -> 0.0.0.0:32775
9990/tcp -> 0.0.0.0:32774
```

You can also manually specify the ports you want forwarded from your host to the container.

```bash
docker run -p 8080:8080 -p 9990:9990 bitnami/wildfly:latest
```

Access your web server in the browser by navigating to [http://localhost:8080](http://localhost:8080/) to access the application server and [http://localhost:9990/console](http://localhost:9990/console/) to access the management console.

# Accessing the command line interface

The command line management tool `jboss-cli.sh` allows a user to connect to the Wildfly server and execute management operations available through the de-typed management model.

The Bitnami Wildfly Docker Image ships the `jboss-cli.sh` client and can be launched by specifying the command while launching the container.

## Connecting a client container to the Wildfly server container

### Step 1: Create a network

```bash
$ docker network create wildfly-tier --driver bridge
```

### Step 2: Launch the Wildfly server instance

Use the `--network wildfly-tier` argument to the `docker run` command to attach the Wildfly container to the `wildfly-tier` network.

```bash
$ docker run -d --name wildfly-server \
    --network wildfly-tier \
    bitnami/wildfly:latest
```

### Step 3: Launch your Wildfly client instance

Finally we create a new container instance to launch the Wildfly client and connect to the server created in the previous step:

```bash
$ docker run -it --rm \
    --network wildfly-tier \
    bitnami/wildfly:latest jboss-cli.sh --controller=wildfly-server:9990  --connect
```

**Note!**
You can also run the client in the same container as the server using the Docker [exec](https://docs.docker.com/reference/commandline/cli/#exec) command.

```bash
docker exec -it wildfly-server \
  jboss-cli.sh --controller=wildfly-server:9990 --connect
```

# Configuration

## Creating a custom user

By default, a management user named `user` is created with the default password `bitnami`. Passing the `WILDFLY_PASSWORD` environment variable when running the image for the first time will set the password of this user to the value of `WILDFLY_PASSWORD`.

Additionally you can specify a user name for the management user using the `WILDFLY_USERNAME` environment variable. When not specified, the `WILDFLY_PASSWORD` configuration is applied on the default user (`user`).

```bash
docker run --name wildfly \
  -e WILDFLY_USERNAME=my_user \
  -e WILDFLY_PASSWORD=my_password \
  bitnami/wildfly:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  wildfly:
    image: 'bitnami/wildfly:latest'
    ports:
      - '8080:8080'
      - '9990:9990'
    environment:
      - WILDFLY_USERNAME=my_user
      - WILDFLY_PASSWORD=my_password
```

## Configuration files

This image looks for Wildfly configuration files in `/bitnami/wildfly/conf`. You may recall from the [persisting wildfly configurations and deployments](#persisting-wildfly-configurations-and-deployments) section, `/bitnami/wildfly` is the path to the persistence volume.

Create a directory named `conf/` at this location with your own configuration, or the default configuration will be copied on the first run which can be customized later.

### Step 1: Run the Wildfly image

Run the Wildfly image, mounting a directory from your host.

```bash
docker run --name wildfly -v /path/to/wildfly-persistence:/bitnami/wildfly bitnami/wildfly:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  wildfly:
    image: 'bitnami/wildfly:latest'
    ports:
      - '8080:8080'
      - '9990:9990'
    volumes:
      - /path/to/wildfly-persistence:/bitnami/wildfly
```

### Step 2: Edit the configuration

Edit the configuration on your host using your favorite editor.

eg.

```bash
vim /path/to/wildfly-persistence/conf/standalone.xml
```

### Step 3: Restart Wildfly

After changing the configuration, restart your Wildfly container for the changes to take effect.

```bash
docker restart wildfly
```

or using Docker Compose:

```bash
docker-compose restart wildfly
```

**Further Reading:**

  - [General configuration concepts](https://docs.jboss.org/author/display/WFLY9/General+configuration+concepts)

# Logging

The Bitnami Wildfly Docker image sends the container logs to the `stdout`. To view the logs:

```bash
docker logs wildfly
```

or using Docker Compose:

```bash
docker-compose logs wildfly
```

You can configure the containers [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration docker uses the `json-file` driver.

# Maintenance

## Backing up your container

To backup your configuration and logs, follow these simple steps:

### Step 1: Stop the currently running container

```bash
docker stop wildfly
```

or using Docker Compose:

```bash
docker-compose stop wildfly
```

### Step 2: Run the backup command

We need to mount two volumes in a container we will use to create the backup: a directory on your host to store the backup in, and the volumes from the container we just stopped so we can access the data.

```bash
docker run --rm \
  -v /path/to/wildfly-backups:/backups \
  --volumes-from wildfly \
  busybox cp -a /bitnami/wildfly /backups/latest
```

or using Docker Compose:

```bash
docker run --rm \
  -v /path/to/wildfly-backups:/backups \
  --volumes-from `docker-compose ps -q wildfly` \
  busybox cp -a /bitnami/wildfly /backups/latest
```

## Restoring a backup

Restoring a backup is as simple as mounting the backup as volumes in the container.

```bash
docker run \
  -v /path/to/wildfly-backups/latest:/bitnami/wildfly \
  bitnami/wildfly:latest
```

or using Docker Compose:

```yaml
version: '2'

services:
  wildfly:
    image: 'bitnami/wildfly:latest'
    ports:
      - '8080:8080'
      - '9990:9990'
    volumes:
      - /path/to/wildfly-backups/latest:/bitnami/wildfly
```

## Upgrade this image

Bitnami provides up-to-date versions of Wildfly, including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container.

### Step 1: Get the updated image

```bash
docker pull bitnami/wildfly:latest
```

or if you're using Docker Compose, update the value of the image property to
`bitnami/wildfly:latest`.

### Step 2: Stop and backup the currently running container

Before continuing, you should backup your container's configuration and logs.

Follow the steps on [creating a backup](#backing-up-your-container).

### Step 3: Remove the currently running container

```bash
docker rm -v wildfly
```

or using Docker Compose:

```bash
docker-compose rm -v wildfly
```

### Step 4: Run the new image

Re-create your container from the new image, [restoring your backup](#restoring-a-backup) if necessary.

```bash
docker run --name wildfly bitnami/wildfly:latest
```

or using Docker Compose:

```bash
docker-compose start wildfly
```

# Notable Changes

## 10.0.0-r3

- `WILDFLY_USER` parameter has been renamed to `WILDFLY_USERNAME`.

## 10.0.0-r0

- All volumes have been merged at `/bitnami/tomcat`. Now you only need to mount a single volume at `/bitnami/tomcat` for persistence.
- The logs are always sent to the `stdout` and are no longer collected in the volume.

# Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/bitnami/bitnami-docker-wildfly/issues), or submit a [pull request](https://github.com/bitnami/bitnami-docker-wildfly/pulls) with your contribution.

# Issues

If you encountered a problem running this container, you can file an [issue](https://github.com/bitnami/bitnami-docker-wildfly/issues). For us to provide better support, be sure to include the following information in your issue:

- Host OS and version
- Docker version (`docker version`)
- Output of `docker info`
- Version of this container (`echo $BITNAMI_IMAGE_VERSION` inside the container)
- The command you used to run the container, and any relevant output you saw (masking any sensitive information)

# License

Copyright (c) 2015-2016 Bitnami

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
