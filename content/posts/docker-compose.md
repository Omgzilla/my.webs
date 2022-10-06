---
title: "Docker Compose"
subtitle: ""
date: 2022-10-06T02:31:23+02:00
lastmod: 2022-10-06T02:31:23+02:00
draft: false
author: "Ohmygodzilla"
authorLink: ""
description: ""
images: []

tags: [docker]
# ubuntu, database, sql, cheat-sheet, docker, container
categories: [documentation]
# cheat-sheet, documentation

featuredImage: "images/docker-compose.webp"
featuredImagePreview: "images/docker-compose.webp"

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

# Docker-Compose
...

## Networking
By default Docker-Compose will create a new network for the given compose file. You can change the behavior by defining custom networks in your compose file.
### Create and assign custom network
...
*Example:*
```yaml
networks:
  custom-network:

services:
  app:
    networks:
      - custom-network
```
### Use existing networks
If you want to use an existing Docker network for your compose files, you can add the `external: true` parameter in your compose file
*Example:*
```yaml
networks:
  existing-network:
    external: true
```