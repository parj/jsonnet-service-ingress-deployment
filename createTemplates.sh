#!/bin/bash
set -e
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # No Color
KUBERNETES=false
PARAMS=""

function main() {
    parseArgs "$@"
    check_errs $? "Unable to parse args"
    prerequisites
    check_errs $? "Pre-requisites does not exist"
    checkIfTemplateExists
    check_errs $? "Unable to download template"
    if $KUBERNETES ; then
        applyToKubernetes
        check_errs $? "Unable to apply to kubernetes"
    else
        generateTemplate
        check_errs $? "Unable to apply to generate template"
    fi
    
}

function prerequisites() {
    echoColour "YELLOW" "Checking if jsonnet exists"
    path_to_jsonnet=$(which jsonnet)
    if [ -x "$path_to_jsonnet" ] ; then
        echoColour "GREEN" "FOUND: $path_to_jsonnet"
    else
        echoColour "RED" "NOT FOUND: jsonnet"
        RC=127
    fi
}

function usage() {
    cat <<EOF
To use this, Jsonnet is required. Instructions to install are here -> http://github.com/google/jsonnet.

This program helps create a Kubernetes deployment using the service-deployment-ingress.jsonnet.template as a template.

Examples of usage are here - https://github.com/parj/SampleSpringBootApp/tree/master/kubernetes-template

./createTemplates.sh {<option>} filename

Available options:
    -h / --help             This message
    -k / --kubernetes       Creates the template and applies the kubernetes
    -f / --file             JSONNET file to convert

EOF
    exit 0
}

function parseArgs() {
    while (( "$#" )); do
        case "$1" in
            -f|--file)
                FILE=$2
                shift 2
                ;;
            -k|--kubernetes)
                KUBERNETES=true
                shift
                ;;
            -h|--help)
                usage
                shift
                ;;
            --) # end argument parsing
                shift
                break
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                exit 1
                ;;
            *) # preserve positional arguments
                PARAMS="$PARAMS $1"
                shift
                ;;
        esac
    done
}

function timestamp() {
    date +"%Y-%m-%d %H:%M:%S,%3N"
}

function echoRed() {
    echo -e "${RED}$(timestamp) $1 ${NC}"
}

function echoColour() {
    local colour=""

    case $1 in
        "RED")
            colour=${RED} 
            ;;
        "YELLOW")
            colour=${YELLOW}
            ;;
        "GREEN")
            colour=${GREEN}
            ;;
        *)
            colour=${NC}
            ;;
    esac
    echo -e "${colour}$(timestamp) $2 ${NC}"

}

function check_errs() {
  if [ "${1}" -ne "0" ]; then
    echoColour "RED" "ERROR # ${1} : ${2}"
    exit ${1}
  fi
}

function checkIfTemplateExists() {
    echoColour "YELLOW" "Checking if template exists"
    local templateFile="service-deployment-ingress.jsonnet.template"
    if [ -f $templateFile ]; then
        echoColour "GREEN" "Template $templateFile exists"
    else
        curl -s local serviceDeployment = import "https://raw.githubusercontent.com/parj/jsonnet-service-ingress-deployment/master/service-deployment-ingress.jsonnet.template" >  $templateFile
        check_errs $? "Unable to download template file"
    fi

}

function generateTemplate() {
    echoColour "YELLOW" "Creating template"
    echo $1
    jsonnet $FILE
}

function applyToKubernetes() {
    echoColour "YELLOW" "Creating template and applying to K8S"
    jsonnet $FILE --output-file values.yml
    echoColour "YELLOW" "Uploading to kubernetes"
    kubectl apply -f values.yml
}

main "$@"