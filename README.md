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

## Getting started

### 1. The 'Java Greeting REST service'

Clean and build the project for the first time.
```sh
$ cd mtls-apps-examples/1-greeting-java 
$ mvn clean
$ mvn spring-boot:run
``` 

#### Enabling TLS

1. Edit the `src/main/resources/application.yml` to enable TLS.   
```yaml
server:
  port: 8080
#  ssl:
#    enabled: true
``` 

2. Generate a Root Certificate and issue a TLS Certificate.   
```sh
$ 
``` 

3. Generate a Root Certificate and issue a TLS Certificate.   
```sh
$ 
``` 

#### Enabling Mutual TLS Authentication

```sh
$ cd mtls-apps-examples/1-greeting-java 
$ mvn clean
$ mvn spring-boot:run
``` 



## References

### Go
* https://kofo.dev/how-to-mtls-in-golang
* https://venilnoronha.io/a-step-by-step-guide-to-mtls-in-go
* https://github.com/nicholasjackson/mtls-go-example
* https://smallstep.com/hello-mtls/doc/server/go

### Java
* https://spring.io/guides/gs/rest-service/