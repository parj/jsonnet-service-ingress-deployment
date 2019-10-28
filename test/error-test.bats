#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "Should fail when missing all mandatory attributes" {
    run jsonnet test/empty/empty.jsonnet
    assert_failure
    assert_output -p "RUNTIME ERROR: serviceName must be specified"
}

@test "Should fail when only 1 mandatory attribute is added" {
    run jsonnet test/err-missing-mandatory-sections/err1.jsonnet
    assert_failure
    assert_output -p "RUNTIME ERROR: servicePort must be specified"
}

@test "Should fail when only 2 mandatory attributes are added" {
    run jsonnet test/err-missing-mandatory-sections/err2.jsonnet
    assert_failure
    assert_output -p "RUNTIME ERROR: Ingress URL must be specified"
}

@test "Should fail when only 3 mandatory attributes are added" {
    run jsonnet test/err-missing-mandatory-sections/err3.jsonnet
    assert_failure
    assert_output -p "RUNTIME ERROR: dockerImage must be specified"
}