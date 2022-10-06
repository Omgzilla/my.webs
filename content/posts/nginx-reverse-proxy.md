---
title: "Nginx Reverse Proxy"
subtitle: ""
date: 2022-10-06T03:27:30+02:00
lastmod: 2022-10-06T03:27:30+02:00
draft: false
author: "Ohmygodzilla"
authorLink: ""
description: ""
images: []

tags: [web server, reverse-proxy, proxy, nginx]
# ubuntu, database, sql, cheat-sheet, docker, container
categories: [documentation]
# cheat-sheet, documentation

featuredImage: "images/nginx-reverse-proxy.webp"
featuredImagePreview: "images/nginx-reverse-proxy.webp"

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

# Nginx Reverse Proxy
This is a guide on how to install nginx as a reverse proxy.

## Install nginx
**Arch**
```bash
sudo pacman -Sy #Update repository
sudo pacman -S nginx #Install package
```

**Ubuntu**
```bash
sudo apt-get update #Update repository
sudo apt-get install nginx #Install package
```

_**Unlink defult configuration on ubuntu (optional)**_
```bash
sudo unlink /etc/nginx/sites-enabled/default
```

## Edit default configuration file
```bash
sudo nvim /etc/nginx/sites-available/default
```

**Copy and paste**
```nginx
server { 
	listen 80;
	listen [::]:80;
	access_log /var/log/nginx/default-access.log; #Change name
	error_log /var/log/nginx/default-error.log; #Change name
	location / { 
		proxy_pass http://127.0.0.1:8000; #Address to host
	}
}
```
*Save and exit*

### Copy default
```bash
sudo cp /etc/nginx/sites-available/default /etc/sites-available/example.com.conf
```

**Edit configuration**
```bash
sudo nvim /etc/nginx/sites-available/example.com.conf
```

## Enable your site
**Symlink configuration file**
```bash
sudo ln -s /etc/nginx/sites-available/example.com.conf /etc/nginx/sites-enabled/example.com.conf
```

## Check configuration file for errors
```bash
sudo nginx -t
```
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```


## [Adding TLS to your Nginx Reverse Proxy using Let’s Encrypt](https://www.scaleway.com/en/docs/tutorials/nginx-reverse-proxy/#adding-tls-to-your-nginx-reverse-proxy-using-let's-encrypt)

> **Important:** Make sure your domain name points towards your server ip (A or AAAA record).

With the current setup, all incoming traffic on the standard, non-securized, HTTP port is anserwered by Nginx, which passes it to the web application on the Instance.

For security reasons, it is recommended to add an encryption layer with TLS/SSL and to use HTTPS. Whilst it is technically possible to use self-signed certificates, it may cause inconveniences as a warning is displayed by default in a user’s web browser when a self-signed certificate is used. A certificate authenticity (CA) can issue trusted certificates which are recognized by most modern web browsers. The CA [Let’s Encrypt](https://letsencrypt.org/) provides TLS certificates for free and the configuration of Nginx can be done easily with [Certbot](https://certbot.eff.org/), a tool provided by the [EFF](https://www.eff.org/).

1.  Install Certbot on your Instance by using the APT packet manager:

```
apt-get update
apt-get install software-properties-common
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install python3-certbot-nginx
```

2.  Certbot provides a plugin designed for the Nginx web server, automatizing most of the configuration work related with requesting, installing and managing the TLS certificate:

```
certbot --nginx
```

3.  Answer the prompts that display on the screen to request a valid Let’s Encrypt TLS certificate:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: your.domain.com
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/
or spaces, or leave input blank to select all options shown 
(Enter 'c' to cancel): 1
Obtaining a new certificate
Performing the following challenges:http-01 challenge for your.domain.com
Waiting for verification...Cleaning up challenges
Deploying Certificate to VirtualHost /etc/nginx/sites-enabled/reverse-proxy.conf
Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
snew sites, or if you're confident your site works on HTTPS. You can undo this
change by editing your web server's configuration.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 2
Redirecting all traffic on port 80 to ssl in /etc/nginx/sites-enabled/reverse-proxy.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-Congratulations! You have successfully enabled https://your.domain.com
You should test your configuration at: https://www.ssllabs.com/ssltest/analyze.html?d=your.domain.com
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

**Note:** 
	When asked if you want to redirect HTTP traffic automatically to HTTPS, choose the option **2**. This enables the automatic redirection of all incoming requests via an unencrypted HTTP connection to a secure HTTPS connection. Providing an additional layer of security for the Web application running behind the Nginx reverse proxy.



## [Nginx reverse proxy example configuration](https://www.acunetix.com/blog/web-security-zone/hardening-nginx/)
You can set up your Nginx configuration file using different parameters and headers.

The following example shows common parameters used in `nginx.conf` with a reverse proxy configuration:
```nginx
location/ {
	proxy_pass http://127.0.0.1:3000;
	proxy_http_version    1.1;
	proxy_cache_bypass    $http_upgrade;
	proxy_set_header Host              $host;
	proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
	proxy_set_header X-Real-IP         $remote_addr;
	proxy_set_header X-Forwarded-Host  $host;
	proxy_set_header X-Forwarded-Proto $scheme;
	proxy_set_header X-Forwarded-Port  $server_port;  }
```

Where:
-   `proxy_http_version` - Defines the HTTP protocol version (the default is set to 1.0)
-   `proxy_cache_bypass` - This configuration allows responses to bypass cache.
-   `Host $host` - The `$host` variable contains, in order of precedence: the host name from the request line, or the host name from the “Host” request header field, or the server name matching a request.
-   `X-Forwarded-For $proxy_add_x_forwarded_for` - Defines the address of the client connected to the proxy.
-   `X-Real-IP $remote_addr` - Contains the client IP address. It forwards the real visitor remote IP address to the proxied server.
-   `X-Forwarded-Host $host` - Defines the original host requested by the client.
-   `X-Forwarded-Proto $scheme` - If defined in an HTTPS server block, the HTTP responses from the proxied server are rewritten to HTTPS.
-   `X-Forwarded-Port $server_port` - Defines the original port requested by the client.


## How to harden your server configuration
### Step 1. Disable any unwanted nginx modules
When you install nginx, it automatically includes many modules. Currently, you cannot choose modules at runtime. To disable certain modules, you need to recompile nginx. We recommend that you disable any modules that are not required as this will minimize the risk of potential attacks by limiting allowed operations. 

To do this, use the _configure_ option during installation. In the example below, we disable the _autoindex_ module, which generates automatic directory listings, and then recompile nginx.

```
# ./configure --without-http_autoindex_module
# make
# make install
```

### Step 2. Disable nginx server_tokens
By default, the _server_tokens_ directive in nginx displays the nginx version number. It is directly visible in all automatically generated error pages but also present in all HTTP responses in the _Server_ header.

This could lead to information disclosure – an unauthorized user could gain knowledge about the version of nginx that you use. You should disable the _server_tokens_ directive in the nginx configuration file by setting `server_tokens off`.

### Step 3. Control Resources and limits
To prevent potential DoS attacks on nginx, you can set buffer size limitations for all clients. You can do this in the nginx configuration file using the following directives:

-   _client_body_buffer_size_ – use this directive to specify the client request body buffer size. The default value is 8k or 16k but it is recommended to set this as low as 1k: `client_body_buffer_size 1k`.
-   _client_header_buffer_size_ – use this directive to specify the header buffer size for the client request header. A buffer size of 1k is adequate for most requests.
-   _client_max_body_size_ – use this directive to specify the maximum accepted body size for a client request. A 1k directive should be sufficient but you need to increase it if you are receiving file uploads via the POST method.
-   _large_client_header_buffers_ – use this directive to specify the maximum number and size of buffers to be used to read large client request headers. A `large_client_header_buffers 2 1k` directive sets the maximum number of buffers to 2, each with a maximum size of 1k. This directive will accept 2 kB data URI.

**Note**: Some sources suggest that setting such limits may prevent potential [buffer overflow attacks](https://www.acunetix.com/blog/web-security-zone/what-is-buffer-overflow/) if such vulnerabilities are found in nginx.

### Step 4. Disable any unwanted HTTP methods
We suggest that you disable any HTTP methods, which are not going to be utilized and which are not required to be implemented on the web server. If you add the following condition in the location block of the nginx virtual host configuration file, the server will only allow GET, HEAD, and POST methods and will filter out methods such as DELETE and TRACE.

```
location / {
	limit_except GET HEAD POST { deny all; }
}
```

Another approach is to add the following condition to the _server_ section (or server block). It can be regarded as more universal but [you should be careful with `if` statements in the location context](https://www.nginx.com/resources/wiki/start/topics/depth/ifisevil/).

```
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
    return 444; }
```

### Step 5. Install ModSecurity for your nginx web server
ModSecurity is an open-source module that works as a web application firewall. Its functionalities include filtering, server identity masking, and null-byte attack prevention. The module also lets you perform real-time traffic monitoring. We recommend that you follow the [ModSecurity manual](https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual) to install the _mod_security_ module in order to strengthen your security options.

Note that if ModSecurity does not meet your needs, you can also use [other free WAF solutions](https://github.com/wallarm/awesome-nginx-security#waf-for-nginx-protect-apis-websites-web-applicatons).

### Step 6. Set up and configure nginx access and error logs
The nginx access and error logs are enabled by default and are located in _logs/error.log_ and _logs/access.log_ respectively. If you want to change the location, you can use the _error_log_ directive in the nginx configuration file. You can also use this directive to specify the logs that will be recorded according to their severity level. For example, a _crit_ severity level will cause nginx to log critical issues and all issues that have a higher severity level than _crit_. To set the severity level to _crit_, set the _error_log_ directive as follows:

```
error_log logs/error.log crit;
```

You can find a complete list of _error_log_ severity levels in [official nginx documentation](http://nginx.org/en/docs/ngx_core_module.html#error_log).

You can also modify the _access_log_ directive in the nginx configuration file to specify a non-default location for access logs. Finally, you can use the _log_format_ directive to configure the format of the logged messages as explained [in nginx documentation](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format).

### Step 7. Configure nginx to include security headers
To additionally harden your nginx web server, you can add several different HTTP headers. Here are some of the options that we recommend.

#### X-Frame-Options
You use the _X-Frame-Options_ HTTP response header to indicate if a browser should be allowed to render a page in a _`<frame>`_ or an _`<iframe>`_. This could prevent clickjacking attacks. Therefore, we recommend that you enable this option for your nginx server. 

To do this, add the following parameter to the nginx configuration file in the _server_ section:
```
add_header X-Frame-Options "SAMEORIGIN";
```

#### Strict-Transport-Security
[HTTP Strict Transport Security (HSTS)](https://www.acunetix.com/blog/articles/what-is-hsts-why-use-it/) is a method used by websites to declare that they should only be accessed using a secure connection (HTTPS). If a website declares an HSTS policy, the browser must refuse all HTTP connections and prevent users from accepting insecure SSL certificates. To add an HSTS header to your nginx server, you can add the following directive to your server section:
```
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";
```

#### CSP and X-XSS-Protection
Content Security Policy (CSP) protects your web server against certain types of attacks, including [Cross-site Scripting attacks](https://www.acunetix.com/websitesecurity/cross-site-scripting/) (XSS) and data injection attacks. You can implement CSP by adding the following example _Content-Security-Policy_ header (note that the actual header should be configured to match your unique requirements):
```
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

The HTTP _X-XSS-Protection_ header is supported by IE and Safari and is not necessary for modern browsers if you have a strong Content Security Policy. However, to help prevent XSS in the case of older browsers (that don’t support CSP yet), you can add the X-XSS Protection header to your _server_ section:
```
add_header X-XSS-Protection "1; mode=block";
```

### Step 8. Configure SSL and Cipher suites
The default configuration of nginx allows you to use insecure old versions of the TLS protocol (according to the [official documentation](http://nginx.org/en/docs/http/configuring_https_servers.html): ssl_protocols TLSv1 TLSv1.1 TLSv1.2). This may lead to attacks such as the [BEAST attack](https://www.acunetix.com/blog/web-security-zone/what-is-beast-attack/). Therefore, we recommend that you do not use old TLS protocols and change your configuration to support only newer, secure TLS versions.

To do this, add the following directive in the _server_ section of the nginx configuration file:
```
ssl_protocols TLSv1.2 TLSv1.3;
```

Additionally, you should specify cipher suites to make sure that no vulnerable suites are supported. To select the best cipher suites, [read our article on TLS cipher hardening](https://www.acunetix.com/blog/articles/tls-ssl-cipher-hardening/) and add a _ssl_ciphers_ directive to the _server_ section to select the ciphers (as suggested in the [article on cipher hardening](https://www.acunetix.com/blog/articles/tls-ssl-cipher-hardening/)). We also recommend that you add the following directive to the _server_ section:
```
ssl_prefer_server_ciphers on;
```

This directive will let the decision on which ciphers to use be made server-side not client-side.

### Step 9. Update your server regularly
As with any other software, we recommend that you always update your nginx server to the latest stable version. New updates often contain fixes for vulnerabilities identified in previous versions, such as the [directory traversal vulnerability](https://www.acunetix.com/websitesecurity/directory-traversal/) ([CVE-2009-3898](https://www.cvedetails.com/cve/CVE-2009-3898/)) that existed in nginx versions prior to 0.7.63, and 0.8.x before 0.8.17. Updates also frequently include new security features and improvements. On the nginx.org site, you can [find security advisories in a dedicated section](http://nginx.org/en/security_advisories.html) and news about the latest updates on the main page.

### Step 10. Check your configuration with Gixy
Gixy is an open-source tool that lets you check your nginx web server for typical misconfigurations. After you prepare your nginx configuration, it is always a good idea to check it with Gixy. [You can find Gixy here](https://github.com/yandex/gixy).

### Step 11. You don't have to do it manually
If you don’t want to configure nginx manually, you can use a free online visual configuration tool made available by DigitalOcean. [You can find this tool here](https://www.digitalocean.com/community/tools/nginx).
