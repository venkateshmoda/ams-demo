#!/bin/bash
# AWS Managed Services - 2018-09-21
# This will install the AWS Managed Services CLI.
# This includes the:
#  * AWS Managed Services Change Management CLI (amscm)
#  * AWS Managed Services SKMS CLI (amsskms)
# Prerequisites:
#  * Linux or Mac operating systems
#  * AWS CLI Version 1.14.x or above (The latest version is recommended)

# AWS CLI
# To install the latest version of the AWS CLI, please visit:
#  * https://aws.amazon.com/cli/
# To know the version of the AWS CLI installed on your system, please run:
#  * aws --version

#######################################
# Checks if a directory exists and is accessible.
# If directory does not exists or is not accessible, it exits with failure.
# Globals:
#   None
# Arguments:
#   $1 Relative or full path to the desired directory.
# Returns:
#   None
#######################################
directory_exists_available() {
  if [ ! -d "$1" ]; then
    echo "ERROR: The $1 folder is not in the same directory as this script."
    echo "Exiting the installation."
    exit 1;
  fi
}

#######################################
# Checks if a file exists and is accessible.
# If file does not exists or is not accessible, it exits with failure.
# Globals:
#   None
# Arguments:
#   $1 Relative or full path to the desired file.
# Returns:
#   None
#######################################
file_exists_available() {
  if [ ! -f "$1" ]; then
    echo "ERROR: The file $1 does not exist."
    echo "Exiting the installation."
    exit 1;
  fi
}

#######################################
# Backups a directory and its substructure/subfolders into a new directory,
#  and after the backup is complete, it deletes the original directory and its substructure/subfolders.
# If the original directory does not exist or is not accessible, it skips the backup process.
# Globals:
#   None
# Arguments:
#   $1 Relative or full path to the folder and its substructure/subfolders to be backed up and later deleted.
#   $2 Relative or full path to the desired folder where this should be back-up.
# Returns:
#   None
#######################################
backup_older_cli_directory() {
  if [ ! -d "$2" ]; then
    echo "ERROR: The $2 folder where the backup is going to copied-to does not exists."
    echo "Exiting the installation."
    exit 1;
  fi
  if [ -d "$1" ]; then
    cp -r "$1" "$2"
    rm -rf "$1"
  fi
}

echo "This will install the AWS Managed Services CLI."
echo "The latest AWS CLI is a pre-requisite to install the AWS Managed Services CLI."

echo ""

if ! command -v aws 2>/dev/null; then
  echo "You do not have the latest AWS CLI installed."
  echo "To install the latest AWS CLI, please visit"
  echo "  https://aws.amazon.com/cli/"
  echo "After you have installed the latest AWS CLI, please run this script again."
  exit;
fi

echo "We have found the following version of the AWS CLI:"
aws --version
echo ""
echo "If you want to update or re-install the AWS CLI, "
echo "  you can do so by visiting https://aws.amazon.com/cli/"
echo ""

echo "Do you wish to install the AWS Managed Services CLI?"
echo "  Please type the number with the desired option."
#select yn in "Yes" "No"; do
#  case $yn in
#    Yes )
      echo "Proceeding with the installation of the latest AWS Managed Services CLI."

      echo ""
      echo "Checking presence and integrity of the installation files."
      # Validation for amscm.
      amscm_directory="amscm/2018-09-21"
      directory_exists_available "$amscm_directory"
      file_exists_available "$amscm_directory/service-2.json"

      # Validation for amsskms.
      amsskms_directory="amsskms/2018-09-21"
      directory_exists_available "$amsskms_directory"
      file_exists_available "$amsskms_directory/service-2.json"


      # Some variables to help the installation
      today_date=$(date +%Y%m%d)
      backup_directory="$HOME/.aws/backup_older_clis/$today_date"

      # Creating the directories to backup the previous AWS Managed Services CLIs.
      mkdir -p "$backup_directory"

      # Move old versions of the services to $backup_directory.
      echo ""
      echo "Backing up previous AWS Managed Services CLIs under the following directory:"
      echo "$backup_directory"
      backup_older_cli_directory "$HOME/.aws/models/mcchangemanagement" "$backup_directory"
      backup_older_cli_directory "$HOME/.aws/models/mcprovisioning" "$backup_directory"
      backup_older_cli_directory "$HOME/.aws/models/amscm" "$backup_directory"
      backup_older_cli_directory "$HOME/.aws/models/amsskms" "$backup_directory"


      echo ""
      echo "Installing the the latest AWS Managed Services CLI."

      # Create the new directories for AWS Managed Services CLIs.
      mkdir -p "$HOME/.aws/models/amscm"
      mkdir -p "$HOME/.aws/models/amsskms"

      # Copy latest version of the services
      cp -r amscm "$HOME/.aws/models"
      cp -r amsskms "$HOME/.aws/models"

      echo "AWS Managed Services CLIs has been installed."
      echo ""
      echo "For usage instructions and examples, please run:"
      echo "  aws amscm help"
      echo "  aws amsskms help"

#      break;;

#    No )
      #echo "You have chosen to not install the AWS Managed Services CLI."
      #echo "Aborting installation."
#      exit;;

#    esac
#done
