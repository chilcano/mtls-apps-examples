# Examples of MTLS on Applications

This repository contains 2 simple applications (REST microservices in Java and Go) used to explain the implementation of Mutual TLS Authentication.

| Application             | Description
| ---                     | ---         
| 1-greeting-java         | Simple REST microservice (Maven Project) based on Spring Boot 2.4.2 and Java 11. 
| 2-two-uservices-go      | Two Go microservices


## Preparation

Clone the repository.
```sh
## clone the repo
$ git clone https://github.com/chilcano/mtls-apps-examples
```

Install Java 11, Maven and Go.
```sh
$ source <(curl -s https://raw.githubusercontent.com/chilcano/how-tos/master/src/devops_playground_tools_install.sh) 
```

## Getting started with the 'Java Greeting REST service'

### Saying greeting (without encryption in transit)

1. Check the REST service (`src/main/resources/application.yml`) configuration. You should have this configuration:  
```yaml
server:
  port: 9090
``` 

2. Clean and build the project for the first time.
```sh
$ cd mtls-apps-examples/1-greeting-java 
$ mvn clean
$ mvn spring-boot:run
``` 

3. Calling the REST service.  
```sh
$ curl -i http://localhost:9090/greeting
```

4. It should give you the following response:  
```sh
HTTP/1.1 200 
Content-Type: application/json
Transfer-Encoding: chunked
Date: Tue, 16 Feb 2021 13:41:15 GMT

{"id":1,"content":"Hello, World!"}
```

5. Close the running REST service typing `Ctrl + C`.   

### Enabling HTTP over TLS (HTTPS) on the service (One-way TLS)

1. Update the `src/main/resources/application.yml` to enable One-way TLS.   
```yaml
server:
  port: 9443
  ssl:
    enabled: true
``` 

2. Restart the REST service so that it can apply the changes and test it.   
```sh
$ mvn clean spring-boot:run
$ curl -i https://localhost:9443/greeting
``` 

We will probably get the following error:
```sh
Caused by: java.lang.IllegalArgumentException: Resource location must not be null
        at org.springframework.util.Assert.notNull(Assert.java:201) ~[spring-core-5.3.3.jar:5.3.3]
        at org.springframework.util.ResourceUtils.getURL(ResourceUtils.java:130) ~[spring-core-5.3.3.jar:5.3.3]
        at org.springframework.boot.web.embedded.tomcat.SslConnectorCustomizer.configureSslKeyStore(SslConnectorCustomizer.java:129) ~[spring-boot-2.4.2.jar:2.4.2]
        ... 16 common frames omitted
```

We are getting this message because the REST service (server) requires a keystore with the certificate of the REST service (server) to ensure that there is a secure connection with the outside world.  
To solve this, we are going to create a keystore with a public and private key for the REST service (server). The public key will be shared with users/clients so that they can encrypt the communication. 
The communication between both parties (user and server) can be decrypted with the private key of the REST service (server). 
The private key of the REST service (server) never must be shared and must be keep it secret, symmetrically encrypted or in a vault (i.e. PKCS#7, HSM, Hashicorp Vault).

3. Generate a TLS Certificate.   

Any Java application use [keystore](https://en.wikipedia.org/wiki/Java_KeyStore) file as repository of public-key certificates and asymmetric private keys. Then, to create a keystore with a public and private key, execute the following command in your terminal:
```sh
$ keytool -v \
        -genkeypair \
        -dname "CN=MTLS for Java Microservice,OU=DevOps Playground,O=ECS,C=UK" \
        -keystore src/main/resources/identity.jks \
        -storepass secret \
        -keypass secret \
        -keyalg RSA \
        -keysize 2048 \
        -alias server \
        -validity 3650 \
        -deststoretype pkcs12 \
        -ext KeyUsage=digitalSignature,dataEncipherment,keyEncipherment,keyAgreement \
        -ext ExtendedKeyUsage=serverAuth,clientAuth \
        -ext SubjectAlternativeName:c=DNS:localhost,IP:127.0.0.1
```

If all goes well, you should see this:
```sh
Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 3,650 days
        for: CN=MTLS for Java Microservice, OU=DevOps Playground, O=ECS, C=UK
[Storing src/main/resources/identity.jks]
```

Now, you need update the REST service (server) `src/main/resources/application.yml` file with the location of the keystore and symmetric passwords required for keystore itself and private key.  
```yaml
server:
  port: 9443
  ssl:
    enabled: true
    key-store: classpath:identity.jks
    key-password: secret
    key-store-password: secret
```

4. Test the One-way TLS connection.   
```sh
$ mvn clean spring-boot:run
$ curl -i --insecure -v https://localhost:9443/greeting
## alternatively with '-k' option
$ curl -i -k -v https://localhost:9443/greeting
``` 

If everything has worked, then you should see this:
```sh
*   Trying 127.0.0.1:9443...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server did not agree to a protocol
* Server certificate:
*  subject: C=UK; O=ECS; OU=DevOps Playground; CN=MTLS for Java Microservice
*  start date: Feb 16 14:59:31 2021 GMT
*  expire date: Feb 14 14:59:31 2031 GMT
*  issuer: C=UK; O=ECS; OU=DevOps Playground; CN=MTLS for Java Microservice
*  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
> GET /greeting HTTP/1.1
> Host: localhost:9443
> User-Agent: curl/7.68.0
> Accept: */*
> 
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 
HTTP/1.1 200 
< Content-Type: application/json
Content-Type: application/json
< Transfer-Encoding: chunked
Transfer-Encoding: chunked
< Date: Tue, 16 Feb 2021 15:17:41 GMT
Date: Tue, 16 Feb 2021 15:17:41 GMT

< 
* Connection #0 to host localhost left intact
{"id":1,"content":"Hello, World!"}
```

Now, if we remove the `--insecure` or `-k` we will get this error:
```sh
$ curl -i https://localhost:9443/greeting

curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

That means `curl` (client) can not get validate the REST service's TLS certificate because the client don't have or don't trust the CA that issued the REST service certificate.
And if you open `https://localhost:9443/greeting` in your browser (another client) you will get similar error (see below image).

![](img/mtls-java-1-err-cert-authority-invalid.png)

To avoid this, you need to have the certificate(s) of the server and you can get it with the following command:
```sh
$ keytool -v \
    -exportcert \
    -file src/main/resources/server.crt \
    -alias server \
    -keystore src/main/resources/identity.jks \
    -storepass secret \
    -rfc 

Certificate stored in file <src/main/resources/server.crt>
```

Now, install `src/main/resources/server.crt` in your browser or use it with curl command to call the REST service.
```sh
$ curl -i --cacert src/main/resources/server.crt https://localhost:9443/greeting

HTTP/1.1 200 
Content-Type: application/json
Transfer-Encoding: chunked
Date: Tue, 16 Feb 2021 17:31:37 GMT

{"id":3,"content":"Hello, World!"}
```


### Enabling Mutual TLS Authentication

```sh

``` 



## References

### Go
* https://kofo.dev/how-to-mtls-in-golang
* https://venilnoronha.io/a-step-by-step-guide-to-mtls-in-go
* https://github.com/nicholasjackson/mtls-go-example
* https://smallstep.com/hello-mtls/doc/server/go

### Java
* https://spring.io/guides/gs/rest-service/