#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "minimalApp should succeed when building the jsonnet template" {
    run jsonnet test/minimalApp/samplespringbootapp.jsonnet
    assert_success
    assert_output -p '"apiVersion": "v1"'
    assert_output -p '"kind": "Service"'
    assert_output -p '"kind": "Deployment"'
    assert_output -p '"kind": "Ingress"'
}

@test "minimalApp should have a Deployment section" {
    run jsonnet test/minimalApp/samplespringbootapp.jsonnet
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
                        "name": "samplespringbootapp",
                        "ports": [
                           {
                              "containerPort": 9999,
                              "name": "container-port"
                           }
                        ]
                     }
                  ]
               }
            }
         }
      }'
}

@test "minimalApp should have 50 replicas" {
    run jsonnet test/minimalApp-50-Replicas/samplespringbootapp.jsonnet
    assert_success
    assert_output -p 'replicas": 50'
}