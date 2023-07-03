---
title: "[Workshop] Learn how to integrate your charm with COS-Lite all the way"
subtitle: "Summary on what we talked about on the workshop"
date: 2023-07-03T13:05:02+02:00
lastmod: 2023-07-03T13:05:02+02:00
draft: false
author: "Ohmygodzilla"
authorLink: ""
description: ""
images: []

tags: [COS-Lite, Documentation, Guide]
# Windows, Linux, MacOS
# Database, SQL
# Cheat-sheet, Documentation, Guide
# Virtual machine, Docker, Container 
# Web server, Nginx, Reverse-proxy, Proxy
categories: [documentation]
# cheat-sheet, documentation

featuredImage: "images/cos-lite-grafana.png"
featuredImagePreview: "images/cos-lite-grafana.png"

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

*This is a summary of what we talked about on the workshop [Learn how to integrate your charm with COS-lite all the way](https://discourse.charmhub.io/t/community-workshop-learn-how-to-integrate-your-charm-with-cos-lite-all-the-way/10917)*

Deployment of a COS-lite on microk8 (kubernetes).
Using cross-model relations with the VM charm observed.
How grafana-dashboards, prometheus (metrics), loki (logs), prometheus alert rules are added automatically by the observed charm.
How to ship alarms/alerts to PagerDuty and/or Slack (webhooks).

## How to setup a COS-lite environment and start tinkering with it

*Notice that this is an example setup to be able to start tinkering with COS-lite*

### Creating a bridge for COS-lite
We started of by creating a bridge in netplan to separate the network for COS-lite.

Edit `/etc/netplan/network-configuration-file.yaml`
```yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    wlp9s0:
      dhcp4: true
      dhcp6: true
  bridges:
    k8sbr0:
      interfaces:
        - wlp9s0
      addresses:
        - 10.10.88.1/24
      routes:
        - to: 0.0.0.0/0
          via: 10.10.88.1
      nameservers:
        addresses:
          - 10.10.88.1
      dhcp4: false
      dhcp6: false
```
<br>


### Install microk8s cloud
After that we continued with installing microk8s from snap

<!-- 2-install_microk8s -->
<script async id="asciicast-UR7KSN2lwa6Q5yyyu0luBI6hh" src="https://asciinema.org/a/UR7KSN2lwa6Q5yyyu0luBI6hh.js"></script>

<details>
  <summary>Commands</summary>

*Metallb is a load balancer and your gateway in to traefik. Traefik then points to services inside kubernetes. There is 3 ways to set IP-addresses, examples: 1. Static-IP: 192.168.0.3/32, 2. Subnet: 192.168.0.0/24, 3. IP-range: 192.168.0.10-192.168.0.20*

```bash
$ sudo snap install microk8s --classic
$ microk8s.enable dns hostpath-storage metallb:10.10.88.2-10.10.88.10
```
</details>
<br>


### Bootstrap a controller on microk8s cloud
Next we bootstrapped a juju controller on the microk8s cloud
<!-- 3-bootstrap_controller -->
<script async id="asciicast-u6CSRmWH8FVmXikWNjG42IVhw" src="https://asciinema.org/a/u6CSRmWH8FVmXikWNjG42IVhw.js"></script>

<details>
  <summary>Commands</summary>

```bash
$ juju bootstrap microk8s <controller-name>
```
</details>
<br>

If you instead wants to add the microk8s cloud to an already deployed controller use this commnads:

```bash
$ microk8s.config | juju add-k8s <cloud-name> --controller <controller-name>
```

### Deploy COS-lite
After bootstrapping a new controller, we add a new model for COS-lite and then deploying COS stack inside that.
<!-- 4-deploy_coslite -->
<script async id="asciicast-gTsEEVbS6kEcLuX57cO9VdAgs" src="https://asciinema.org/a/gTsEEVbS6kEcLuX57cO9VdAgs.js"></script>

<details>
  <summary>Commands</summary>

```bash
$ juju add-model <model-name>
$ juju deploy cos-lite --trust --channel edge
```
</details>
<br>

To deploy COS-lite using overlays (pre-defined configurations), we can add `--overlay` to the command when deploying
<!-- 4-deploy_coslite_with_overlays -->
<script async id="asciicast-e1l0exQC2MMKAsyKi1L3mrxbH" src="https://asciinema.org/a/e1l0exQC2MMKAsyKi1L3mrxbH.js"></script>

<details>
  <summary>Commands</summary>

```bash
$ juju add-model <model-name>
$ juju deploy cos-lite --trust --channel edge --overlay ./path-to-overlay-file.yaml --overlay ./path-to-second-overlay-file.yaml
```
</details>
<br>

<!-- 5-coslite_offers -->
<script async id="asciicast-WzWPbKkWE7KUTor4fvkugSWPu" src="https://asciinema.org/a/WzWPbKkWE7KUTor4fvkugSWPu.js"></script>

<!-- 6-obeserved_charm -->
<script async id="asciicast-7EfUTw4xlZsi00Oc7dS6lC2s7" src="https://asciinema.org/a/7EfUTw4xlZsi00Oc7dS6lC2s7.js"></script>

<!-- 7-deploy_grafana-agent -->
<script async id="asciicast-WVysjssItuezm1JaDhk8uJoGR" src="https://asciinema.org/a/WVysjssItuezm1JaDhk8uJoGR.js"></script>

<!-- 8-consume_and_relate -->
<script async id="asciicast-XHAxz5Blyo9W8ozqpfLmaw9CR" src="https://asciinema.org/a/XHAxz5Blyo9W8ozqpfLmaw9CR.js"></script>