# Docoba

[![](https://images.microbadger.com/badges/version/kidk/docoba:1.0.0.svg)](https://microbadger.com/images/kidk/docoba:1.0.0 "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/image/kidk/docoba:1.0.0.svg)](https://microbadger.com/images/kidk/docoba:1.0.0 "Get your own image badge on microbadger.com")

A label based backup system for containers. By defining labels at runtime or in Docker compose you can automatically backup containers and store on a remote location.

At the moment it's possible to backup Docker volumes and MySQL databases, but other integrations can easily be added. Backups can be stored remotely on Amazon S3.

## How to use

```
docker run -v /var/run/docker.sock:/var/run/docker.sock --env-file .backup-env kidk/docoba:latest
```

`.backup-env` contains all the environment variables needed for accessing S3.

```
# Credentials for AWS CLI tool
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=eu-west-1
AWS_S3_BUCKET=name-of-bucket
```

## Configuration

To flag a container for backup, use the following labels.

### `VOLUME_BACKUP="volume1,volume2"`

The value is a comma delimited list of volumes you want to backup. The label keeps into account the project used (through docker-compose).

It is technically possible, not advised, to backup volumes not linked to the container with the label.

### `MYSQL_BACKUP=true`

Docoba will try to backup the MySQL container using the available credentials.

It looks for the following environment variables (in order) to connect:
- `root` -> `$MYSQL_ROOT_PASSWORD`
- `root` -> `MYSQL_RANDOM_ROOT_PASSWORD` (retrieves it from Docker logs)
- `MYSQL_USERNAME` -> `MYSQL_PASSWORD`

It will download all tables it can access with exception of `information_schema`, `performance_schema` and `mysql`.

## Example

```
version: '3'

services:
  wordpress:
    image: wordpress
    restart: always
    volumes:
    - wordpress_ps:/var/www/html/wp-content
    labels:
      VOLUME_BACKUP: "wordpress_ps"
    environment:
      WORDPRESS_DB_HOST: "mysql"
      WORDPRESS_DB_USER: "username"
      WORDPRESS_DB_PASSWORD: "password"
      WORDPRESS_DB_NAME: "database"

  mysql:
    image: mysql:5
    restart: always
    volumes:
      - database_ps:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: "super_secret_no_share_plz"
      MYSQL_DATABASE: database
      MYSQL_USER: username
      MYSQL_PASSWORD: password
    labels:
      MYSQL_BACKUP: "true"

volumes:
  wordpress_ps:
  database_ps:
```

## Development and testing

The scripts are written in Bash and are extensively commented. Feel free to provide pull requests, feature requests and bugs as they are much appreciated.

You can use the files in `test/` to run a local dev version of the scripts. Don't run the scripts directly on your machine as it may have unexpected results. Use `docker-compose up` to run a couple of test containers.

## MIT License

Copyright (c) 2018 Docoba

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
