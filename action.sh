#!/bin/bash

if [[ -z "${ACTIONS_ID_TOKEN_REQUEST_URL}" ]] && [[ -z "${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" ]]; then
    echo "==> No GitHub OIDC token found, skipping..."
    exit 0
fi

log_group_start() {
    echo "::group::${1}"
}
log_group_end() {
    echo "::endgroup::"
}

jwtd() {
    log_group_start "Decoding JWT data..."
    jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "${1}"
    echo "Signature: $(echo "${1}" | awk -F'.' '{print $3}')"
    log_group_end
}

INPUT_GITHUB_OIDC_AUDIENCE="https://pub.dev"

echo "Create the OIDC token used for pub.dev publishing..."
GITHUB_OIDC_RESPONSE=$(curl -s -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=${INPUT_GITHUB_OIDC_AUDIENCE}")
GITHUB_OIDC_IDTOKEN=$(jq -r '.value' <<< "${GITHUB_OIDC_RESPONSE}")
export PUB_TOKEN=${GITHUB_OIDC_IDTOKEN}
echo "PUB_TOKEN=${GITHUB_OIDC_IDTOKEN}" >> $GITHUB_ENV

jwtd "$GITHUB_OIDC_IDTOKEN"

echo "The Dart CLI successfully authenticated with the GitHub OIDC token,"
dart pub token add ${INPUT_GITHUB_OIDC_AUDIENCE} --env-var PUB_TOKEN
