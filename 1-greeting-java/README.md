# Example 1. Enabling MTLS on Spring Boot (Java) REST service

This is a simple REST microservice (Maven Project) based on Spring Boot 2.4.2 and Java 11. 

![](../img/mtls-java-0-greeting-microservice-arch.png)

## Tools used

* OpenJDK 11 and Spring Boot to create the microservice.
* Java KeyTool to generate key-pairs, private and public keys, public key certificates and import, export and encode key material.
* OpenSSL to convert certificates to PEM/DER formats.
* Maven to build and run the application.


## Steps

First of all, open 3 Browser tabs, in 2 of them open a [Wetty Terminal](../) and in both go to the working directory for this example. In the 3rd Browser tab open the [Code-Server](../):

```sh
cd $HOME/workdir/mtls-apps-examples/1-greeting-java 
```

Also make sure the owner of all files and directories under `workdir` is `$USER`, if the owner is `root` the labs will not work.  
You can set up a owner using this command: `sudo chown -R $USER $HOME/workdir/`


### I. Saying greeting (without encryption in transit)

#### 1. Check initial configuration of REST service.


```sh
cat src/main/resources/application.yml
```

You should have:
```yaml
server:
  port: 9090
``` 

#### 2. Clean and build the project.  


```sh
mvn clean spring-boot:run
``` 

#### 3. Calling the REST service.  


In other Wetty Terminal, execute this:
```sh
curl -i http://localhost:9090/greeting
```

It should give you the following response:  

```sh
HTTP/1.1 200 
Content-Type: application/json
Transfer-Encoding: chunked
Date: Tue, 16 Feb 2021 13:41:15 GMT

{"id":1,"content":"Hello, World!"}
```

#### 4. Close the running REST service.

Just type `Ctrl + C`.   


### II. HTTP over TLS (One-way TLS)

#### 1. Generate the server certificate.   

Any Java application use [keystore](https://en.wikipedia.org/wiki/Java_KeyStore) file as repository of public-key certificates and asymmetric private keys. Then, to create a keystore with a public and private key, execute the following command in your terminal:
```sh
keytool -v \
        -genkeypair \
        -dname "CN=Server (MTLS for Java Microservice),OU=DevOps Playground,O=ECS,C=UK" \
        -keystore src/main/resources/server_identity.p12 \
        -storepass secret \
        -keypass secret \
        -keyalg RSA \
        -keysize 2048 \
        -alias server \
        -validity 3650 \
        -deststoretype PKCS12 \
        -ext KeyUsage=digitalSignature,dataEncipherment,keyEncipherment,keyAgreement \
        -ext ExtendedKeyUsage=serverAuth,clientAuth \
        -ext SubjectAlternativeName:c=DNS:localhost,IP:127.0.0.1

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 3,650 days
        for: CN=MTLS for Java Microservice, OU=DevOps Playground, O=ECS, C=UK
[Storing src/main/resources/server_identity.p12]
```

> **Important:**   
>   
> We have to create a keystore with a public and private key for the REST service (server). The public key will be shared with users/clients so that they can encrypt the communication.  
> The communication between both parties (user and server) can be decrypted with the private key of the REST service (server).  
> The private key of the REST service (server) never must be shared and must be keep it secret, symmetrically encrypted or in a vault (i.e. PKCS#7, HSM, Hashicorp Vault).

#### 2. Update the REST service onfiguration file.

Once generated the TLS certificate, you will need to update the REST service (server) `src/main/resources/application.yml` file with the location of the keystore and symmetric passwords required for keystore itself and for private key.  
```yaml
nano src/main/resources/application.yml
```

```yaml
server:
  port: 9443
  ssl:
    enabled: true
    key-store: classpath:server_identity.p12
    key-password: secret
    key-store-password: secret
```

#### 3. Run the REST service and test the One-way TLS connection.   

```sh
mvn clean spring-boot:run
```

In other Wetty Terminal execute this:
```sh
curl --insecure -v https://localhost:9443/greeting

## alternatively with '-k' option
curl -k https://localhost:9443/greeting

{"id":1,"content":"Hello, World!"}
```

Now, if we remove the `--insecure` or `-k` we will get this error:
```sh
curl https://localhost:9443/greeting

curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

> **Important:**   
>   
> That means `curl` (client) can not get validated the REST service's TLS certificate because the client don't have or don't trust the CA that issued the server certificate.

To avoid this error, you need to get the certificate(s) of the server and store it in the trusted CA certificate store of your curl and/or browser.  
You can get the server certificate with the following command. Execute it from `$HOME/workdir/mtls-apps-examples/1-greeting-java`:
```sh
keytool -v \
    -exportcert \
    -file src/main/resources/server.crt \
    -alias server \
    -keystore src/main/resources/server_identity.p12 \
    -storepass secret \
    -rfc 

Certificate stored in file <src/main/resources/server.crt>
```

Now, install `src/main/resources/server.crt` in the trusted CA certificate store that curl uses.  
```sh
curl --cacert src/main/resources/server.crt \
       --capath /etc/ssl/certs/ \
        https://localhost:9443/greeting
```

Unfortunately curl still will show same error about `verify the legitimacy of the server` because, curl doesn't validate self-signed certificates, despite installing it in the CA certificate store. 
However, you would bypass this using Browser instead of curl.

Install CA certificates in the trusted CA certificate store and make available to curl requires compile curl from source code. The process is explained in below links in References section.



### III. Enabling Mutual TLS Authentication (Two-way TLS)

The configuration of MTLS (Two-way TLS) in the server will require a new certificate for the authentication of the client. 
This configuration will force the client (curl, your browser or any proper HTTP client) to identify itself using a certificate, and in that way, the server (REST service) 
can also validate the identity of the client and whether or not it is a trusted one. 
You can get this by configuring the server (REST service) that you also want to validate the client with the property `client-auth` in the `src/main/resources/application.yml` file.   

#### 1. Generating a client certificate.  

We are going to use ``Java KeyTool` to create a new client self-signed certificate. Use the following command:

```sh
keytool -v \
        -genkeypair \
        -dname "CN=Client (MTLS for Java Microservice),OU=DevOps Playground,O=ECS,C=UK" \
        -keystore src/main/resources/client_identity.p12 \
        -storepass secret \
        -keypass secret \
        -keyalg RSA \
        -keysize 2048 \
        -alias client \
        -validity 3650 \
        -deststoretype PKCS12 \
        -ext KeyUsage=digitalSignature,dataEncipherment,keyEncipherment,keyAgreement \
        -ext ExtendedKeyUsage=serverAuth,clientAuth 
```

> The above command will not add the `SubjectAlternativeName` attribute to the client certificate (`-ext SubjectAlternativeName:c=DNS:<client-fqdn>,IP:<client-ip-address>`) because the client (curl or browser) will be executed in the same host where the REST service is running. But if you want to execute the client (curl or browser) from different host, you could set a `SubjectAlternativeName` attribute with a `fqdn`, `hostname` or `IP address` what the REST service (server) can resolve and validate without issues.   
> You can simulate this behaviour when running the client and server in the same host, only you have to add as client's hostname and server's hostname to the `/etc/hosts` file.

Once the `client_identity.p12` (private key and public key certificate) has been generated, we must tell the server about which root and intermediate certificates to trust. This is done creating a `truststore` containing all those trusted certificates. We can get the client certificate extracting it from previously generated `client_identity.p12`.

#### 2. Extract the client certificate from `client_identity.p12`.  

The `client_identity.p12` file containts the key-pair (private and public key) and the public key certificate. We need run the below command to get only the publick key certificate.
```sh
keytool -v \
        -exportcert \
        -file src/main/resources/client.crt \
        -alias client \
        -keystore src/main/resources/client_identity.p12 \
        -storepass secret \
        -rfc 
```

#### 3. Create the server `truststore` with the client certificate.   

The `truststore`, in `JKS` format, file must contain all certificates that are trusted, and since we have 2 self-signed certificates (client and server) in this Lab, the `truststore` will be the same for the client and server.
```sh
keytool -v \
        -importcert \
        -file src/main/resources/client.crt \
        -alias client \
        -keystore src/main/resources/server_truststore.jks \
        -storepass secret \
        -noprompt
```

#### 4. Update the server configuration file.


Update the server configuration:

```yaml
nano src/main/resources/application.ym
```

```yaml
server:
  port: 9443
  ssl:
    enabled: true
    key-store: classpath:server_identity.p12
    key-password: secret
    key-store-password: secret
    client-auth: need                             ## require client authn
    trust-store: classpath:server_truststore.jks  ## trusted root and intermediate certs store
    trust-store-password: secret
``` 

#### 5. Get the client private key in PEM format. 

> Since `cURL` only sopports `PEM`, `DER` and `ENG` and all `*.crt` files in format `PEM` and doesn't support `Java KeyStore` files containing key material (`*.jks`). We need to extract the client private key in `PEM` format from `client_identity.p12` file.
> Only if that is the case, we need to convert the `JKS` to ``PKCS12` and then extract the private key from the `PKCS12`. 
> Then, the next `keytool` command only is necessary if the previous `Java KeyStore` file was created in `JKS` format. In our case all `Java KeyStore` files were create with the `-deststoretype PKCS12` flag, so that **next command is not necessary**.   

```sh
keytool -importkeystore \
        -srckeystore src/main/resources/client_identity.jks \
        -destkeystore src/main/resources/client_identity.p12 \
        -srcstoretype JKS \
        -deststoretype PKCS12 \
        -srcstorepass secret \
        -deststorepass secret \
        -srcalias client \
        -destalias client \
        -srckeypass secret \
        -destkeypass secret \
        -noprompt
```

Get the `PEM` file from `client_identity.p12` that holds only the client private key.
```sh
openssl pkcs12 \
          -in src/main/resources/client_identity.p12 \
          -out src/main/resources/client_identity.pem \
          -passin pass:secret \
          -passout pass:secret \
          -nocerts
```

#### 6. Finally, you are able to call to the REST service to test MTLS.   

Restart the server:
```sh
mvn clean spring-boot:run
```

In other terminal execute curl.
```sh
curl --cacert src/main/resources/server_fqdn.crt \
       --key src/main/resources/client_identity.pem \
       --cert src/main/resources/client.crt \
       https://localhost:9443/greeting

Enter PEM pass phrase:

curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

The above error happens because the server certificate's SAN doesn't match the REST service's domain name. Lets bypass this error for a moment and use `-k` flag to check if the REST service and MTLS are working.

```sh
curl -k --cacert src/main/resources/server_fqdn.crt \
       --key src/main/resources/client_identity.pem \
       --cert src/main/resources/client.crt \
       https://localhost:9443/greeting

Enter PEM pass phrase:

{"id":2,"content":"Hello, World!"}
```

#### 9. Testing MTLS using the Client PKCS12 (key-pair).  

To take advantage of `--cert <certificate[:password]>` flag and avoid prompt for the private key's passphrase, we could generate a `PKCS12` file in `PEM` format with a passphrase containing the certificate and use all together according the previous flag (`--cert <certificate[:password]>`). To use it, only follow the next command:

```sh
openssl pkcs12 \
          -in src/main/resources/client_identity.p12 \
          -out src/main/resources/client_identity.pem \
          -passin pass:secret \
          -passout pass:secret
```

Finally, execute curl again passing the passphrase using the aforementioned flag `--cert <certificate[:password]>`:   
```sh
curl -k --cacert src/main/resources/server_fqdn.crt \
       --cert src/main/resources/client_identity.pem:secret \
       https://localhost:9443/greeting
```
   
```json
{"id":3,"content":"Hello, World!"}
```

## References

* [Spring Boot REST service](https://spring.io/guides/gs/rest-service/)
* [curl website - SSL Certificate Verification](https://curl.se/docs/sslcerts.html)
* [Daniel Stenberg's blog - Get the CA Cert for curl](https://daniel.haxx.se/blog/2018/11/07/get-the-ca-cert-for-curl/)