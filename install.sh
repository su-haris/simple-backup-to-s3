#!/bin/bash
# Installer Script for simple-backup-to-s3
# A Simple Script to backup files to any S3 compliant storage
# https://github.com/su-haris/simple-backup-to-s3

REPO_URL="https://github.com/su-haris/simple-backup-to-s3.git"

echo "Installing simple-backup-to-s3"
echo -e

# Install Python

echo "Proceeding to install Python3 and virtualenv"

# Check the distribution
if [ -f /etc/redhat-release ]; then
    # Install Python3 on Redhat/CentOS
    yum install python3 -yq
    yum install python3-venv -yq
elif [ -f /etc/lsb-release ]; then
    # Install Python3 on Ubuntu/Debian
    apt-get update -q
    apt-get install python3 -yq
    sudo apt-get install python3-venv -yq
elif [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ "$ID" == "amzn" ]; then
        # Install Python3 on Amazon Linux
        yum install python3 -yq
        yum install python3-venv -yq
    fi
else
    echo "Distribution not supported."
    echo "Try to install Python3 manually and try again."
    exit 1
fi
echo -e
echo "Python3 is successfully installed!"
echo -e

# Clone the repository
echo "Cloning repository for the necessary files."
echo -e
git clone -q $REPO_URL
cd simple-backup-to-s3

# Ask the user to input the SECRET_ACCESS_KEY
echo -e
echo "Enter your S3 SECRET_ACCESS_KEY: "
read SECRET_ACCESS_KEY

# Ask the user to input the ACCESS_KEY_ID
echo -e
echo "Enter your S3 ACCESS_KEY_ID: "
read ACCESS_KEY_ID

# Ask the user to input the ENDPOINT_URL
echo -e
echo "Enter your S3 ENDPOINT_URL: "
read ENDPOINT_URL

# Ask the user to input the REGION
echo -e
echo "Enter your S3 REGION: "
read REGION

# Ask the user to input the DIRECTORY_PATHS
echo -e
echo "Enter DIRECTORY_PATHS to backup (separated by commas)."
read DIRECTORY_PATHS

# Convert comma-separated values to Python list
DIRECTORY_PATHS=$(echo $DIRECTORY_PATHS | sed "s/,/','/g")
DIRECTORY_PATHS="['"$DIRECTORY_PATHS"']"

# Write the values to the file
echo "SECRET_ACCESS_KEY = '$SECRET_ACCESS_KEY'" >settings.py
echo "ACCESS_KEY_ID = '$ACCESS_KEY_ID'" >>settings.py
echo "ENDPOINT_URL = '$ENDPOINT_URL'" >>settings.py
echo "REGION = '$REGION'" >>settings.py
echo "DIRECTORY_PATHS = $DIRECTORY_PATHS" >>settings.py

# Confirm that the values have been written to the file
echo -e
echo "Values written to settings.py"
cat settings.py

# Update /etc/profile to trigger script on SSH
CURRENT_DIR=$(pwd)

# activate virtualenv
python3 -m venv env
source env/bin/activate

# install required packages
echo -e
echo "Installing required python packages"
pip install -r requirements.txt

# Doing a test run backup
echo -e
echo "Doing a test run backup. This will confirm if installation was successful."
python backup_to_s3.py

# Add Cron entry to run at 3AM daily.
(
    crontab -l 2>/dev/null
    echo "0 3 * * * cd $CURRENT_DIR && source env/bin/activate && python backup_to_s3.py"
) | crontab -

echo "Installation of simple-backup-to-s3 is complete."
