#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "SimpleApp should succeed when building the jsonnet template" {
    run jsonnet test/simpleApp/samplespringbootapp.jsonnet
    assert_success
    assert_output -p '"apiVersion": "v1"'
    assert_output -p '"kind": "Service"'
    assert_output -p '"kind": "Deployment"'
    assert_output -p '"kind": "Ingress"'
}

@test "SimpleApp should have a Service section" {
    run jsonnet test/simpleApp/samplespringbootapp.jsonnet
    assert_success
    assert_output -p '{
         "apiVersion": "v1",
         "kind": "Service",
         "metadata": {
            "name": "samplespringbootapp-service"
         },
         "spec": {
            "ports": [
               {
                  "port": 9999,
                  "protocol": "TCP",
                  "targetPort": 9999
               }
            ],
            "selector": {
               "app": "samplespringbootapp"
            },
            "type": "ClusterIP"
         }
      }'
}

@test "SimpleApp should have a Ingress section" {
    run jsonnet test/simpleApp/samplespringbootapp.jsonnet
    assert_success
    assert_output -p '{
         "apiVersion": "extensions/v1beta1",
         "kind": "Ingress",
         "metadata": {
            "name": "samplespringbootapp-ingress",
            "namespace": "default"
         },
         "spec": {
            "rules": [
               {
                  "host": "mysterious-grass-savages.github",
                  "http": {
                     "paths": [
                        {
                           "backend": {
                              "serviceName": "samplespringbootapp-service",
                              "servicePort": 9999
                           },
                           "path": "/hello"
                        }
                     ]
                  }
               }
            ]
         }
      }'
}

@test "SimpleApp should have a Deployment section" {
    run jsonnet test/simpleApp/samplespringbootapp.jsonnet
    assert_success
    assert_output -p '{
         "apiVersion": "apps/v1",
         "kind": "Deployment",
         "metadata": {
            "labels": {
               "app": "samplespringbootapp",
               "environment": "dev"
            },
            "name": "samplespringbootapp-deployment"
         },
         "spec": {
            "replicas": 2,
            "selector": {
               "matchLabels": {
                  "app": "samplespringbootapp"
               }
            },
            "template": {
               "metadata": {
                  "labels": {
                     "app": "samplespringbootapp"
                  }
               },
               "spec": {
                  "containers": [
                     {
                        "image": "parjanya/samplespringbootapp:1.6-SNAPSHOT",
                        "livenessProbe": {
                           "httpGet": {
                              "path": "/hello/commitId",
                              "port": "container-port"
                           },
                           "initialDelaySeconds": 8,
                           "periodSeconds": 10
                        },
                        "name": "samplespringbootapp",
                        "ports": [
                           {
                              "containerPort": 9999,
                              "name": "container-port"
                           }
                        ],
                        "readinessProbe": {
                           "httpGet": {
                              "path": "/hello/actuator/health",
                              "port": "container-port"
                           },
                           "initialDelaySeconds": 8,
                           "periodSeconds": 10
                        }
                     }
                  ]
               }
            }
         }
      }'
}
