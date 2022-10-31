---
title: "Arch Maintenance Commands"
subtitle: ""
date: 2022-10-31T13:55:33+01:00
lastmod: 2022-10-31T13:55:33+01:00
draft: false
author: "Ohmygodzilla"
authorLink: ""
description: ""
images: []

tags: [Linux, Cheat-sheet]
categories: [cheat-sheet]

featuredImage: "images/arch-pacman.png"
featuredImagePreview: "images/arch-pacman.png"

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: false
ruby: true
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

<!-- more -->
# Arch maintenance commands
##### Check systemd failed services
```bash
systemctl --failed
```
##### Log files check
```bash
sudo journalctl -p 3 -xb
```
##### Clean the journal
```bash
sudo journalctl --vacuum-time=2weeks
```
---------------------
##### Pacman Update
```bash
sudo pacman -Syu
```
##### Delete Pacman Cache
```bash
sudo pacman -Scc
```
##### Check Orphan packages
```bash
pacman -Qtdq
```
##### Remove Orphan packages
```bash
sudo pacman -Rns $(pacman -Qtdq)
```
---------------------
##### Paru Update
```bash
paru
```
##### Delete Paru Cache
```bash
paru -Scc
```
##### Delete unwanted dependencies
```bash
paru -Yc
```
---------------------
##### Yay Update
```bash
yay
```
##### Delete Yay Cache
```bash
yay -Scc
```
##### Delete unwanted dependencies
```bash
yay -Yc
```
---------------------
##### Clean the Cache
```bash
rm -rf .cache/*
```

