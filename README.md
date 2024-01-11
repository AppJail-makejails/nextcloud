# Nextcloud

Nextcloud is a suite of client-server software for creating and using file hosting services. Nextcloud provides functionality similar to Dropbox, Office 365 or Google Drive when used with integrated office suites Collabora Online or OnlyOffice. It can be hosted in the cloud or on-premises. It is scalable, from home office software based on the low cost Raspberry Pi, all the way through to full sized data centers that support millions of users. Translations in 60 languages exist for web interface and client applications.

wikipedia.org/wiki/Nextcloud

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Nextcloud_Logo.svg/800px-Nextcloud_Logo.svg.png" width="60%" height="auto">

## How to use this Makejail

### Recommendation

For any of the following deployment methods visit `Administration settings > Administration > Overview` and follow the recommendations that suits your environment.

### Basic usage

```sh
appjail makejail \
    -j nextcloud \
    -f gh+AppJail-makejails/nextcloud \
    -o virtualnet=":<random> default" \
    -o nat \
    -o expose=80 \
    -o template="$PWD/template.conf"
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

Enter `http://<your ip address>` in the browser on another system or `http://<jail ip address or host name>` on the same system from which Nextcloud is deployed and follow the installation wizard.

### Deploy using appjail-director

Using Director to deploy Nextcloud is easier: run `appjail-director up` and Nextcloud is deployed anywhere.

#### SQLite

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  nextcloud:
    name: nextcloud
    makejail: gh+AppJail-makejails/nextcloud
    environment:
      - SQLITE_DATABASE: nextcloud
      - NEXTCLOUD_ADMIN_USER: !ENV '${ADMIN_USER}'
      - NEXTCLOUD_ADMIN_PASSWORD: !ENV '${ADMIN_PASS}'
      - NEXTCLOUD_TRUSTED_DOMAINS: !ENV '${TRUSTED_DOMAINS}'
    options:
      - expose: 80
      - template: !ENV '${PWD}/template.conf'
    volumes:
      - apps: nextcloud-apps
      - config: nextcloud-config
      - data: nextcloud-data
      - done: nextcloud-done
      - log: nextcloud-log
      - themes: nextcloud-themes

default_volume_type: '<volumefs>'

volumes:
  apps:
    device: .volumes/apps
  config:
    device: .volumes/config
  data:
    device: .volumes/data
  done:
    device: .volumes/done
  log:
    device: .volumes/log
  themes:
    device: .volumes/themes
```

**.env**:

```
DIRECTOR_PROJECT=nextcloud
ADMIN_USER=nextcloud
ADMIN_PASS=nextcloud
TRUSTED_DOMAINS=nextcloud.dtxdf-test.lan
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

#### PostgreSQL

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  nextcloud:
    name: nextcloud
    makejail: gh+AppJail-makejails/nextcloud
    environment:
      - POSTGRES_DB: !ENV '${DB_NAME}'
      - POSTGRES_USER: !ENV '${DB_USER}'
      - POSTGRES_PASSWORD: !ENV '${DB_PASS}'
      - POSTGRES_HOST: nextcloud-postgres
      - NEXTCLOUD_ADMIN_USER: !ENV '${ADMIN_USER}'
      - NEXTCLOUD_ADMIN_PASSWORD: !ENV '${ADMIN_PASS}'
      - NEXTCLOUD_TRUSTED_DOMAINS: !ENV '${TRUSTED_DOMAINS}'
    options:
      - expose: 80
      - template: !ENV '${PWD}/template.conf'
    volumes:
      - nc-apps: nextcloud-apps
      - nc-config: nextcloud-config
      - nc-data: nextcloud-data
      - nc-done: nextcloud-done
      - nc-log: nextcloud-log
      - nc-themes: nextcloud-themes

  db:
    name: nextcloud-postgres
    makejail: gh+AppJail-makejails/postgres
    priority: 98
    environment:
      - POSTGRES_DB: !ENV '${DB_NAME}'
      - POSTGRES_USER: !ENV '${DB_USER}'
      - POSTGRES_PASSWORD: !ENV '${DB_PASS}'
    options:
      - template: !ENV '${PWD}/template.conf'
    arguments:
      - postgres_tag: '13.2-15'
    volumes:
      - pg-done: pg-done
      - pg-data: pg-data

default_volume_type: '<volumefs>'

volumes:
  nc-apps:
    device: .volumes/nextcloud/apps
  nc-config:
    device: .volumes/nextcloud/config
  nc-data:
    device: .volumes/nextcloud/data
  nc-done:
    device: .volumes/nextcloud/done
  nc-log:
    device: .volumes/nextcloud/log
  nc-themes:
    device: .volumes/nextcloud/themes
  pg-done:
    device: .volumes/postgres/done
  pg-data:
    device: .volumes/postgres/data
```

**.env**:

```
DIRECTOR_PROJECT=nextcloud
ADMIN_USER=nextcloud
ADMIN_PASS=nextcloud
TRUSTED_DOMAINS=nextcloud.dtxdf-test.lan
DB_NAME=nextcloud
DB_USER=nextcloud
DB_PASS=nextcloud
```

**template.conf**:

See [#sqlite](#sqlite).

**Notes**:

1. If you see the following message in `Administration settings > Administration > Overview`:

> The database is missing some indexes. Due to the fact that adding indexes on big tables could take some time they were not added automatically. By running "occ db:add-missing-indices" those missing indexes could be added manually while the instance keeps running. Once the indexes are added queries to those tables are usually much faster. Missing optional index "fs_storage_path_prefix" in table "filecache".

Run the following command:

```sh
appjail cmd jexec nextcloud occ db:add-missing-indices
```

#### MySQL / MariaDB

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  nextcloud:
    name: nextcloud
    makejail: gh+AppJail-makejails/nextcloud
    environment:
      - MYSQL_DATABASE: !ENV '${DB_NAME}'
      - MYSQL_USER: !ENV '${DB_USER}'
      - MYSQL_PASSWORD: !ENV '${DB_PASS}'
      - MYSQL_HOST: nextcloud-mariadb
      - NEXTCLOUD_ADMIN_USER: !ENV '${ADMIN_USER}'
      - NEXTCLOUD_ADMIN_PASSWORD: !ENV '${ADMIN_PASS}'
      - NEXTCLOUD_TRUSTED_DOMAINS: !ENV '${TRUSTED_DOMAINS}'
    options:
      - expose: 80
      - template: !ENV '${PWD}/template.conf'
    volumes:
      - nc-apps: nextcloud-apps
      - nc-config: nextcloud-config
      - nc-data: nextcloud-data
      - nc-done: nextcloud-done
      - nc-log: nextcloud-log
      - nc-themes: nextcloud-themes

  db:
    name: nextcloud-mariadb
    makejail: gh+AppJail-makejails/mariadb
    priority: 98
    arguments:
      - mariadb_tag: '13.2-106'
      - mariadb_user: !ENV '${DB_USER}'
      - mariadb_password: !ENV '${DB_PASS}'
      - mariadb_database: !ENV '${DB_NAME}'
      - mariadb_root_password: !ENV '${DB_ROOT_PASS}'
    options:
      - copydir: !ENV '${PWD}/files'
      - file: /usr/local/etc/mysql/conf.d/nextcloud.cnf
    volumes:
      - mariadb-done: mariadb-done
      - mariadb-db: mariadb-db

default_volume_type: '<volumefs>'

volumes:
  nc-apps:
    device: .volumes/nextcloud/apps
  nc-config:
    device: .volumes/nextcloud/config
  nc-data:
    device: .volumes/nextcloud/data
  nc-done:
    device: .volumes/nextcloud/done
  nc-log:
    device: .volumes/nextcloud/log
  nc-themes:
    device: .volumes/nextcloud/themes
  mariadb-done:
    device: .volumes/mariadb/done
  mariadb-db:
    device: .volumes/mariadb/db
```

**.env**:

```
DIRECTOR_PROJECT=nextcloud
ADMIN_USER=nextcloud
ADMIN_PASS=nextcloud
TRUSTED_DOMAINS=nextcloud.dtxdf-test.lan
DB_NAME=nextcloud
DB_USER=nextcloud
DB_PASS=nextcloud
DB_ROOT_PASS=nextcloud-rt
```

**template.conf**:

See [#sqlite](#sqlite).

**files/usr/local/etc/mysql/conf.d/nextcloud.cnf**

```
[mysqld]
transaction_isolation = READ-COMMITTED
binlog_format = ROW
```

#### MinIO

**TODO**: MinIO was successfully tested, however the steps to use it with this Makejail will be posted here when there is a Makejail for it.

#### OpenStack Swift

**TODO**: OpenStack Swift is not tested, if you can, please open an issue with the steps you follow to use it with this Makejail.

#### PHP-FPM + NGINX (+TLS) + MariaDB + Redis + Mailpit

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:
  - copydir: !ENV '${PWD}/files'

services:
  db:
    name: nextcloud-mariadb
    makejail: gh+AppJail-makejails/mariadb
    priority: 97
    arguments:
      - mariadb_tag: '13.2-106'
      - mariadb_user: !ENV '${DB_USER}'
      - mariadb_password: !ENV '${DB_PASS}'
      - mariadb_database: !ENV '${DB_NAME}'
      - mariadb_root_password: !ENV '${DB_ROOT_PASS}'
    options:
      - file: /usr/local/etc/mysql/conf.d/nextcloud.cnf
    volumes:
      - mariadb-done: mariadb-done
      - mariadb-db: mariadb-db

  redis:
    name: nextcloud-redis
    makejail: gh+AppJail-makejails/redis
    priority: 98

  mailpit:
    name: nextcloud-mailpit
    makejail: gh+AppJail-makejails/mailpit
    priority: 99
    start-environment:
      - MP_SMTP_AUTH_ACCEPT_ANY: 1
      - MP_SMTP_AUTH_ALLOW_INSECURE: 1

  nextcloud:
    name: nextcloud
    makejail: gh+AppJail-makejails/nextcloud
    priority: 100
    arguments:
      - nextcloud_tag: '13.2-php82-fpm'
    environment:
      - MYSQL_DATABASE: !ENV '${DB_NAME}'
      - MYSQL_USER: !ENV '${DB_USER}'
      - MYSQL_PASSWORD: !ENV '${DB_PASS}'
      - MYSQL_HOST: nextcloud-mariadb
      - NEXTCLOUD_ADMIN_USER: !ENV '${ADMIN_USER}'
      - NEXTCLOUD_ADMIN_PASSWORD: !ENV '${ADMIN_PASS}'
      - NEXTCLOUD_TRUSTED_DOMAINS: !ENV '${TRUSTED_DOMAINS}'
      - REDIS_HOST: nextcloud-redis
      - SMTP_HOST: nextcloud-mailpit
      - SMTP_PORT: 1025
      - SMTP_NAME: user@example.org
      - SMTP_PASSWORD: xxxxx
      - MAIL_FROM_ADDRESS: support@example.org
      - MAIL_DOMAIN: example.org
    options:
      - template: !ENV '${PWD}/template.conf'
    volumes:
      - nc-apps: nextcloud-apps
      - nc-config: nextcloud-config
      - nc-data: nextcloud-data
      - nc-done: nextcloud-done
      - nc-log: nextcloud-log
      - nc-themes: nextcloud-themes
      - nc-wwwdir: /usr/local/www/nextcloud

  revproxy:
    name: nextcloud-nginx
    makejail: ./nginx.makejail
    priority: 101
    options:
      - file: /usr/local/etc/nginx/nginx.conf
      - file: /usr/local/etc/nginx/mime.types
      - file: /certs
      - expose: 80
      - expose: 443
      - priority: 1
    arguments:
      - server_name: !ENV '${SERVER_NAME}'
    volumes:
      - revproxy-wwwdir: /usr/local/www/nextcloud
      - revproxy-apps: /usr/local/www/nextcloud/apps
      - revproxy-config: /usr/local/www/nextcloud/config
      - revproxy-data: /usr/local/www/nextcloud/data
      - revproxy-themes: /usr/local/www/nextcloud/themes

default_volume_type: '<volumefs>'

volumes:
  nc-apps:
    device: .volumes/nextcloud/apps
  nc-config:
    device: .volumes/nextcloud/config
  nc-data:
    device: .volumes/nextcloud/data
  nc-done:
    device: .volumes/nextcloud/done
  nc-log:
    device: .volumes/nextcloud/log
  nc-themes:
    device: .volumes/nextcloud/themes
  nc-wwwdir:
    device: !ENV '${PWD}/.volumes/nextcloud/wwwdir'
    type: 'nullfs:reverse'
  revproxy-wwwdir:
    device: .volumes/nextcloud/wwwdir
    type: 'nullfs'
  revproxy-apps:
    device: .volumes/nextcloud/apps
    type: 'nullfs'
  revproxy-config:
    device: .volumes/nextcloud/config
    type: 'nullfs'
  revproxy-data:
    device: .volumes/nextcloud/data
    type: 'nullfs'
  revproxy-themes:
    device: .volumes/nextcloud/themes
    type: 'nullfs'
  mariadb-done:
    device: .volumes/mariadb/done
  mariadb-db:
    device: .volumes/mariadb/db
```

**nginx.makejail**:

```
INCLUDE gh+AppJail-makejails/nginx

ARG server_name
ARG worker_processes=auto
ARG worker_connections=1024
ARG resolver=172.0.0.1
ARG nextcloud_addr=nextcloud
ARG nextcloud_port=9000

VAR nginx_conf=/usr/local/etc/nginx/nginx.conf

REPLACE ${nginx_conf} SERVER_NAME ${server_name}
REPLACE ${nginx_conf} WORKER_PROCESSES ${worker_processes}
REPLACE ${nginx_conf} WORKER_CONNECTIONS ${worker_connections}
REPLACE ${nginx_conf} RESOLVER ${resolver}
REPLACE ${nginx_conf} NEXTCLOUD_ADDR ${nextcloud_addr}
REPLACE ${nginx_conf} NEXTCLOUD_PORT ${nextcloud_port}

SERVICE nginx restart
```

**files/usr/local/etc/nginx/nginx.conf**:

```
worker_processes  %{WORKER_PROCESSES};

events {
    worker_connections  %{WORKER_CONNECTIONS};
}

http {
    resolver %{RESOLVER} valid=30s;

    # Set the `immutable` cache control options only for assets with a cache busting `v` argument
    map $arg_v $asset_immutable {
        "" "";
        default "immutable";
    }

    server {
        listen 80;
        listen [::]:80;
        server_name %{SERVER_NAME};

        # Prevent nginx HTTP Server Detection
        server_tokens off;

        # Enforce HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443      ssl http2;
        listen [::]:443 ssl http2;
        server_name %{SERVER_NAME};

        # Path to the root of your installation
        root /usr/local/www/nextcloud;

        # Use Mozilla's guidelines for SSL/TLS settings
        # https://mozilla.github.io/server-side-tls/ssl-config-generator/
        ssl_certificate     /certs/.crt;
        ssl_certificate_key /certs/.key;

        # Prevent nginx HTTP Server Detection
        server_tokens off;

        # HSTS settings
        # WARNING: Only add the preload option once you read about
        # the consequences in https://hstspreload.org/. This option
        # will add the domain to a hardcoded list that is shipped
        # in all major browsers and getting removed from this list
        # could take several months.
        #add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload" always;

        # set max upload size and increase upload timeout:
        client_max_body_size 512M;
        client_body_timeout 300s;
        fastcgi_buffers 64 4K;

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

        # The settings allows you to optimize the HTTP2 bandwidth.
        # See https://blog.cloudflare.com/delivering-http-2-upload-speed-improvements/
        # for tuning hints
        client_body_buffer_size 512k;

        # HTTP response headers borrowed from Nextcloud `.htaccess`
        add_header Referrer-Policy                   "no-referrer"       always;
        add_header X-Content-Type-Options            "nosniff"           always;
        add_header X-Frame-Options                   "SAMEORIGIN"        always;
        add_header X-Permitted-Cross-Domain-Policies "none"              always;
        add_header X-Robots-Tag                      "noindex, nofollow" always;
        add_header X-XSS-Protection                  "1; mode=block"     always;

        # Remove X-Powered-By, which is an information leak
        fastcgi_hide_header X-Powered-By;

        # See mime.types (mjs):
        include mime.types;

        # Specify how to handle directories -- specifying `/index.php$request_uri`
        # here as the fallback means that Nginx always exhibits the desired behaviour
        # when a client requests a path that corresponds to a directory that exists
        # on the server. In particular, if that directory contains an index.php file,
        # that file is correctly served; if it doesn't, then the request is passed to
        # the front-end controller. This consistent behaviour means that we don't need
        # to specify custom rules for certain paths (e.g. images and other asses,
        # `/updater`, `/ocs-provider`), and thus
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
            rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|.+\/richdocumentscode\/proxy) /index.php$request_uri;

            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            set $path_info $fastcgi_path_info;

            try_files $fastcgi_script_name =404;

            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $path_info;
            fastcgi_param HTTPS on;

            fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
            fastcgi_param front_controller_active true;     # Enable pretty urls
            set $endpoint %{NEXTCLOUD_ADDR};
            fastcgi_pass $endpoint:%{NEXTCLOUD_PORT};

            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;

            fastcgi_max_temp_file_size 0;
        }

        # Serve static files
        location ~ \.(?:css|js|mjs|svg|gif|png|jpg|ico|wasm|tflite|map|ogg|flac)$ {
            try_files $uri /index.php$request_uri;
            add_header Cache-Control "public, max-age=15778463, $asset_immutable";
            access_log off;     # Optional: Don't log access to assets

            location ~ \.wasm$ {
                default_type application/wasm;
            }
        }

        location ~ \.woff2?$ {
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

**files/usr/local/etc/nginx/mime.types**:

```
types {
    text/html                                        html htm shtml;
    text/css                                         css;
    text/xml                                         xml;
    image/gif                                        gif;
    image/jpeg                                       jpeg jpg;
    # Add .mjs as a file extension for javascript:
    application/javascript                           js mjs;
    application/atom+xml                             atom;
    application/rss+xml                              rss;

    text/mathml                                      mml;
    text/plain                                       txt;
    text/vnd.sun.j2me.app-descriptor                 jad;
    text/vnd.wap.wml                                 wml;
    text/x-component                                 htc;

    image/avif                                       avif;
    image/png                                        png;
    image/svg+xml                                    svg svgz;
    image/tiff                                       tif tiff;
    image/vnd.wap.wbmp                               wbmp;
    image/webp                                       webp;
    image/x-icon                                     ico;
    image/x-jng                                      jng;
    image/x-ms-bmp                                   bmp;

    font/woff                                        woff;
    font/woff2                                       woff2;

    application/java-archive                         jar war ear;
    application/json                                 json;
    application/mac-binhex40                         hqx;
    application/msword                               doc;
    application/pdf                                  pdf;
    application/postscript                           ps eps ai;
    application/rtf                                  rtf;
    application/vnd.apple.mpegurl                    m3u8;
    application/vnd.google-earth.kml+xml             kml;
    application/vnd.google-earth.kmz                 kmz;
    application/vnd.ms-excel                         xls;
    application/vnd.ms-fontobject                    eot;
    application/vnd.ms-powerpoint                    ppt;
    application/vnd.oasis.opendocument.graphics      odg;
    application/vnd.oasis.opendocument.presentation  odp;
    application/vnd.oasis.opendocument.spreadsheet   ods;
    application/vnd.oasis.opendocument.text          odt;
    application/vnd.openxmlformats-officedocument.presentationml.presentation
                                                     pptx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                                                     xlsx;
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                                     docx;
    application/vnd.wap.wmlc                         wmlc;
    application/wasm                                 wasm;
    application/x-7z-compressed                      7z;
    application/x-cocoa                              cco;
    application/x-java-archive-diff                  jardiff;
    application/x-java-jnlp-file                     jnlp;
    application/x-makeself                           run;
    application/x-perl                               pl pm;
    application/x-pilot                              prc pdb;
    application/x-rar-compressed                     rar;
    application/x-redhat-package-manager             rpm;
    application/x-sea                                sea;
    application/x-shockwave-flash                    swf;
    application/x-stuffit                            sit;
    application/x-tcl                                tcl tk;
    application/x-x509-ca-cert                       der pem crt;
    application/x-xpinstall                          xpi;
    application/xhtml+xml                            xhtml;
    application/xspf+xml                             xspf;
    application/zip                                  zip;

    application/octet-stream                         bin exe dll;
    application/octet-stream                         deb;
    application/octet-stream                         dmg;
    application/octet-stream                         iso img;
    application/octet-stream                         msi msp msm;

    audio/midi                                       mid midi kar;
    audio/mpeg                                       mp3;
    audio/ogg                                        ogg;
    audio/x-m4a                                      m4a;
    audio/x-realaudio                                ra;

    video/3gpp                                       3gpp 3gp;
    video/mp2t                                       ts;
    video/mp4                                        mp4;
    video/mpeg                                       mpeg mpg;
    video/quicktime                                  mov;
    video/webm                                       webm;
    video/x-flv                                      flv;
    video/x-m4v                                      m4v;
    video/x-mng                                      mng;
    video/x-ms-asf                                   asx asf;
    video/x-ms-wmv                                   wmv;
    video/x-msvideo                                  avi;
}
```

**template.conf**:

See [#sqlite](#sqlite).

**Certificate & Key**:

```
# ls files/certs
.crt    .key
```

**files/usr/local/etc/mysql/conf.d/nextcloud.cnf**

See [MySQL / MariaDB](#mysql--mariadb).

**.env**:

```
DIRECTOR_PROJECT=nextcloud
ADMIN_USER=nextcloud
ADMIN_PASS=nextcloud
TRUSTED_DOMAINS=nextcloud.dtxdf-test.lan
DB_NAME=nextcloud
DB_USER=nextcloud
DB_PASS=nextcloud
DB_ROOT_PASS=nextcloud-rt
SERVER_NAME=nextcloud.dtxdf-test.lan
```

**WARNING #1**: The above NGINX configuration file is taken from the [Nextcloud documentation](https://docs.nextcloud.com/server/latest/admin_manual/installation/nginx.html) with minor changes. This configuration file is intended for demonstration purposes, please change anything that does not fit your needs.

**WARNING #2**: Mailpit is used as an SMTP server, but note that it is designed for development and testing.

### Auto configuration via hook folders

There are 5 hooks:

* `pre-installation`: Executed before the Nextcloud is installed/initiated.
* `post-installation`: Executed after the Nextcloud is installed/initiated.
* `pre-upgrade`: Executed before the Nextcloud is upgraded.
* `post-upgrade`: Executed after the Nextcloud is upgraded.
* `before-starting`: Executed before the Nextcloud starts.

To use the hooks triggered by this Makejail, add them to the `/appjail-hooks.d` folder inside the jail.

Note: Only the scripts located in a hook folder (not sub-folders), ending with .sh and marked as executable, will be executed.

### Arguments

* `nextcloud_tag` (default: `13.2-php82-apache`): [#tags](#tags).
* `nextcloud_php_type` (default: `production`): The PHP configuration file to link to `/usr/local/etc/php.ini`. Valid values: `development`, `production`.
* `nextcloud_memory_limit` (default: `513M`): This option will override the memory limit for PHP ([memory_limit](https://www.php.net/manual/en/ini.core.php#ini.memory-limit)).
* `nextcloud_upload_limit` (default: `513M`): This option will change [upload_max_filesize](https://www.php.net/manual/en/ini.core.php#ini.upload-max-filesize) and [post_max_size](https://www.php.net/manual/en/ini.core.php#ini.post-max-size) values.

### Environment

* `NEXTCLOUD_ADMIN_USER` (optional): Name of the Nextcloud admin user.
* `NEXTCLOUD_ADMIN_PASSWORD` (optional): Password for the Nextcloud admin user.
* `NEXTCLOUD_DATA_DIR` (default: `/usr/local/www/nextcloud/data`): Configures the data directory where nextcloud stores all files from the users.
* `SQLITE_DATABASE` (optional): Name of the database using sqlite.
* `MYSQL_DATABASE` (optional): Name of the database using MySQL / MariaDB.
* `MYSQL_USER` (optional): Username for the database using MySQL / MariaDB.
* `MYSQL_PASSWORD` (optional): Password for the database user using MySQL / MariaDB.
* `MYSQL_HOST` (optional): Hostname of the database server using MySQL / MariaDB.
* `POSTGRES_DB` (optional): Name of the database using PostgreSQL.
* `POSTGRES_USER` (optional): Username for the database using PostgreSQL.
* `POSTGRES_PASSWORD` (optional): Password for the database user using PostgreSQL.
* `POSTGRES_HOST` (optional): Hostname of the database server using PostgreSQL.
* `NEXTCLOUD_TRUSTED_DOMAINS` (optional): Optional space-separated list of domains.
* `NEXTCLOUD_INIT_HTACCESS` (optional): Set it to true to enable run `occ maintenance:update:htaccess` after initialization.
* `LOGTIMEZONE` (optional): The timezone for logfiles.
* `REDIS_HOST` (optional): Host or IP address of Redis jail. It is also used as a PHP session handler.
* `REDIS_HOST_PORT` (default: `6379`): Only use for external Redis servers that run on non-standard ports.
* `REDIS_HOST_PASSWORD` (optional): Redis password. 
* `OVERWRITEHOST` (optional): Set the hostname of the proxy. Can also specify a port.
* `OVERWRITEPROTOCOL` (optional): Set the protocol of the proxy, i.e., http or https.
* `OVERWRITECLIURL` (optional): Set the cli url of the proxy (e.g. https://mydnsname.example.com).
* `OVERWRITEWEBROOT` (optional): Set the absolute path of the proxy.
* `OVERWRITECONDADDR` (optional): Regex to overwrite the values dependent on the remote address.
* `TRUSTED_PROXIES` (optional): Space-separated list of trusted proxies. CIDR notation is supported for IPv4.
* `OBJECTSTORE_S3_BUCKET` (optional): The name of the bucket that Nextcloud should store the data in.
* `OBJECTSTORE_S3_SSL` (default: `false`): 
* `OBJECTSTORE_S3_USEPATH_STYLE` (default: `false`): Not required for AWS S3.
* `OBJECTSTORE_S3_LEGACYPATH` (default: `false`): Not required for AWS S3.
* `OBJECTSTORE_S3_AUTOCREATE` (default: `false`): Create the container if it does not exist.
* `OBJECTSTORE_S3_REGION` (optional): The region that the S3 bucket resides in.
* `OBJECTSTORE_S3_HOST` (optional): The hostname of the object storage server.
* `OBJECTSTORE_S3_PORT` (optional): The port that the object storage server is being served over.
* `OBJECTSTORE_S3_OBJECT_PREFIX` (default: `urn:oid:`): Prefix to prepend to the fileid.
* `OBJECTSTORE_S3_KEY` (optional): AWS style access key.
* `OBJECTSTORE_S3_SECRET` (optional): AWS style secret access key.
* `SMTP_HOST` (optional): The hostname of the SMTP server.
* `SMTP_PORT` (default `465` for SSL and `25` for non-secure connections): Optional port for the SMTP connection. Use `587` for an alternative port for STARTTLS.
* `SMTP_SECURE` (optional): Set to `ssl` to use SSL, or `tls` to use STARTTLS.
* `SMTP_NAME` (optional): The username for the authentication.
* `SMTP_AUTHTYPE` (default: `LOGIN`): The method used for authentication. Use PLAIN if no authentication is required.
* `SMTP_PASSWORD` (optional): The password for the authentication.
* `MAIL_FROM_ADDRESS` (optional): Set the local-part for the 'from' field in the emails sent by Nextcloud.
* `MAIL_DOMAIN` (optional): Set a different domain for the emails than the domain where Nextcloud is installed.
* `OBJECTSTORE_SWIFT_URL` (optional): The Swift identity (Keystone) endpoint. 
* `OBJECTSTORE_SWIFT_AUTOCREATE` (default: `false`): Whether or not Nextcloud should automatically create the Swift container.
* `OBJECTSTORE_SWIFT_USER_NAME` (optional): Swift username.
* `OBJECTSTORE_SWIFT_USER_PASSWORD` (optional): Swift user password.
* `OBJECTSTORE_SWIFT_USER_DOMAIN` (optional): Swift user domain.
* `OBJECTSTORE_SWIFT_PROJECT_NAME` (default: `Default`): OpenStack project name.
* `OBJECTSTORE_SWIFT_PROJECT_DOMAIN` (default: `Default`): OpenStack project domain.
* `OBJECTSTORE_SWIFT_SERVICE_NAME` (default: `swift`): 
* `OBJECTSTORE_SWIFT_REGION` (optional): Swift endpoint region
* `OBJECTSTORE_SWIFT_CONTAINER_NAME` (optional): Swift container (bucket) that Nextcloud should store the data in.

### Volumes

| Name               | Owner | Group | Perm | Type | Mountpoint                        |
| ------------------ | ----- | ----- | ---- | ---- | --------------------------------- |
| nextcloud-apps     | 80    | 80    |  -   |  -   | /usr/local/www/nextcloud/apps     |
| nextcloud-apps-pkg | 0     | 0     |  -   |  -   | /usr/local/www/nextcloud/apps-pkg |
| nextcloud-config   | 80    | 80    |  -   |  -   | /usr/local/www/nextcloud/config   |
| nextcloud-data     | 80    | 80    | 770  |  -   | /usr/local/www/nextcloud/data     |
| nextcloud-themes   | 0     | 0     |  -   |  -   | /usr/local/www/nextcloud/themes   |
| nextcloud-done     | -     | -     |  -   |  -   | /.nextcloud-done                  |
| nextcloud-log      | 80    | 80    |  -   |  -   | /var/log/nextcloud                |

**Note**: `nextcloud-apps-pkg` volume was added for special purposes. If you have installed a Nextcloud application using the package manager (not using Nextcloud: `occ` or web GUI), install them each time you create the Nextcloud jail. 

## Tags

| Tag                 | Arch    | Version        | Type   |
| ------------------- | ------- | -------------- | ------ |
| `13.2-php82-apache` | `amd64` | `13.2-RELEASE` | `thin` |
| `13.2-php82-fpm`    | `amd64` | `13.2-RELEASE` | `thin` |
| `14.0-php82-apache` | `amd64` | `14.0-RELEASE` | `thin` |
| `14.0-php82-fpm`    | `amd64` | `14.0-RELEASE` | `thin` |

## Notes

1. The ideas present in the Docker image of Nextcloud are taken into account for users who are familiar with it.
