# DevOpsPlayground - Hands-on with MTLS Authentication for Microservices

This repository contains Microservices-based applications used to explain the implementation of Mutual TLS Authentication.


## Slides

[DevOps Playground - MTLS Authn for Microservices](slides/DevOpsPlayground-MTLSAuthnforMicroservices.pdf)


## Labs

| Application                                   | Description
| ---                                           | ---         
| [1-greeting-java](1-greeting-java/)           | Simple REST microservice (Maven Project) based on Spring Boot 2.4.2 and Java 11. 
| [2-hello-go](2-hello-go/)                     | Simple Go microservice used to demonstrate how to implement mutual TLS authentication.
| [3-caddy-sidecar](3-caddy-sidecar/)           | Caddy as sidecar proxy for any kind of microservices to manage MTLS and Certificates.
|                                               |   


## Preparation

### Clone the repository.
```sh
## clone the repo
$ git clone <repo>
```

### Install Java 11, Maven and Go.
```sh
$ source <(curl -s https://raw.githubusercontent.com/chilcano/how-tos/master/src/devops_playground_tools_install.sh) 
```

### Install a Fancy Linux Prompt

```sh
$ curl -sS https://raw.githubusercontent.com/diogocavilha/fancy-git/master/install.sh | sh
$ . ~/.bashrc
$ fancygit human
$ . ~/.bashrc
```


