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

---

*This is a summary of what we talked about on the workshop [Learn how to integrate your charm with COS-lite all the way](https://discourse.charmhub.io/t/community-workshop-learn-how-to-integrate-your-charm-with-cos-lite-all-the-way/10917)*

---

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
<br><br>


### Install microk8s cloud
After that we continued with installing microk8s from snap
<!-- 2-install_microk8s -->
<script async id="asciicast-UR7KSN2lwa6Q5yyyu0luBI6hh" src="https://asciinema.org/a/UR7KSN2lwa6Q5yyyu0luBI6hh.js"></script>

**Commands used in video**

*Metallb is a load balancer and your gateway in to traefik. Traefik then points to services inside kubernetes. There is 3 ways to set IP-addresses, examples: 1. Static-IP: 192.168.0.3/32, 2. Subnet: 192.168.0.0/24, 3. IP-range: 192.168.0.10-192.168.0.20*
```bash
$ sudo snap install microk8s --classic
$ microk8s.enable dns hostpath-storage metallb:10.10.88.2-10.10.88.10
```
<br><br>


### Bootstrap a controller on microk8s cloud
Next, we bootstrapp a juju controller on the microk8s cloud
<!-- 3-bootstrap_controller -->
<script async id="asciicast-u6CSRmWH8FVmXikWNjG42IVhw" src="https://asciinema.org/a/u6CSRmWH8FVmXikWNjG42IVhw.js"></script>

**Commands used in video**
```bash
$ juju bootstrap microk8s <controller-name>
```
<br>

If you instead want to add the microk8s cloud to an already deployed controller use this commnads:
```bash
$ microk8s.config | juju add-k8s <cloud-name> --controller <controller-name>
```
<br><br>

### Deploy COS-lite
After bootstrapping a new controller, we add a new model for COS-lite and then deploying COS stack inside that.
<!-- 4-deploy_coslite -->
<script async id="asciicast-gTsEEVbS6kEcLuX57cO9VdAgs" src="https://asciinema.org/a/gTsEEVbS6kEcLuX57cO9VdAgs.js"></script>

**Commands used in video**
```bash
$ juju add-model <model-name>
$ juju deploy cos-lite --trust --channel edge
```
<br>

To deploy COS-lite using overlays (pre-defined configurations), we can add `--overlay` to the command when deploying. Here are some overlay [examples](https://github.com/canonical/cos-lite-bundle/tree/main/overlays)
<!-- 4-deploy_coslite_with_overlays -->
<script async id="asciicast-e1l0exQC2MMKAsyKi1L3mrxbH" src="https://asciinema.org/a/e1l0exQC2MMKAsyKi1L3mrxbH.js"></script>

**Commands used in video**
```bash
$ juju add-model <model-name>
$ juju deploy cos-lite --trust --channel edge --overlay ./path-to-overlay-file.yaml --overlay ./path-to-second-overlay-file.yaml
```
<br>

#### Connect to COS-lite services
Traefik is a reverse proxy, it get a gateway address from the metallb, which we can use to connect to grafana, prometheus and alertmanager. We can connect to the services by using the IP-address followed by model-name and application-name like this `https://10.10.88.2/cos-grafana`. I've noticed that some applications require adding unit number as well (ex. `cos-prometheus-0`).
<br>

#### Login to grafana
We can use actions to get the admin password to be able to login to grafana.
`juju run-action grafana/0 get-admin-password --wait`
<br><br>

### Make offers needed for grafana-agent
After having COS-lite deployed and ready, we can make offers of the endpoints needed for grafana-agent. Grafana-agent needs to be related to 3 endpoints to get out of it's blocked state.
<!-- 5-coslite_offers -->
<script async id="asciicast-WzWPbKkWE7KUTor4fvkugSWPu" src="https://asciinema.org/a/WzWPbKkWE7KUTor4fvkugSWPu.js"></script>

**Commands used in video**
```bash
$ juju offer grafana:grafana-dashboard [<offer-name>]
$ juju offer loki:logging [<offer-name>]
$ juju offer prometheus:receive-remote-write [<offer-name>]
$ juju status
```
<br><br>


### Build and deploy Observed charm
Observed is built by @eriklonroth as a reference charm to learn what COS-lite can do. It ships with a dashboard, prometheus & loki alert rule. To be able to build it you need a clone of the [repo](https://github.com/erik78se/juju-operators-examples/tree/main/observed) and [charmcraft](https://juju.is/docs/sdk/install-charmcraft). After building it we can deploy observed to a new model.
<!-- 6-obeserved_charm -->
<script async id="asciicast-7EfUTw4xlZsi00Oc7dS6lC2s7" src="https://asciinema.org/a/7EfUTw4xlZsi00Oc7dS6lC2s7.js"></script>

**Commands used in video**
```bash
$ juju add-model observed
$ juju deploy ./observed.charm
```
<br><br>


### Deploy and integrate grafana-agent
For observed to be able to send data to the COS-lite, we need to deploy are "bridge" between COS-lite and the charms. [Grafana-agent](https://charmhub.io/grafana-agent) is a subordinate charm that scrapes metrics, logs and dashboards and sends it to COS stack. [Charms need to support](https://discourse.charmhub.io/t/using-the-grafana-agent-machine-charm/8896) grafana-agent integrations for it to work, which observed does, so lets deploy and relate grafana-agent right now.
<!-- 7-deploy_grafana-agent -->
<script async id="asciicast-WVysjssItuezm1JaDhk8uJoGR" src="https://asciinema.org/a/WVysjssItuezm1JaDhk8uJoGR.js"></script>

**Commmands used in video**
```bash
$ juju deploy grafana-agent --channel edge
$ juju relate grafana-agent observed
$ juju status --relations
```
<br><br>


### Consuming and relating offers
We can now see that grafana-agent is deployed under observed but is showing a blocked status. To get out of the blocked status we need to consume the offers we made previously and relate those to grafana-agent.
<!-- 8-consume_and_relate -->
<script async id="asciicast-XHAxz5Blyo9W8ozqpfLmaw9CR" src="https://asciinema.org/a/XHAxz5Blyo9W8ozqpfLmaw9CR.js"></script>

**Commmands used in video**
```bash
$ juju find-offers <controller-name>:
$ juju consume [<controller-name>]:admin/cos.grafana-dashboard [<saas-name>]
$ juju consume [<controller-name>]:admin/cos.loki-logging [<saas-name>]
$ juju consume [<controller-name>]:admin/cos.prometheus-rrw [<saas-name>]
$ juju status
$ juju relate grafana-agent grafana-dashboard
$ juju relate grafana-agent loki-logging
$ juju relate grafana-agent prometheus-rrw
```
<br><br>


### Try out your new setup
After previous section it should now be possible to find new dashboards and alert rules in grafana. There should also be a dashboard called *Observed Microsample*. To trigger alert rules we can start to call observed charms api.

Curl Observed
```bash
$ curl http://<IP-ADDRESS-FOR-OBSERVED>:8080 # to return online
$ curl http://<IP-ADDRESS_FOR_OBSERVED>:8080/whatever # to return 404
# Example to trigger alerts for invalid api calls
$ while 1>0; do curl http://10.10.99.213:8080/fire; sleep 0.5; done
```
<br><br>

### Integrate alertmanager with other services
In the observed [repo](https://github.com/erik78se/juju-operators-examples/tree/main/observed) you can find [examples](https://github.com/erik78se/juju-operators-examples/tree/main/observed/src/alertmanager_configs) configurations for alertmanager that can enable integration with other services like slack and pagerduty to receive notifications. Use following command to push a configuration file to alertmanager.
```bash
$ juju config alertmanager config_file=@/path/to/file.yaml
```
To show or check current configuration:
```bash
$ juju run-action alertmanager/0 show-config
$ juju run-action alertmanager/0 check-config
```