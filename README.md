# simple-backup-to-s3 (Work In Progress)
A Simple Script to backup directories on your Linux machine to any S3 provider using Python <br>

## Installation
```
wget https://raw.githubusercontent.com/su-haris/simple-backup-to-s3/master/install.sh -O sbs3-installer.sh && bash sbs3-installer.sh
```
Follow the on screen instructions to finish the setup

## How it works
- Run the installer
- Input credentials from your S3 provider. It does not have to be AWS only, for eg I use iDrive.
- During installation, a test run is done to verify if everything works as intended.
- A cronjob is set to run the script daily at 3AM
- The folders specified during installation is compressed at max level to tar.gz and stored at /simple-backups
- It is then uploaded to your S3 bucket under the hostname of your machine.

## Future Plans
- Encrypted Backups
- Flexibility with directories during installation
- zip,7z options
- Store backup of last 3 days in bucket
- Add notifications to Telegram (maybe)