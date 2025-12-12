# AWS Resource Tracker

A **Bash + AWS CLI + GitHub automation tool** that collects your AWS cloud resources (EC2, S3, IAM) and generates a **JSON and HTML report**. Optionally, it can upload the report to a GitHub repository.

---

## Features

- Collect EC2 instance details: total, running, stopped, instance type, AZ, Name.
- Collect S3 bucket details: name, creation date, region.
- Collect IAM user details: username, MFA status, access keys.
- Save JSON reports locally.
- Generate a clean HTML report (`cloud_report.html`).
- Safe HTML version (`cloud_report_safe.html`) removes sensitive information.
- Optionally upload the report to GitHub via API.

---

## Project Structure

aws-resource-tracker/
│
├── scripts/
│ ├── main.sh # Main automation script
│ └── report.sh # HTML report generator
│
├── config/
│ └── example.env # Environment variables (AWS credentials, GitHub token)
│
├── reports/ # JSON & HTML reports (ignored by Git)
│
└── README.md


---

## Prerequisites

- **AWS CLI** installed and configured with proper credentials.
- **jq** installed for JSON processing.
- Bash shell (Linux, Mac, or Git Bash on Windows).
- GitHub Personal Access Token (if uploading report).

---

## Setup

1. **Clone your repository:**

```bash
git clone https://github.com/<your-username>/<repo>.git
cd aws-resource-tracker
Create your environment file:

cp config/example.env config/.env

Edit .env with your AWS credentials, GitHub username, repository, and token:
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY
AWS_DEFAULT_REGION=YOUR_REGION
GITHUB_USERNAME=your-github-username
GITHUB_REPO=your-repo-name
GITHUB_TOKEN=your-personal-access-token
REPORT_PATH=reports
REPORT_FILE=cloud_report.html

Usage

Run the main script to collect AWS data and generate reports:

cd scripts
./main.sh


Reports will be saved in reports/.

Safe HTML version (cloud_report_safe.html) is generated automatically.

If GitHub credentials are provided, the report is uploaded automatically.

Notes

The reports/ folder is ignored in Git to avoid committing sensitive information.

The script uses base64 encoding to safely upload HTML files to GitHub.

Make sure your AWS IAM user has read access to EC2, S3, and IAM.

Security

Sensitive data (like Access Keys) should never be committed.

Use the _safe.html report when sharing publicly.

Keep your .env file private.

License

MIT License © [Afrooz Habib]
