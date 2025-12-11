#!/bin/bash
# ==============================
# AWS Resource Tracker - Final Polished
# ==============================

# Load environment variables
source ../config/example.env

# Ensure REPORT_PATH exists
mkdir -p "$REPORT_PATH"

echo "======================================"
echo " AWS Resource Tracker Starting..."
echo "======================================"

# --------------------------
# EC2 MODULE
# --------------------------
get_ec2_info() {
    echo "[+] Collecting EC2 instance information..."
    EC2_DATA=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*]' --output json)
    EC2_TOTAL=$(echo "$EC2_DATA" | jq 'flatten | length')
    EC2_RUNNING=$(echo "$EC2_DATA" | jq 'flatten | map(select(.State.Name == "running")) | length')
    EC2_STOPPED=$(echo "$EC2_DATA" | jq 'flatten | map(select(.State.Name == "stopped")) | length')
    EC2_DETAILS=$(echo "$EC2_DATA" | jq 'flatten | map({
        InstanceId: .InstanceId,
        InstanceType: .InstanceType,
        AvailabilityZone: .Placement.AvailabilityZone,
        State: .State.Name,
        Name: (.Tags[]? | select(.Key=="Name") | .Value)
    })')
    EC2_JSON=$(jq -n \
        --arg total "$EC2_TOTAL" \
        --arg running "$EC2_RUNNING" \
        --arg stopped "$EC2_STOPPED" \
        --argjson details "$EC2_DETAILS" \
        '{
            total_instances: ($total | tonumber),
            running: ($running | tonumber),
            stopped: ($stopped | tonumber),
            details: $details
        }'
    )
    EXPORT_EC2_JSON="$EC2_JSON"
    echo "[+] EC2 data collected."
}

# --------------------------
# S3 MODULE
# --------------------------
get_s3_info() {
    echo "[+] Collecting S3 bucket information..."
    S3_BUCKETS_RAW=$(aws s3api list-buckets --output json)
    S3_TOTAL=$(echo "$S3_BUCKETS_RAW" | jq '.Buckets | length')
    S3_BUCKETS=$(echo "$S3_BUCKETS_RAW" | jq -c '.Buckets | map({Name: .Name, CreationDate: .CreationDate})')
    S3_BUCKET_DETAILS="[]"

    for row in $(echo "$S3_BUCKETS" | jq -r '.[] | @base64'); do
        _jq() { printf "%s" "$row" | tr -d '\r' | base64 --decode | jq -r "$1"; }
        BUCKET_NAME=$(_jq '.Name')
        BUCKET_REGION=$(aws s3api get-bucket-location --bucket "$BUCKET_NAME" --query 'LocationConstraint' --output text 2>/dev/null)
        if [[ "$BUCKET_REGION" == "None" || "$BUCKET_REGION" == "null" ]]; then
            BUCKET_REGION="us-east-1"
        fi
        S3_BUCKET_DETAILS=$(echo "$S3_BUCKET_DETAILS" | jq \
            --arg name "$BUCKET_NAME" \
            --arg created "$(_jq '.CreationDate')" \
            --arg region "$BUCKET_REGION" \
            '. += [{Name: $name, CreationDate: $created, Region: $region}]'
        )
    done

    S3_JSON=$(jq -n \
        --arg total "$S3_TOTAL" \
        --argjson details "$S3_BUCKET_DETAILS" \
        '{
            total_buckets: ($total | tonumber),
            buckets: $details
        }'
    )
    EXPORT_S3_JSON="$S3_JSON"
    echo "[+] S3 data collected."
}

# --------------------------
# IAM MODULE
# --------------------------
get_iam_info() {
    echo "[+] Collecting IAM user information..."
    IAM_RAW=$(aws iam list-users --output json)
    IAM_TOTAL=$(echo "$IAM_RAW" | jq '.Users | length')
    IAM_DETAILS="[]"

    for row in $(echo "$IAM_RAW" | jq -r '.Users[] | @base64'); do
        _decode() { printf "%s" "$row" | tr -d '\r' | base64 --decode | jq -r "$1"; }
        USERNAME=$(_decode '.UserName')
        MFA_COUNT=$(aws iam list-mfa-devices --user-name "$USERNAME" --query 'MFADevices | length(@)' --output text)
        MFA_STATUS="Disabled"
        if [[ "$MFA_COUNT" -gt 0 ]]; then MFA_STATUS="Enabled"; fi
        ACCESS_KEYS=$(aws iam list-access-keys --user-name "$USERNAME" --output json)
        KEY_INFO=$(echo "$ACCESS_KEYS" | jq -c '.AccessKeyMetadata | map({AccessKeyId: .AccessKeyId, Status: .Status, CreateDate: .CreateDate})')
        IAM_DETAILS=$(echo "$IAM_DETAILS" | jq \
            --arg user "$USERNAME" \
            --arg mfa "$MFA_STATUS" \
            --argjson keys "$KEY_INFO" \
            '. += [{UserName: $user, MFAStatus: $mfa, AccessKeys: $keys}]'
        )
    done

    IAM_JSON=$(jq -n --arg total "$IAM_TOTAL" --argjson details "$IAM_DETAILS" '{total_users: ($total|tonumber), users: $details}')
    EXPORT_IAM_JSON="$IAM_JSON"
    echo "[+] IAM data collected."
}

# --------------------------
# SAVE JSON REPORTS
# --------------------------
save_json_reports() {
    echo "[+] Saving JSON reports..."
    echo "$EXPORT_EC2_JSON" > "$REPORT_PATH/ec2.json"
    echo "$EXPORT_S3_JSON" > "$REPORT_PATH/s3.json"
    echo "$EXPORT_IAM_JSON" > "$REPORT_PATH/iam.json"
    echo "[+] JSON reports saved in $REPORT_PATH"
}

# --------------------------
# GENERATE HTML REPORT
# --------------------------
generate_html_report() {
    echo "[+] Generating HTML report using report.sh..."
    ./report.sh
}

# --------------------------
# GITHUB UPLOAD
# --------------------------
push_to_github() {
    echo "[+] Uploading report to GitHub..."
    REPO_PATH="reports/$REPORT_FILE"
    BASE64_CONTENT=$(base64 -w 0 "$REPORT_PATH/$REPORT_FILE")

    FILE_CHECK=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/repos/$GITHUB_USERNAME/$GITHUB_REPO/contents/$REPORT_PATH/$REPORT_FILE)
    SHA=$(echo "$FILE_CHECK" | jq -r '.sha // empty')

    if [ -n "$SHA" ]; then
        PAYLOAD=$(jq -n --arg message "Update report" --arg content "$BASE64_CONTENT" --arg sha "$SHA" \
            '{message: $message, content: $content, sha: $sha}')
    else
        PAYLOAD=$(jq -n --arg message "Add report" --arg content "$BASE64_CONTENT" '{message: $message, content: $content}')
    fi

    RESPONSE=$(curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD" \
        https://api.github.com/repos/$GITHUB_USERNAME/$GITHUB_REPO/contents/$REPORT_PATH/$REPORT_FILE)

    if echo "$RESPONSE" | grep -q "content"; then
        echo "[+] Report uploaded successfully!"
    else
        echo "[!] Failed to upload report."
        echo "$RESPONSE"
    fi
}

# --------------------------
# MAIN WORKFLOW
# --------------------------
get_ec2_info
get_s3_info
get_iam_info
save_json_reports
generate_html_report    # <- calls report.sh
push_to_github

echo "======================================"
echo " AWS Resource Tracker Completed."
echo "======================================"
