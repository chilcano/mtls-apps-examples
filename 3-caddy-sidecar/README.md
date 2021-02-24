# Example 3. Using Caddy as Sidecar/Proxy for Microservices

Caddy as sidecar proxy for any kind of microservices to manage MTLS and Certificates

![](../img/mtls-caddy-sidecar-microservices-arch.png)


## Tools used

* Go
* Caddy v2 
* SmallStep Certificates (libraries already embeded in Caddy v2)
* Docker


## Steps

### 1. Install Caddy (Proxy/Sidecar) and CA

Caddy can be installed as a Linux service, the [binary can be downloaded](https://caddyserver.com/download) and embedded in applications or use it in a [Docker Container](https://hub.docker.com/_/caddy). This latest option is the way we are going to use along this Lab.

#### Install Docker

If your workstation **doesn't have Docker installed and running**, please, follow these commands.

```sh
$ curl gnupg-agent software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ sudo apt update
$ sudo apt -y install -y docker-ce docker-ce-cli containerd.io
$ sudo usermod -a -G docker $USER
$ sudo systemctl enable docker
```

#### Caddy in Docker 

Once installed Docker we are ready to use Caddy. Then, lets download the Caddy docker image:  

```sh
$ docker pull caddy

Using default tag: latest
latest: Pulling from library/caddy
Digest: sha256:925100cc9e08c8d79ee37b36abe21d2f554982d5bf302c55a38f5da971f53431
Status: Image is up to date for caddy:latest
docker.io/library/caddy:latest
```

Checking the downloaded Caddy docker image.
```sh
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
caddy               latest              2c73dc9258a8        7 weeks ago         39.5MB
```

### 2. Checking basic usage with Caddy in docker

```sh
$ cd 1-basic

$ echo "Hola amigo!" > index.html

$ docker run -d -p 81:80 \
    -v $PWD/index.html:/usr/share/caddy/index.html \
    -v caddy_data:/data \
    caddy
```

Checking if Caddy is running as a Docker process:
```sh
$ docker ps

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                   NAMES
cfd9b8b9a993        caddy               "caddy run --config …"   8 seconds ago       Up 8 seconds        443/tcp, 2019/tcp, 0.0.0.0:81->80/tcp   relaxed_cartwright
```

Checking if Caddy is serving `index.html` in the port `81`:
```sh
$ curl -i http://localhost:81

HTTP/1.1 200 OK
Accept-Ranges: bytes
Content-Length: 11
Content-Type: text/html; charset=utf-8
Etag: "qp1edyb"
Last-Modified: Wed, 24 Feb 2021 14:17:58 GMT
Server: Caddy
Date: Wed, 24 Feb 2021 14:23:37 GMT

Hola amigo!
```


### 2. Checking automatic TLS with Caddy in docker


```sh
$ cd 2-tls

$ mkdir site caddy_data caddy_config

$ echo "Hello friend!!" > site/index.html

$ docker run -d -p 82:80 -p 442:443 \
    -v $PWD/site:/srv \
    -v $PWD/caddy_data:/data \
    -v $PWD/caddy_config:/config \
    caddy caddy file-server --domain $HOSTNAME
```

Checking the caddy docker process:
```sh
$docker ps

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                NAMES
7080ba995f36        caddy               "caddy file-server -…"   9 seconds ago       Up 7 seconds        2019/tcp, 0.0.0.0:82->80/tcp, 0.0.0.0:442->443/tcp   nervous_euclid
cfd9b8b9a993        caddy               "caddy run --config …"   16 minutes ago      Up 16 minutes       443/tcp, 2019/tcp, 0.0.0.0:81->80/tcp                relaxed_cartwright
```

Checking TLS:
```sh
$ curl -iv http://inti.local:82
*   Trying 172.17.0.1:82...
* TCP_NODELAY set
* Connected to inti.local (172.17.0.1) port 82 (#0)
> GET / HTTP/1.1
> Host: inti.local:82
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 308 Permanent Redirect
HTTP/1.1 308 Permanent Redirect
< Connection: close
Connection: close
< Location: https://inti.local/
Location: https://inti.local/
< Server: Caddy
Server: Caddy
< Date: Wed, 24 Feb 2021 14:48:23 GMT
Date: Wed, 24 Feb 2021 14:48:23 GMT
< Content-Length: 0
Content-Length: 0

< 
* Closing connection 0


curl -i -v https://inti.local:442
*   Trying 172.17.0.1:442...
* TCP_NODELAY set
* Connected to inti.local (172.17.0.1) port 442 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (OUT), TLS alert, unknown CA (560):
* SSL certificate problem: unable to get local issuer certificate
* Closing connection 0
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```


### 3. Test Two-way TLS (Mutual TLS authentication)

TBC

## References

* tbc
