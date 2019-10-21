# jsonnet-service-ingress-deployment
This repository holds the master Kubernetes jsonnet template

# Pre-requisites
Jsonnet is required. Instructions to install are here -> http://github.com/google/jsonnet

# Using the template

Example of using this is here -> https://github.com/parj/SampleSpringBootApp/tree/master/kubernetes-template

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