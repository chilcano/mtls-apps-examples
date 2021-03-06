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

REPOSITORY             TAG       IMAGE ID       CREATED        SIZE
caddy                  latest    88588539bb90   3 hours ago    39.5MB
codercom/code-server   latest    681a48e7bf50   3 weeks ago    838MB
wettyoss/wetty         latest    06a426b25e16   4 months ago   148MB
```

### 2. Checking basic usage with Caddy in docker

Caddy is able to server static files and work as proxy at the same time. Lets check if Caddy using this feature: 
```sh
$ docker run -d -p 8001:80 \
    -v $PWD/1-basic/hola.html:/usr/share/caddy/hola.html \
    --name caddy1 \
    caddy
```

Checking if Caddy is serving `site/hola.html` on the port `8001`:
```sh
$ curl -i http://localhost:8001/hola.html

HTTP/1.1 200 OK
Accept-Ranges: bytes
Content-Length: 12
Content-Type: text/html; charset=utf-8
Etag: "qpjzl3c"
Last-Modified: Sat, 06 Mar 2021 15:12:39 GMT
Server: Caddy
Date: Sat, 06 Mar 2021 15:19:21 GMT

Hola amigo!
```

Now, run another Caddy instance over the `8002` port and overwritting its `/etc/caddy/Caddyfile` config file: 
```sh
$ docker run -d -p 8002:80 \
    -v $PWD/1-basic/hola.html:/usr/share/caddy/hola.html \
    -v $PWD/1-basic/Caddyfile:/etc/caddy/Caddyfile \
    -v caddy_data:/data \
    --name caddy2 \
    caddy
```

Checking the Caddy docker processes are running:
```sh
$ docker ps

CONTAINER ID   IMAGE                         COMMAND                  CREATED          STATUS          PORTS                                     NAMES
a3ba303fbe6e   caddy                         "caddy run --config …"   59 seconds ago   Up 59 seconds   443/tcp, 2019/tcp, 0.0.0.0:8002->80/tcp   caddy2
a433bf9e14c3   caddy                         "caddy run --config …"   4 minutes ago    Up 4 minutes    443/tcp, 2019/tcp, 0.0.0.0:8001->80/tcp   caddy1
```

Remove recently created container:  
```sh
$ docker rm -f caddy1 caddy2
```

### 2. Checking automatic TLS with Caddy in docker


```sh
## $ mkdir site caddy_data caddy_config

$ docker run -d -p 82:80 -p 442:443 \
    -v $PWD/site:/srv \
    -v $PWD/caddy_data:/data \
    -v $PWD/caddy_config:/config \
    --name caddy-82 \
    caddy caddy file-server --domain $HOSTNAME


$ docker run -d -p 84:80 -p 444:443 \
    -v $PWD/site:/srv \
    -v $PWD/caddy_data:/data \
    -v $PWD/caddy_config:/config \
    --name caddy-84 \
    caddy caddy file-server --domain funny-panda.devopsplayground.org

$ docker run -d -p 85:80 -p 8445:443 \
    -v $PWD/site/index.html:/usr/share/caddy/index.html \
    --name caddy-85 \
    caddy caddy file-server --domain $HOSTNAME

docker run -d -p 8443:443 \
    -v $PWD/site/index.html:/usr/share/caddy/index.html \
    --name caddy-86 \
    caddy caddy file-server --domain $HOSTNAME
```

Checking the caddy docker process:
```sh
$docker ps

CONTAINER ID   IMAGE                         COMMAND                  CREATED              STATUS              PORTS                                                NAMES
bd8c3af50661   caddy                         "caddy file-server -…"   6 seconds ago        Up 5 seconds        2019/tcp, 0.0.0.0:82->80/tcp, 0.0.0.0:442->443/tcp   caddy-82
e1a87e6e508d   caddy                         "caddy run --config …"   About a minute ago   Up About a minute   443/tcp, 2019/tcp, 0.0.0.0:81->80/tcp                caddy-81
```

Checking HTTP and TLS:  

```sh
$ curl -iv http://$HOSTNAME:82

* Rebuilt URL to: http://playground:82/
*   Trying 10.0.10.83...
* TCP_NODELAY set
* Connected to playground (10.0.10.83) port 82 (#0)
> GET / HTTP/1.1
> Host: playground:82
> User-Agent: curl/7.58.0
> Accept: */*
> 
< HTTP/1.1 308 Permanent Redirect
HTTP/1.1 308 Permanent Redirect
< Connection: close
Connection: close
< Location: https://playground/
Location: https://playground/
< Server: Caddy
Server: Caddy
< Date: Sat, 06 Mar 2021 11:54:40 GMT
Date: Sat, 06 Mar 2021 11:54:40 GMT
< Content-Length: 0
Content-Length: 0

< 
* Closing connection 0
```
Since Caddy has generated succesfully a TLS certificate for $HOSTNAME, Caddy is redirecting the traffic to the HTTPS site.  
Let's call to the HTTPS site:  
```sh
$ curl -iv https://$HOSTNAME:442

* Rebuilt URL to: https://playground:442/
*   Trying 10.0.10.83...
* TCP_NODELAY set
* Connected to playground (10.0.10.83) port 442 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS alert, Server hello (2):
* error:14094438:SSL routines:ssl3_read_bytes:tlsv1 alert internal error
* stopped the pause stream!
* Closing connection 0
curl: (35) error:14094438:SSL routines:ssl3_read_bytes:tlsv1 alert internal error
```


### 3. Test Two-way TLS (Mutual TLS authentication)

TBC

## References

* tbc
