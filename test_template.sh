#!/bin/bash

set -e
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # No Color

function main() {
    parseArgs "$@"
    check_errs $? "Unable to parse args"
    prerequisites
    check_errs $? "Pre-requisites does not exist"
    generateTemplate
    check_errs $? "Unable to generate template"
}

function usage() {
    cat <<EOF
This is used for running tests on the template. Pre-requisites for this is jq, jsonnet, entr and BATS

One of set up is gitsubmodules. Run command `git submodule update --init --recursive` or run  ./test_template.sh --init

./test_template.sh {<option>} --file filename

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
            -i|--init)
                initGitSubmodules
                shift
                break
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

function prerequisites() {
    echoColour "YELLOW" "Checking if jq exists"
    path_to_jq=$(which jq)
    if [ -x "$path_to_jq" ] ; then
        echoColour "GREEN" "FOUND: $path_to_jq"
    else
        echoColour "RED" "NOT FOUND: jq"
        RC=127
    fi

    echoColour "YELLOW" "Checking if jsonnet exists"
    path_to_jsonnet=$(which jsonnet)
    if [ -x "$path_to_jsonnet" ] ; then
        echoColour "GREEN" "FOUND: $path_to_jsonnet"
    else
        echoColour "RED" "NOT FOUND: jsonnet"
        RC=127
    fi
}

function initGitSubmodules)() {
    git submodule update --init --recursive
}

function generateTemplate() {
    echoColour "YELLOW" "Generating template"
    generatedTemplate=$(jsonnet service-deployment-ingress.jsonnet.template)

    echo $generatedTemplate
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


main "$@"