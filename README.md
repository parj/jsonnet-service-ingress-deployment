[![Build Status](https://travis-ci.org/parj/jsonnet-service-ingress-deployment.svg?branch=master)](https://travis-ci.org/parj/jsonnet-service-ingress-deployment) [![CircleCI](https://circleci.com/gh/parj/jsonnet-service-ingress-deployment.svg?style=svg)](https://circleci.com/gh/parj/jsonnet-service-ingress-deployment)

# jsonnet-service-ingress-deployment
This repository holds the master Kubernetes jsonnet template

# Pre-requisites
Jsonnet is required. Instructions to install are here -> http://github.com/google/jsonnet

## MacOS

`brew install jsonnet`

## Other platforms

`go get github.com/google/go-jsonnet/cmd/jsonnet`

# Using the template

Example of using this is in the `test` directory of this repo. The directory `minimalApp`, `simpleApp` has working examples.

A deployment `template` is required. Example - `samplespringbootapp-deployment.jsonnet.template`

```
local serviceDeployment = import "service-deployment-ingress.jsonnet.TEMPLATE";

local samplespringbootapp() = serviceDeployment + {
    serviceName:: "samplespringbootapp",
    dockerImage:: "parjanya/samplespringbootapp:1.6-SNAPSHOT",
    servicePort:: 9999,
    url:: "/hello",

    readinessProbe::
        {
            "httpGet": {
                "path": "/hello/actuator/health",
                "port": "container-port"
            },
            "initialDelaySeconds": 8,
            "periodSeconds": 10
        },

    livenessProbe::
        {
            "httpGet": {
                "path": "/hello/commitId",
                "port": "container-port"
            },
            "initialDelaySeconds": 8,
            "periodSeconds": 10
        },

};

// Export the function as a constructor for shards
{
  samplespringbootapp:: samplespringbootapp,
}
```

Another file to bootstrap the template is created. Example is `samplespringbootapp.jsonnet`

```
local sampleSpringBootAppDeployment = import "samplespringbootapp-deployment.jsonnet.template";

sampleSpringBootAppDeployment.samplespringbootapp()
```

To apply to Kubernetes - `jsonnet samplespringbootapp.jsonnet | kubectl apply -f -`

# To run tests

Run `git submodule update --init --recursive`. This needs to be run only once.

Run `./test.sh` to trigger tests. This should give the following output

    ✓ Should fail when missing all mandatory attributes
    ✓ Should fail when only 1 mandatory attribute is added
    ✓ Should fail when only 2 mandatory attributes are added
    ✓ Should fail when only 3 mandatory attributes are added
    ✓ minimalApp should succeed when building the jsonnet template
    ✓ minimalApp should have a Deployment section
    ✓ minimalApp should have 50 replicas
    ✓ SimpleApp should succeed when building the jsonnet template
    ✓ SimpleApp should have a Service section
    ✓ SimpleApp should have a Ingress section
    ✓ SimpleApp should have a Deployment section

    11 tests, 0 failures