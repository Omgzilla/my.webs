---
title: "Mariadb Setup"
subtitle: "MariaDB SQL Database"
date: 2022-10-06T00:59:35+02:00
lastmod: 2022-10-06T00:59:35+02:00
draft: false
author: "Ohmygodzilla"
authorLink: ""
description: "How to setup MariaDB basic"
images: [images/mariadb-setup.jpg]

tags: [ubuntu, database, sql]
categories: [documentation]

featuredImage: "images/mariadb-setup.jpg"
featuredImagePreview: "images/mariadb-setup.jpg"

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: false
ruby: false
fraction: true
fontawesome: true
linkToMarkdown: true
rssFullText: false

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
math:
  enable: false
share:
  enable: true
comment:
  enable: true
---

# MariaDB Cheat-Sheet

## Install MariaDB on Ubuntu 20.04 LTS
```bash
sudo apt update
sudo apt install mariadb-server
sudo mysql_secure_installation
```

## Access Database from outside
Open `/etc/mysql/mariadb.conf.d/50-server.cnf` and change the `bind-address` to:
```vim
bind-address = 0.0.0.0
```
## Create Administrative User
1. Create a new user `newuser` for the host `localhost` with a new `password`:
```mysql
CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';
```

2. Grant all permissions to the new user
```mysql
GRANT ALL PRIVILEGES ON * . * TO 'newuser'@'localhost';
``` 

3. Update permissions
```mysql
FLUSH PRIVILEGES;
```