#!/usr/bin/env bash
# Departed
set -eu
cc_fp=${CC_FP:-""}
cc_file=${CC_FILE:-"${HOME}/.local/configs/ccrypt/p.cpt"}
env_file="${HOME}/.aws/assumer.env.cpt"

if [ ! -f "$cc_file" ]; then
    exit 1
fi





if [ -f "$env_file" ]; then
    if [ -n "${cc_fp}" ]; then
        cc_enp=$(ccrypt -d "${cc_file}" -c -K "${cc_fp}")
    else
        cc_enp=$(ccrypt -d "${cc_file}" -c)
    fi
    eval "$(ccrypt -d "$env_file" -c -K $cc_enp)"
else
    echo "$env_file do not exists."
    exit
fi

echo  -n "Enter token code: "
read token_code
CREDENTIALS=$(aws sts assume-role \
    --role-arn "$ROLE_ARN" \
    --role-session-name "$SESSION_NAME" \
    --serial-number "$MFA_ARN" \
    --token-code "$token_code" \
    --duration-seconds 14400) # 4小时

# 解析临时凭证
AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')
EXPIRATION=$(echo $CREDENTIALS | jq -r '.Credentials.Expiration')
PROFILE_NAME="dtw"
aws configure set "profile.${PROFILE_NAME}.aws_access_key_id" ${AWS_ACCESS_KEY_ID}
aws configure set "profile.${PROFILE_NAME}.aws_secret_access_key" ${AWS_SECRET_ACCESS_KEY}
aws configure set "profile.${PROFILE_NAME}.aws_session_token" ${AWS_SESSION_TOKEN}
aws configure set "profile.${PROFILE_NAME}.x_security_token_expires" ${EXPIRATION}

echo
echo "Profile $PROFILE_NAME configured successfully."
