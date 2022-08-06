#!/usr/bin/env bash

set -euo pipefail

LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

# source the global vars and other files
. "${LIB_DIR}"/vars
. "${LIB_DIR}"/colors

# source the test-specific vars
[ -f "${TEST_DIR}/vars" ] && [ -r "${TEST_DIR}/vars" ] && . "${TEST_DIR}/vars"


echo2() {
    echo >&2 "$@"
}


aws() {
    # local version of the aws command that automatically
    # adds a configured endpoint and region
    local arg args=() has_endpoint=false has_region=false

    for arg in "${@}"; do
        args+=("${arg}")
        [ "${arg}" == "--endpoint-url" ] && has_endpoint=true
        [ "${arg}" == "--region" ] && has_region=true
    done

    [ !${has_endpoint} ] && [ -n "${ENDPOINT}" ] && args+=('--endpoint-url' "${ENDPOINT}")
    [ !${has_region} ] && [ -n "${REGION}" ] && args+=('--region' "${REGION}")

    command aws "${args[@]}"
}


maybe_delete_table() {
    aws dynamodb delete-table "${@}" >/dev/null 2>&1 || :
}


create_table() {
    aws dynamodb create-table "${@}" >/dev/null
}


put_item_from_file() {
    local item_json_file="${1?first arg is put item input json file}"; shift||:
    local item_json="$(cat "${item_json}")"
    echo2 "Inserting item from file '${item_json_file}'"
    echo2 "${item_json}"
    aws dynamodb put-item --cli-input-json "$(cat "${item_json}")" "${@}"
}


start_message() {
    echo2 -e "${BLUE}${TEST_NAME}:${NC} ${@:-beginning}"
}

setup_test() {
    maybe_delete_table \
        --table-name "${TEST_NAME}"
    create_table \
        --table-name "${TEST_NAME}" \
        --cli-input-json "$(cat "${SCHEMA_FILE}")"

    [ "${CLEANUP:-true}" == "true" ] && {
        echo >&2 'Setting cleanup trap on EXIT'
        trap "maybe_delete_table --table-name '${TEST_NAME}'" EXIT
    }
}


tests_end() {
    local tests_passed=${1:?provide bool indicating tests success (true) or failure (false)}
    if $tests_passed; then
        echo2 -e "${GREEN}${TEST_NAME}:${NC} All tests passed successfully."
        exit
    else
        echo2 -e "${RED}${TEST_NAME}:${NC} One or more tests failed."
        exit 1
    fi
}


test_case() {
    echo2 -e "${BLUE}TEST:${NC} ${@}"
}


test_ok() {
    echo2 -e "${GREEN}OK:${NC} ${@}"
}


test_nok() {
    echo2 -e "${RED}FAILED:${NC} ${@}"
}
