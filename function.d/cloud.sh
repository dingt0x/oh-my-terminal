#!/usr/bin/env bash

dtw.aliyun.login(){(
    set -eu
    kp_db="secret.kdbx"
    entry="ak"

    cd  "${HOME}/.aliyun" || { echo "${HOME}/.aliyun Not existing"; exit 2; }

    if [ ! -f "$kp_db" ]; then
        echo "secret.kdbx is not existing, exit 2"
        exit
    fi

    eval "$(keepassxc-cli show "$kp_db" -s "$entry" -a Notes)"

    response=$(aliyun  --region "${ALICLOUD_REGION}" \
    --access-key-id "${ACCESS_KEY_ID}" \
    --access-key-secret "${ACCESS_KEY_SECRET}" \
    sts AssumeRole --RoleArn "${ROLE_ARN}" \
    --RoleSessionName "${ROLE_SESSION_NAME}" \
    --DurationSeconds "${DURATION_SECONDS}")

    TEMP_ACCESS_KEY_ID=$(echo "$response" | jq -r '.Credentials.AccessKeyId')
    TEMP_ACCESS_KEY_SECRET=$(echo "$response" | jq -r '.Credentials.AccessKeySecret')
    SECURITY_TOKEN=$(echo "$response" | jq -r '.Credentials.SecurityToken')
    PROFILE_NAME="dtw"


    res=$(aliyun configure set --profile "${PROFILE_NAME}" \
    --region "${ALICLOUD_REGION}" \
    --mode "StsToken" \
    --access-key-id "${TEMP_ACCESS_KEY_ID}" \
    --access-key-secret "${TEMP_ACCESS_KEY_SECRET}" \
    --sts-token "${SECURITY_TOKEN}" \
    --sts-region "${ALICLOUD_REGION}")

    if [ -n "${res}" ]; then
        echo "$res"
    else
        echo "Profile $PROFILE_NAME configured successfully."
    fi

)}