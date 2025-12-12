#!/bin/bash

# ==============================
# AWS Cloud Resource Report - Safe Version
# ==============================

# Path to reports folder (relative to scripts/)
REPORT_PATH="../reports"
mkdir -p "$REPORT_PATH"

REPORT_FILE="$REPORT_PATH/cloud_report.html"

echo "[+] Generating Safe Cloud Report..."

# Start HTML
cat <<EOT > "$REPORT_FILE"
<html>
<head>
<title>AWS Cloud Resource Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
h1 { color: #0A74DA; }
h2 { color: #0D47A1; }
pre { background: #f4f4f4; padding: 10px; border-radius: 5px; white-space: pre-wrap; word-wrap: break-word; }
hr { border: 1px solid #ccc; margin: 20px 0; }
</style>
</head>
<body>

<h1>AWS Cloud Resource Summary Report (Safe Version)</h1>
<hr>
EOT

# --------------------------
# EC2 SECTION
# --------------------------
echo "[+] Adding EC2 to report..."
if [ -f "$REPORT_PATH/ec2.json" ]; then
    SAFE_EC2_JSON=$(jq '(.details[]? | .InstanceId="****MASKED****")' "$REPORT_PATH/ec2.json")
    echo "<h2>EC2 Instances</h2><pre>$SAFE_EC2_JSON</pre>" >> "$REPORT_FILE"
else
    echo "<h2>EC2 Instances</h2><p>No EC2 data found.</p>" >> "$REPORT_FILE"
fi

# --------------------------
# S3 SECTION
# --------------------------
echo "[+] Adding S3 to report..."
if [ -f "$REPORT_PATH/s3.json" ]; then
    SAFE_S3_JSON=$(jq '(.buckets[]? | .Name="****MASKED****")' "$REPORT_PATH/s3.json")
    echo "<h2>S3 Buckets</h2><pre>$SAFE_S3_JSON</pre>" >> "$REPORT_FILE"
else
    echo "<h2>S3 Buckets</h2><p>No S3 data found.</p>" >> "$REPORT_FILE"
fi

# --------------------------
# IAM SECTION
# --------------------------
echo "[+] Adding IAM to report..."
if [ -f "$REPORT_PATH/iam.json" ]; then
    SAFE_IAM_JSON=$(jq '(.users[]? | .AccessKeys[]? |= (.AccessKeyId="****MASKED****"))' "$REPORT_PATH/iam.json")
    echo "<h2>IAM Users</h2><pre>$SAFE_IAM_JSON</pre>" >> "$REPORT_FILE"
else
    echo "<h2>IAM Users</h2><p>No IAM data found.</p>" >> "$REPORT_FILE"
fi

# --------------------------
# END OF REPORT
# --------------------------
cat <<EOT >> "$REPORT_FILE"
<hr>
<p>Report generated automatically using AWS CLI + Bash Automation.</p>
</body>
</html>
EOT

echo "[+] Safe Report Generated Successfully: $REPORT_FILE"
