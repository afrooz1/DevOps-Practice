#!/bin/bash

# Path to reports folder (relative to scripts/)
REPORT_PATH="../reports"
mkdir -p "$REPORT_PATH"

REPORT_FILE="$REPORT_PATH/cloud_report.html"

echo "[+] Generating Final Cloud Report..."

# Start HTML
echo "<html>
<head>
<title>AWS Cloud Resource Report</title>
<style>
body { font-family: Arial; margin: 20px; }
h1 { color: #0A74DA; }
pre { background: #f4f4f4; padding: 10px; border-radius: 5px; }
</style>
</head>
<body>

<h1> AWS Cloud Resource Summary Report </h1>
<hr>" > "$REPORT_FILE"

# --------------------------
# EC2 SECTION
# --------------------------
echo "[+] Adding EC2 to report..."
if [ -f "$REPORT_PATH/ec2.json" ]; then
    echo "<h2>EC2 Instances</h2>" >> "$REPORT_FILE"
    echo "<pre>" >> "$REPORT_FILE"
    cat "$REPORT_PATH/ec2.json" >> "$REPORT_FILE"
    echo "</pre>" >> "$REPORT_FILE"
else
    echo "<h2>EC2 Instances</h2><p>No EC2 data found.</p>" >> "$REPORT_FILE"
fi

# --------------------------
# S3 SECTION
# --------------------------
echo "[+] Adding S3 to report..."
if [ -f "$REPORT_PATH/s3.json" ]; then
    echo "<h2>S3 Buckets</h2>" >> "$REPORT_FILE"
    echo "<pre>" >> "$REPORT_FILE"
    cat "$REPORT_PATH/s3.json" >> "$REPORT_FILE"
    echo "</pre>" >> "$REPORT_FILE"
else
    echo "<h2>S3 Buckets</h2><p>No S3 data found.</p>" >> "$REPORT_FILE"
fi

# --------------------------
# IAM SECTION
# --------------------------
echo "[+] Adding IAM to report..."
if [ -f "$REPORT_PATH/iam.json" ]; then
    echo "<h2>IAM Users</h2>" >> "$REPORT_FILE"
    echo "<pre>" >> "$REPORT_FILE"
    cat "$REPORT_PATH/iam.json" >> "$REPORT_FILE"
    echo "</pre>" >> "$REPORT_FILE"
else
    echo "<h2>IAM Users</h2><p>No IAM data found.</p>" >> "$REPORT_FILE"
fi

# --------------------------
# END OF REPORT
# --------------------------
echo "<hr>
<p>Report generated automatically using AWS CLI + Bash Automation.</p>
</body></html>" >> "$REPORT_FILE"

echo "[+] Report Generated Successfully: $REPORT_FILE"
