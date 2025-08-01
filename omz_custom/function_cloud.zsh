#!/usr/bin/env bash

dtw.aliyun.login(){(
#    set -eu
    kp_db="secret.kdbx"
    entry="ak"

    cd  "${HOME}/.aliyun" || { echo "${HOME}/.aliyun Not existing"; exit 2; }

    if [ ! -f "$kp_db" ]; then
        echo "secret.kdbx is not existing, exit 2"
        exit
    fi


    env="$(keepassxc-cli show "$kp_db" -s "$entry" -a Notes)"

    if [ -z "$env" ];then
        echo "Error getting environment from secret."
        exit 1
    fi

    eval "$env"

    if ! response=$(aliyun  \
    --region "${ALICLOUD_REGION}" \
    --access-key-id "${ACCESS_KEY_ID}" \
    --access-key-secret "${ACCESS_KEY_SECRET}" \
    sts AssumeRole --RoleArn "${ROLE_ARN}" \
    --RoleSessionName "${ROLE_SESSION_NAME}" \
    --DurationSeconds "${DURATION_SECONDS}"); then
        echo "Error in AssumeRole"
        exit 1
    fi

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
        exit 1
    else
        echo "Profile $PROFILE_NAME configured successfully."
    fi

)}


l.aws(){
    if [ "$#" -lt 1 ]; then
        echo "Usage: l.aws <profile>"
    fi


    local profile="$1"
    local force="${2-:default}"
    local do=false

    if ! aws sts get-caller-identity --profile "$profile" &>/dev/null; then
        echo "🔴 凭证已过期或无效 (profile: $profile)"
        do=true
    else
        if [ "$force" = "--force" ]; then
            echo "🔴 凭证有效，但强制更新 (profile: $profile)"
            do=true
        else
            echo "✅ 凭证有效，无需更新 (profile: $profile)"
        fi
    fi

    if ! "$do"; then
        return
    fi

    echo "⏳ SSO 登录(profile: $profile)"
    aws --profile "$profile" sso login
    if aws sts get-caller-identity --profile "$profile" &>/dev/null; then
        echo "✅ 登录成功(profile: $profile)"
        yawsso --profile "$profile"
    else
        echo "🔴 登录失败(profile: $profile)"

    fi
}

l.env() {
    if [ "$#" -lt 1 ]; then
        echo "🔴 清除环境变量"
        unset  AWS_PROFILE
        return
    fi
    local profile=$1
    if ! aws sts get-caller-identity --profile "$profile" &>/dev/null; then
        echo "🔴 凭证已过期或无效,设置环境变量失败 (profile: $profile)"
        return
    fi
    export AWS_PROFILE="$1"
    echo "🟢 设置环境变量AWS_PROFILE (profile: $profile)"

}