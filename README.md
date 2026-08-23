# Nextcloud

Nextcloud is a suite of client-server software for creating and using file hosting services. Nextcloud provides functionality similar to Dropbox, Office 365 or Google Drive when used with integrated office suites Collabora Online or OnlyOffice. It can be hosted in the cloud or on-premises. It is scalable, from home office software based on the low cost Raspberry Pi, all the way through to full sized data centers that support millions of users. Translations in 60 languages exist for web interface and client applications.

wikipedia.org/wiki/Nextcloud

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Nextcloud_Logo.svg/960px-Nextcloud_Logo.svg.png" width="30%" height="auto" alt="Nextcloud logo">

## How to use this Makejail

This image is designed to be used in a micro-service environment. There are two versions of the image you can choose from.

The `apache` variant contains a full Nextcloud installation including an apache web server. It is designed to be easy to use and gets you running pretty fast. This is also the default for the `latest` tag.

The second option is a `fpm` variant. It is based on the [php-fpm](https://github.com/AppJail-makejails/php) image and runs a fastCGI-Process that serves your Nextcloud page. To use this image it must be combined with any webserver that can proxy the http requests to the FastCGI-port of the container.

### Using the apache image

The apache image contains a webserver and exposes port 80. To start the container type:

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template=template.conf \
    ghcr.io/appjail-makejails/nextcloud nextcloud
```

**template.conf**:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
sysvshm: new
sysvsem: new
sysvmsg: new
mount.devfs
```

Now you can access Nextcloud at http://nextcloud:8080/ from your host system or http://host-ip:8080/ from external hosts.

### Using the fpm image

To use the fpm image, you need an additional web server, such as [nginx](https://docs.nextcloud.com/server/latest/admin_manual/installation/nginx.html), that can proxy http-request to the fpm-port of the container. For fpm connection this container uses port 9000. In most cases, you might want to use another container or your host as proxy.

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template=template.conf \
    ghcr.io/appjail-makejails/nextcloud:15.1-fpm nextcloud
```

As the fastCGI-Process is not capable of serving static files (style sheets, images, ...), the webserver needs access to these files. See below for an example.

### Using an external database

By default, this container uses SQLite for data storage but the Nextcloud setup wizard (appears on first run) allows connecting to an existing MySQL/MariaDB or PostgreSQL database. Later on, we'll deploy both Nextcloud and MariaDB, as well as Nextcloud and PostgreSQL.

### Persistent data

The Nextcloud installation and all data beyond what lives in the database (file uploads, etc.) are stored in the volume `/usr/local/www/html`. That means your data is saved even if the container crashes, is stopped or deleted.

`/usr/local/www/html` folder where all Nextcloud data lives.

```console
$ mkdir -p /var/appjail-volumes/nextcloud/data
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o fstab="/var/appjail-volumes/nextcloud/data /usr/local/www/html" \
    -o template=template.conf \
    ghcr.io/appjail-makejails/nextcloud nextcloud
```

#### Additional volumes

If you want to get fine grained access to your individual files, you can mount additional volumes for data, config, your theme and custom apps. The data, config files are stored in respective subfolders inside `/usr/local/www/html/`. The apps are split into core apps (which are shipped with Nextcloud and you don't need to take care of) and a custom_apps folder. If you use a custom theme it would go into the themes subfolder.

Overview of the folders that can be mounted as volumes:

* `/usr/local/www/html` Main folder, needed for updating
* `/usr/local/www/html/custom_apps` installed / modified apps
* `/usr/local/www/html/config` local configuration
* `/usr/local/www/html/data` the actual data of your Nextcloud
* `/usr/local/www/html/themes/<YOUR_CUSTOM_THEME>` theming/branding

If you want to use volumes for all of these, it would look like this:

```console
$ mkdir -p /var/appjail-volumes/nextcloud/{apps,config,data,theme}
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o fstab="/var/appjail-volumes/nextcloud/apps /usr/local/www/html/custom_apps" \
    -o fstab="/var/appjail-volumes/nextcloud/config /usr/local/www/html/config" \
    -o fstab="/var/appjail-volumes/nextcloud/data /usr/local/www/html/data" \
    -o fstab="/var/appjail-volumes/nextcloud/theme /usr/local/www/html/themes/mytheme" \
    -o template=template.conf \
    ghcr.io/appjail-makejails/nextcloud nextcloud
```

#### Custom volumes

If mounting additional volumes under `/usr/local/www/html`, you should consider:

* Confirming that [upgrade.exclude](upgrade.exclude) contains the files and folders that should persist during installation and upgrades; or
* Mounting storage volumes to locations outside of `/usr/local/www/html`.

> You should note that data inside the main folder (/usr/local/www/html) will be overridden/removed during installation and upgrades, unless listed in [upgrade.exclude](upgrade.exclude). The additional volumes officially supported are already in that list, but custom volumes will need to be added by you. We suggest mounting custom storage volumes outside of /usr/local/www/html and if possible read-only so that making this adjustment is unnecessary. If you must do so, however, you may build a custom image with a modified `/upgrade.exclude` file that incorporates your custom volume(s).

### Using the Nextcloud command-line interface

To use the [Nextcloud command-line interface](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html) (aka. `occ command`):

```console
$ appjail oci exec -u www nextcloud php occ
```

### Auto configuration via environment variables

The Nextcloud image supports auto configuration via environment variables. You can preconfigure everything that is asked on the install page on first run. To enable auto configuration, set your database connection via the following environment variables. You must specify all of the environment variables for a given database or the database environment variables defaults to SQLITE. ONLY use one database type!

**SQLite**:

* `SQLITE_DATABASE`: Name of the database using sqlite.

**MYSQL/MariaDB**:

* `MYSQL_DATABASE`: Name of the database using mysql / mariadb.
* `MYSQL_USER`: Username for the database using mysql / mariadb.
* `MYSQL_PASSWORD`: Password for the database user using mysql / mariadb.
* `MYSQL_HOST`: Hostname of the database server using mysql / mariadb.

**PostgreSQL**:

* `POSTGRES_DB`: Name of the database using postgres.
* `POSTGRES_USER`: Username for the database using postgres.
* `POSTGRES_PASSWORD`: Password for the database user using postgres.
* `POSTGRES_HOST`: Hostname of the database server using postgres.

As an alternative to passing sensitive information via environment variables, `_FILE` may be appended to the previously listed environment variables, causing the initialization script to load the values for those variables from files present in the container. See [AppJail Secrets](#appjail-secrets) section below.

If you set any group of values (i.e. all of `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_HOST`), they will not be asked in the install page on first run. With a complete configuration by using all variables for your database type, you can additionally configure your Nextcloud instance by setting admin user and password (only works if you set both):

* `NEXTCLOUD_ADMIN_USER`: Name of the Nextcloud admin user.
* `NEXTCLOUD_ADMIN_PASSWORD`: Password for the Nextcloud admin user.

If you want, you can set the data directory, otherwise default value will be used.

* `NEXTCLOUD_DATA_DIR` (default: `/usr/local/www/html/data`): Configures the data directory where nextcloud stores all files from the users.

One or more trusted domains can be set through environment variable, too. They will be added to the configuration after install.

* `NEXTCLOUD_TRUSTED_DOMAINS` (not set by default): Optional space-separated list of domains.

The install and update script is only triggered when a default command is used (`httpd-foreground` or php-fpm). If you use a custom command you have to enable the install / update with

* `NEXTCLOUD_UPDATE` (default: `0`)

You might want to make sure the htaccess is up to date after each container update.

* `NEXTCLOUD_INIT_HTACCESS` (not set by default): Set it to true to enable run `occ maintenance:update:htaccess` after container initialization.

If you want to use Redis you have to create a separate [Redis](https://github.com/AppJail-makejails/redis) container in your setup / in your Director file. To inform Nextcloud about the Redis container, pass in the following parameters:

* `REDIS_HOST` (not set by default): Name of Redis container.
* `REDIS_HOST_PORT` (default: `6379`): Optional port for Redis, only use for external Redis servers that run on non-standard ports.
* `REDIS_HOST_PASSWORD` (not set by default): Redis password.

The use of Redis is recommended to prevent file locking problems. See the examples for further instructions.

To use an external SMTP server, you have to provide the connection details. To configure Nextcloud to use SMTP add:

* `SMTP_HOST` (not set by default): The hostname of the SMTP server.
* `SMTP_SECURE` (empty by default): Set to `ssl` to use SSL, or `tls` to use STARTTLS.
* `SMTP_PORT` (default: `465` for SSL and `25` for non-secure connections): Optional port for the SMTP connection. Use `587` for an alternative port for STARTTLS.
* `SMTP_AUTHTYPE` (default: `LOGIN`): The method used for authentication. Use `PLAIN` if no authentication is required.
* `SMTP_NAME` (empty by default): The username for the authentication.
* `SMTP_PASSWORD` (empty by default): The password for the authentication.
* `MAIL_FROM_ADDRESS` (not set by default): Set the local-part for the 'from' field in the emails sent by Nextcloud.
* `MAIL_DOMAIN` (not set by default): Set a different domain for the emails than the domain where Nextcloud is installed.

At least `SMTP_HOST`, `MAIL_FROM_ADDRESS` and `MAIL_DOMAIN` must be set for the configurations to be applied.

Check the [Nextcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/email_configuration.html) for other values to configure SMTP.

To use an external S3 compatible object store as primary storage, set the following variables:

* `OBJECTSTORE_S3_BUCKET`: The name of the bucket that Nextcloud should store the data in
* `OBJECTSTORE_S3_REGION`: The region that the S3 bucket resides in
* `OBJECTSTORE_S3_HOST`: The hostname of the object storage server
* `OBJECTSTORE_S3_PORT`: The port that the object storage server is being served over
* `OBJECTSTORE_S3_KEY`: AWS style access key
* `OBJECTSTORE_S3_SECRET`: AWS style secret access key
* `OBJECTSTORE_S3_STORAGE_CLASS`: The storage class to use when adding objects to the bucket
* `OBJECTSTORE_S3_SSL` (default: `true`): Whether or not SSL/TLS should be used to communicate with object storage server
* `OBJECTSTORE_S3_USEPATH_STYLE` (default: `false`): Not required for AWS S3
* `OBJECTSTORE_S3_LEGACYAUTH` (default: `false`): Not required for AWS S3
* `OBJECTSTORE_S3_OBJECT_PREFIX` (default: `urn:oid:`): Prefix to prepend to the fileid
* `OBJECTSTORE_S3_AUTOCREATE` (default: `true`): Create the container if it does not exist
* `OBJECTSTORE_S3_SSE_C_KEY` (not set by default): Base64 encoded key with a maximum length of 32 bytes for server side encryption (SSE-C)

Check the [Nextcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/primary_storage.html#simple-storage-service-s3) for more information.

To use an external OpenStack Swift object store as primary storage, set the following variables:

* `OBJECTSTORE_SWIFT_URL`: The Swift identity (Keystone) endpoint
* `OBJECTSTORE_SWIFT_AUTOCREATE` (default: `false`): Whether or not Nextcloud should automatically create the Swift container
* `OBJECTSTORE_SWIFT_USER_NAME`: Swift username
* `OBJECTSTORE_SWIFT_USER_PASSWORD`: Swift user password
* `OBJECTSTORE_SWIFT_USER_DOMAIN` (default: `Default`): Swift user domain
* `OBJECTSTORE_SWIFT_PROJECT_NAME`: OpenStack project name
* `OBJECTSTORE_SWIFT_PROJECT_DOMAIN` (default: `Default`): OpenStack project domain
* `OBJECTSTORE_SWIFT_SERVICE_NAME` (default: `swift`): Swift service name
* `OBJECTSTORE_SWIFT_REGION`: Swift endpoint region
* `OBJECTSTORE_SWIFT_CONTAINER_NAME`: Swift container (bucket) that Nextcloud should store the data in

Check the [Nextcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/primary_storage.html#openstack-swift) for more information.

To customize other PHP limits you can simply change the following variables:

* `PHP_MEMORY_LIMIT` (default `512M`) This sets the maximum amount of memory in bytes that a script is allowed to allocate. This is meant to help prevent poorly written scripts from eating up all available memory but it can prevent normal operation if set too tight.
* `PHP_UPLOAD_LIMIT` (default `512M`) This sets the upload limit (`post_max_size` and `upload_max_filesize`) for big files. Note that you may have to change other limits depending on your client, webserver or operating system. Check the [Nextcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/big_file_upload_configuration.html) for more information.

To customize Apache max file upload limit you can change the following variable:

* `APACHE_BODY_LIMIT` (default `1073741824` [1GiB]) This restricts the total size of the HTTP request body sent from the client. It specifies the number of *bytes* that are allowed in a request body. A value of **0** means **unlimited**. Check the [Nextcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/big_file_upload_configuration.html#apache) for more information.

### Auto configuration via hook folders

There are 5 hooks

* `pre-installation`: Executed before the Nextcloud is installed/initiated.
* `post-installation`: Executed after the Nextcloud is installed/initiated.
* `pre-upgrade`: Executed before the Nextcloud is upgraded.
* `post-upgrade`: Executed after the Nextcloud is upgraded.
* `before-starting`: Executed before the Nextcloud starts.

To use the hooks triggered by the `entrypoint` script, either

* Added your script(s) to the individual of the hook folder(s), which are located at the path `/entrypoint-hooks.d` in the container
* Use volume(s) if you want to use script from the host system inside the container, see example.

**Note:** Only the script(s) located in a hook folder (not sub-folders), ending with `.sh` and marked as executable, will be executed.

**Example:** Mount using volumes

```yaml
...
  app:
    name: nextcloud
    makejail: gh+AppJail-makejails/nextcloud
...
    volumes:
      - pre-installation-hook: /entrypoint-hooks.d/pre-installation
      - post-installation-hook: /entrypoint-hooks.d/post-installation
      - pre-upgrade-hook: /entrypoint-hooks.d/pre-upgrade
      - post-upgrade-hook: /entrypoint-hooks.d/post-upgrade
      - before-starting-hook: /entrypoint-hooks.d/before-starting
...
volumes:
  pre-installation-hook:
    device: !ENV '${PWD}/app-hooks/pre-installation'
  post-installation-hook:
    device: !ENV '${PWD}/app-hooks/post-installation-hook'
  pre-upgrade-hook:
    device: !ENV '${PWD}/app-hooks/pre-upgrade'
  post-upgrade-hook:
    device: !ENV '${PWD}/app-hooks/post-upgrade'
  before-starting-hook:
    device: !ENV '${PWD}/app-hooks/before-starting'
```

**Note**: Hooks run as a non-root user. If you want to run the hooks as root, set `RUN_HOOKS_AS_ROOT`. The `RUN_AS` environment variable is set to the non-root user in case you want to downgrade privileges in the script.

### Using the apache image behind a reverse proxy and auto configure server host and protocol

The apache image will replace the remote addr (IP address visible to Nextcloud) with the IP address from `X-Real-IP` if the request is coming from a proxy in `10.0.0.0/8`, `172.16.0.0/12` or `192.168.0.0/16` by default. If you want Nextcloud to pick up the server host (`HTTP_X_FORWARDED_HOST`), protocol (`HTTP_X_FORWARDED_PROTO`) and client IP (`HTTP_X_FORWARDED_FOR`) from a trusted proxy, then disable rewrite IP and add the reverse proxy's IP address to `TRUSTED_PROXIES`.

* `APACHE_DISABLE_REWRITE_IP` (not set by default): Set to 1 to disable rewrite IP.
* `TRUSTED_PROXIES` (empty by default): A space-separated list of trusted proxies. CIDR notation is supported for IPv4.

If the `TRUSTED_PROXIES` approach does not work for you, try using fixed values for overwrite parameters.

* `OVERWRITEHOST` (empty by default): Set the hostname of the proxy. Can also specify a port.
* `OVERWRITEPROTOCOL` (empty by default): Set the protocol of the proxy, http or https.
* `OVERWRITECLIURL` (empty by default): Set the cli url of the proxy (e.g. https://mydnsname.example.com)
* `OVERWRITEWEBROOT` (empty by default): Set the absolute path of the proxy.
* `OVERWRITECONDADDR` (empty by default): Regex to overwrite the values dependent on the remote address.

Check the [Nexcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/reverse_proxy_configuration.html) for more details.

Keep in mind that once set, removing these environment variables won't remove these values from the configuration file, due to how Nextcloud merges configuration files together.

### Running this image with AppJail Director

The easiest way to get a fully featured and functional setup is using a `appjail-director.yml` file. There are too many different possibilities to setup your system, so here are only some examples of what you have to look for.

At first, make sure you have chosen the right base image (fpm or apache) and added features you wanted (see below). In every case, you would want to add a database container and volumes to get easy access to your persistent data. When you want to have your server reachable from the internet, adding HTTPS-encryption is mandatory! See below for more information.

#### Base version - apache

This version will use the apache image and add a mariaDB container. The volumes are set to keep your data persistent. This setup provides **no ssl encryption**.

Make sure to pass in values for `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` variables before you run this setup.

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  db:
    name: nextcloud-db
    makejail: gh+AppJail-makejails/mariadb
    priority: 98
    options:
      - container: 'args:--pull'
    oci:
      arguments: ["--transaction-isolation=READ-COMMITTED", "--log-bin=binlog", "--binlog-format=ROW"]
      environment:
        - MYSQL_ROOT_PASSWORD: !ENV '${MYSQL_ROOT_PASSWORD}'
        - MYSQL_PASSWORD: !ENV '${MYSQL_PASSWORD}'
        - MYSQL_DATABASE: nextcloud
        - MYSQL_USER: nextcloud
    volumes:
      - db: /var/db/mysql

  app:
    name: nextcloud
    makejail: gh+AppJail-makejails/nextcloud
    options:
      - expose: 8080:80
      - container: 'args:--pull'
      - depend: nextcloud-db
      - template: !ENV '${PWD}/template.conf'
    volumes:
      - data: /usr/local/www/html
    oci:
      environment:
        - MYSQL_PASSWORD: !ENV '${MYSQL_PASSWORD}'
        - MYSQL_DATABASE: nextcloud
        - MYSQL_USER: nextcloud
        - MYSQL_HOST: nextcloud-db

volumes:
  db:
    device: /var/appjail-volumes/nextcloud/db
  data:
    device: /var/appjail-volumes/nextcloud/data
```

**.env**:

```dotenv
DIRECTOR_PROJECT=nextcloud
MYSQL_ROOT_PASSWORD=changeme
MYSQL_PASSWORD=please_changeme
```

Then run `appjail-director up`. Now you can access Nextcloud at http://nextcloud/ from your host system or http://host-ip:8080/ from external hosts.

#### Base version - FPM

When using the FPM image, you need another container that acts as web server on port 80 and proxies the requests to the Nextcloud container. In this example a simple nginx container is combined with the Nextcloud-fpm image and a MariaDB database container. The data is stored in volumes. The nginx container also needs access to static files from your Nextcloud installation. The configuration for nginx is stored in the configuration file `nginx.conf`, that is mounted into the container.

As this setup does **not include encryption**, it should be run behind a proxy.

Make sure to pass in values for `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` variables before you run this setup.

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  db:
    name: nextcloud-db
    makejail: gh+AppJail-makejails/mariadb
    priority: 97
    oci:
      arguments: ["--transaction-isolation=READ-COMMITTED", "--log-bin=binlog", "--binlog-format=ROW"]
      environment:
        - MYSQL_ROOT_PASSWORD: !ENV '${MYSQL_ROOT_PASSWORD}'
        - MYSQL_PASSWORD: !ENV '${MYSQL_PASSWORD}'
        - MYSQL_DATABASE: nextcloud
        - MYSQL_USER: nextcloud
    volumes:
      - db: /var/db/mysql

  app:
    name: nextcloud-fpm
    makejail: gh+AppJail-makejails/nextcloud
    priority: 98
    arguments:
      - nextcloud_tag: 15.1-fpm
    options:
      - depend: nextcloud-db
      - template: !ENV '${PWD}/template.conf'
    volumes:
      - data: /usr/local/www/html
    oci:
      environment:
        - MYSQL_PASSWORD: !ENV '${MYSQL_PASSWORD}'
        - MYSQL_DATABASE: nextcloud
        - MYSQL_USER: nextcloud
        - MYSQL_HOST: nextcloud-db

  web:
    name: nextcloud
    makejail: gh+AppJail-makejails/nginx
    options:
      - expose: 8080:80
      - depend: nextcloud-fpm
    volumes:
      - data: /usr/local/www/html
      - nginx_conf: usr/local/etc/nginx/nginx.conf

volumes:
  db:
    device: /var/appjail-volumes/nextcloud/db
  data:
    device: /var/appjail-volumes/nextcloud/data
  nginx_conf:
    device: !ENV '${PWD}/nginx.conf'
    options: ro
```

**.env**:

```dotenv
DIRECTOR_PROJECT=nextcloud
MYSQL_ROOT_PASSWORD=changeme
MYSQL_PASSWORD=please_changeme
```

**nginx.conf**:

```nginx
user  www;
worker_processes  auto;

error_log  /dev/stderr notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /usr/local/etc/nginx/mime.types;
    default_type  application/octet-stream;
    types {
        text/javascript mjs;
    }

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /dev/stdout  main;

    sendfile        on;

    keepalive_timeout  65;

    # Prevent nginx HTTP Server Detection
    server_tokens   off;

    # Set the `immutable` cache control options only for assets with a cache busting `v` argument
    map $arg_v $asset_immutable {
        "" "";
    default ", immutable";
    }

    resolver 172.16.0.1 valid=2s;
    upstream php-handler {
        zone backends 64k;
        server nextcloud-fpm:9000 resolve;
    }

    server {
        listen        80;

        # HSTS settings
        # WARNING: Only add the preload option once you read about
        # the consequences in https://hstspreload.org/. This option
        # will add the domain to a hardcoded list that is shipped
        # in all major browsers and getting removed from this list
        # could take several months.
        #add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;

        # set max upload size and increase upload timeout:
        client_max_body_size 512M;
        client_body_timeout 300s;
        fastcgi_buffers 64 4K;

        # The settings allows you to optimize the HTTP2 bandwidth.
        # See https://blog.cloudflare.com/delivering-http-2-upload-speed-improvements/
        # for tuning hints
        client_body_buffer_size 512k;

        # Enable gzip but do not remove ETag headers
        gzip on;
        gzip_vary on;
        gzip_comp_level 4;
        gzip_min_length 256;
        gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
        gzip_types application/atom+xml text/javascript application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

        # Pagespeed is not supported by Nextcloud, so if your server is built
        # with the `ngx_pagespeed` module, uncomment this line to disable it.
        #pagespeed off;

        # HTTP response headers borrowed from Nextcloud `.htaccess`
        add_header Referrer-Policy                      "no-referrer"       always;
        add_header X-Content-Type-Options               "nosniff"           always;
        add_header X-Frame-Options                      "SAMEORIGIN"        always;
        add_header X-Permitted-Cross-Domain-Policies    "none"              always;
        add_header X-Robots-Tag                         "noindex, nofollow" always;

        # Remove X-Powered-By, which is an information leak
        fastcgi_hide_header X-Powered-By;

        # Path to the root of your installation
        root /usr/local/www/html;

        # Specify how to handle directories -- specifying `/index.php$request_uri`
        # here as the fallback means that Nginx always exhibits the desired behaviour
        # when a client requests a path that corresponds to a directory that exists
        # on the server. In particular, if that directory contains an index.php file,
        # that file is correctly served; if it doesn't, then the request is passed to
        # the front-end controller. This consistent behaviour means that we don't need
        # to specify custom rules for certain paths (e.g. images and other assets,
        # `/updater`, `/ocm-provider`, `/ocs-provider`), and thus
        # `try_files $uri $uri/ /index.php$request_uri`
        # always provides the desired behaviour.
        index index.php index.html /index.php$request_uri;

        # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
        location = / {
            if ( $http_user_agent ~ ^DavClnt ) {
                return 302 /remote.php/webdav/$is_args$args;
            }
        }

        location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
        }

        # Make a regex exception for `/.well-known` so that clients can still
        # access it despite the existence of the regex rule
        # `location ~ /(\.|autotest|...)` which would otherwise handle requests
        # for `/.well-known`.
        location ^~ /.well-known {
            # The rules in this block are an adaptation of the rules
            # in `.htaccess` that concern `/.well-known`.

            location = /.well-known/carddav { return 301 /remote.php/dav/; }
            location = /.well-known/caldav  { return 301 /remote.php/dav/; }

            location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
            location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

            # Let Nextcloud's API for `/.well-known` URIs handle all other
            # requests by passing them to the front-end controller.
            return 301 /index.php$request_uri;
        }

        # Rules borrowed from `.htaccess` to hide certain paths from clients
        location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
        location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

        # Ensure this block, which passes PHP files to the PHP process, is above the blocks
        # which handle static assets (as seen below). If this block is not declared first,
        # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
        # to the URI, resulting in a HTTP 500 error response.
        location ~ \.php(?:$|/) {
            # Required for legacy support
            rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|.+\/richdocumentscode(_arm64)?\/proxy) /index.php$request_uri;

            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            set $path_info $fastcgi_path_info;

            try_files $fastcgi_script_name =404;

            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $path_info;
            #fastcgi_param HTTPS on;

            fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
            fastcgi_param front_controller_active true;     # Enable pretty urls
            fastcgi_pass php-handler;

            fastcgi_intercept_errors on;
            fastcgi_request_buffering on;                   # Required as PHP-FPM does not support chunked transfer encoding and requires a valid ContentLength header.

            fastcgi_max_temp_file_size 0;
        }

        # Serve static files
        location ~ \.(?:css|js|mjs|svg|gif|ico|jpg|png|webp|wasm|tflite|map|ogg|flac|mp4|webm)$ {
            try_files $uri /index.php$request_uri;
            add_header Cache-Control "public, max-age=15778463$asset_immutable";
            add_header Referrer-Policy                   "no-referrer"       always;
            add_header X-Content-Type-Options            "nosniff"           always;
            add_header X-Frame-Options                   "SAMEORIGIN"        always;
            add_header X-Permitted-Cross-Domain-Policies "none"              always;
            add_header X-Robots-Tag                      "noindex, nofollow" always;
            access_log off;     # Optional: Don't log access to assets
        }

        location ~ \.(otf|woff2?)$ {
            try_files $uri /index.php$request_uri;
            expires 7d;         # Cache-Control policy borrowed from `.htaccess`
            access_log off;     # Optional: Don't log access to assets
        }

        # Rule borrowed from `.htaccess`
        location /remote {
            return 301 /remote.php$request_uri;
        }

        location / {
            try_files $uri $uri/ /index.php$request_uri;
        }
    }
}
```

Then run `appjail-director up`. Now you can access Nextcloud at http://nextcloud/ from your host system or http://host-ip:8080/ from external hosts.

### AppJail Secrets

As an alternative to passing sensitive information via environment variables, `_FILE` may be appended to the previously listed environment variables, causing the initialization script to load the values for those variables from files present in the container.  In particular, this can be used to load passwords from [AppJail secrets](https://appjail.readthedocs.io/en/latest/secrets/) stored in `/secrets/<group_name>/<secret_name>` files. For example:

**Secrets**:

```console
$ # IMPORTANT: Turn off shell history
$ appjail secrets create -s postgres/db nextcloud
$ appjail secrets create -s postgres/user nextcloud
$ appjail secrets create -s postgres/password nextcloud
$ appjail secrets create -s nextcloud/admin_password nextcloud
$ appjail secrets create -s nextcloud/admin_user admin
```

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  db:
    name: nextcloud-db
    priority: 98
    makejail: gh+AppJail-makejails/postgres
    options:
      - template: !ENV '${PWD}/template.conf'
      - secret: postgres
    volumes:
      - db: /var/db/postgres
    oci:
      environment:
        - POSTGRES_DB_FILE: /secrets/postgres/db
        - POSTGRES_USER_FILE: /secrets/postgres/user
        - POSTGRES_PASSWORD_FILE: /secrets/postgres/password

  app:
    name: nextcloud
    makejail: gh+AppJail-makejails/nextcloud
    options:
      - expose: 8080:80
      - depend: nextcloud-db
      - template: !ENV '${PWD}/template.conf'
      - secret: postgres
      - secret: nextcloud
    volumes:
      - data: /usr/local/www/html
    oci:
      environment:
        - POSTGRES_HOST: nextcloud-db
        - POSTGRES_DB_FILE: /secrets/postgres/db
        - POSTGRES_USER_FILE: /secrets/postgres/user
        - POSTGRES_PASSWORD_FILE: /secrets/postgres/password
        - NEXTCLOUD_ADMIN_PASSWORD_FILE: /secrets/nextcloud/admin_password
        - NEXTCLOUD_ADMIN_USER_FILE: /secrets/nextcloud/admin_user
        # required due to NEXTCLOUD_ADMIN_* env vars
        - NEXTCLOUD_TRUSTED_DOMAINS: nextcloud

volumes:
  db:
    device: /var/appjail-volumes/nextcloud/db
  data:
    device: /var/appjail-volumes/nextcloud/data
```

Currently, this is only supported for `NEXTCLOUD_ADMIN_PASSWORD`, `NEXTCLOUD_ADMIN_USER`, `MYSQL_DATABASE`, `MYSQL_PASSWORD`, `MYSQL_USER`, `POSTGRES_DB`, `POSTGRES_PASSWORD`, `POSTGRES_USER`, `REDIS_HOST_PASSWORD`, `SMTP_PASSWORD`, `OBJECTSTORE_S3_KEY`, and `OBJECTSTORE_S3_SECRET`.

If you set any group of values (i.e. all of `MYSQL_DATABASE_FILE`, `MYSQL_USER_FILE`, `MYSQL_PASSWORD_FILE`, `MYSQL_HOST`), the script will not use the corresponding group of environment variables (`MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_HOST`).

### Make your Nextcloud available from the internet

Until here, your Nextcloud is just available from your appjail host. If you want your Nextcloud available from the internet adding SSL encryption is mandatory.

#### HTTPS - SSL encryption

There are many different possibilities to introduce encryption depending on your setup.

We recommend using a reverse proxy in front of your Nextcloud installation. Your Nextcloud will only be reachable through the proxy, which encrypts all traffic to the clients. You can mount your manually generated certificates to the proxy or use a fully automated solution which generates and renews the certificates for you.

### First use

When you first access your Nextcloud, the setup wizard will appear and ask you to choose an administrator account username, password and the database connection. For the database use `nextcloud-db` as host and `nextcloud` as table and user name. Also enter the password you chose in your `appjail-director.yml` file.

### Update to a newer version

Updating the Nextcloud container is done by pulling the new image, throwing away the old container and starting the new one.

**It is only possible to upgrade one major version at a time. For example, if you want to upgrade from version 14 to 16, you will have to upgrade from version 14 to 15, then from 15 to 16.**

Since all data is stored in volumes, nothing gets lost. The startup script will check for the version in your volume and the installed version. If it finds a mismatch, it automatically starts the upgrade process. Don't forget to add all the volumes to your new container, so it works as expected.

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template=template.conf \
    -o fstab="/var/appjail-volumes/nextcloud/data /usr/local/www/html" \
    ghcr.io/appjail-makejails/nextcloud nextcloud
```

Beware that you have to run the same command with the options that you used to initially start your Nextcloud. That includes volumes, port mapping.

When using AppJail Director, your `appjail-director.yml` file takes care of your configuration, so you just have to run:

```console
$ appjail-director down -d && appjail-director up
```

### Adding Features

A lot of people want to use additional functionality inside their Nextcloud installation. If the image does not include the packages you need, you can easily build your own image on top of it. Start your derived image with the `FROM` statement and add whatever you like.

```dockerfile
FROM ghcr.io/appjail-makejails/nextcloud:15.1-apache

RUN ...
```

If you intend to use another command to run the image, make sure that you set `NEXTCLOUD_UPDATE=1` in your Containerfile. Otherwise the installation and update will not work.

```dockerfile
FROM ghcr.io/appjail-makejails/nextcloud:15.1-apache

...

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/local/bin/supervisord"]
```

**Updating** your own derived image is also very simple. When a new version of the Nextcloud image is available run:

```console
$ buildah build --network=host -t your-name --pull .
```

The `--pull` option tells buildah to look for new versions of the base image. Then the build instructions inside your `Containerfile` are run on top of the new image.

### Arguments (stage: build)

* `nextcloud_from` (default: `ghcr.io/appjail-makejails/nextcloud`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `nextcloud_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `UMASK` (default: `0022`): Override default umask setting.

### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-44aff70a60-usr_local_www_html | `${PUID}` | `${PGID}` | - | - | /usr/local/www/html |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1-apache
      containerfile: Containerfile.apache
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        APACHEVER: "24"
        PHPVER: "84"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-fpm
      containerfile: Containerfile.fpm
      args:
        FREEBSD_RELEASE: "15.1"
        PHPVER: "84"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```

## Notes

1. The ideas present in the Docker image of Nextcloud are taken into account for users who are familiar with it.
