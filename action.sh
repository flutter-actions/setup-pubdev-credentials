#!/bin/bash

if [[ -z "${ACTIONS_ID_TOKEN_REQUEST_URL}" ]] && [[ -z "${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" ]]; then
    echo "::error:: The job or workflow run requires a permissions setting with id-token: write.\nYou won't be able to request the OIDC JWT ID token if the permissions setting for id-token is set to read or none.\nThe \`id-token: write\` setting allows the JWT to be requested from GitHub's OIDC provider."
    exit 0
fi

if [ ! "$(command -v dart)" ] && [ ! "$(command -v flutter)" ]; then
    echo "::error::Flutter is not installed,"
    echo "See https://github.com/flutter-actions/setup-flutter for more details."
    exit 1
fi

log_group_start() {
    echo "::group::${1}"
}
log_group_end() {
    echo "::endgroup::"
}

echo "Create the OIDC token used for pub.dev publishing..."
INPUT_GITHUB_OIDC_AUDIENCE="https://pub.dev"
GITHUB_OIDC_RESPONSE=$(curl -s -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=${INPUT_GITHUB_OIDC_AUDIENCE}")
GITHUB_OIDC_IDTOKEN=$(jq -r '.value' <<< "${GITHUB_OIDC_RESPONSE}")
export PUB_TOKEN=${GITHUB_OIDC_IDTOKEN}
echo "PUB_TOKEN=${GITHUB_OIDC_IDTOKEN}" >> $GITHUB_ENV
echo "The Dart CLI successfully authenticated with the GitHub OIDC token,"
dart pub token add ${INPUT_GITHUB_OIDC_AUDIENCE} --env-var PUB_TOKEN
