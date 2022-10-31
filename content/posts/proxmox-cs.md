---
title: "Proxmox"
subtitle: "Proxmox Cheat-sheet"
date: 2022-10-06T13:39:59+02:00
lastmod: 2022-10-06T13:39:59+02:00
draft: false
author: "Ohmygodzilla"
authorLink: ""
description: ""
images: []

tags: [Cheat-sheet, Virtual machine, Container]
categories: [cheat-sheet]

featuredImage: "images/proxmox.png"
featuredImagePreview: "images/proxmox.png"

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
Increase disk size in the GUI or with the following command
<!-- more -->
## Resize Disk
### Increase disk size
Increase disk size in the GUI or with the following command
```
qm resize 100 virtio0 +5G
```

### Decrease disk size
> Before decreasing disk sizes in Proxmox, you should take a backup!
1. Convert qcow2 to raw
```
qemu-img convert vm-100.qcow2 vm-100.raw
```
2. Shrink the disk
```
qemu-img resize -f raw vm-100.raw 10G
```
3. Convert back to qcow2#
```
qemu-img convert -p -O qcow2 vm-100.raw vm-100.qcow2
```
