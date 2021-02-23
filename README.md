# DevOpsPlayground - Hands-on with MTLS Authentication for Microservices

This repository contains Microservices-based applications used to explain the implementation of Mutual TLS Authentication.


## Slides

[DevOps Playground - MTLS Authn for Microservices.pdf]("slides/DevOps Playground - MTLS Authn for Microservices.pdf")


## Labs

| Application                                   | Description
| ---                                           | ---         
| [1-greeting-java](1-greeting-java/)           | Simple REST microservice (Maven Project) based on Spring Boot 2.4.2 and Java 11. 
| [2-hello-go](2-hello-go/)                     | Simple Go microservice used to demonstrate how to implement mutual TLS authentication.
| [3-caddy-sidecar](3-caddy-sidecar/)           | Caddy as sidecar proxy for any kind of microservice to manage MTLS and Certificates.
| [4-mtls-emojivoto-tf](4-mtls-emojivoto-tf)    | Example enabling MTLS on Buoyant [Emojivoto](https://github.com/buoyantio/emojivoto) microservices application using [SmallStep CA](https://github.com/smallstep/certificates) and [Envoy Proxy](https://www.envoyproxy.io/). This version is based on [Step AWS Emojivoto](https://github.com/smallstep/step-aws-emojivoto) example and it's adapted to be used for multiple users simultaneously without collisions.
|                                               |   


## Preparation

Clone the repository.
```sh
## clone the repo
$ git clone <repo>
```

Install Java 11, Maven and Go.
```sh
$ source <(curl -s https://raw.githubusercontent.com/chilcano/how-tos/master/src/devops_playground_tools_install.sh) 
```
