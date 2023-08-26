#!/bin/sh
set -e

# Retrieve the latest build number
LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/velocity | jq -r '.versions | .[-1]')
LATEST_BUILD=$(curl -s "https://api.papermc.io/v2/projects/velocity/versions/${LATEST_VERSION}/builds/" | jq '.builds[-1].build')
SHA256=$(curl -s "https://api.papermc.io/v2/projects/velocity/versions/${LATEST_VERSION}/builds/" | jq '.builds[-1].downloads.application.sha256')

echo "--------------------------------------------------------------------------------------------------------"
echo "Velocity build: $LATEST_BUILD Latest version: $LATEST_VERSION"
echo "--------------------------------------------------------------------------------------------------------"

# Construct the download URL
DOWNLOAD_URL="https://api.papermc.io/v2/projects/velocity/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/${LATEST_VERSION}-${LATEST_BUILD}.jar"
curl -s -o velocity.jar "$DOWNLOAD_URL"
downloaded_sha256=$(sha256sum "velocity.jar" | awk '{print $1}')
if [ "$downloaded_sha256" = "${SHA256}" ]; then
  echo "Velocity server downloaded successfully."
else
     echo "Velocity server downloaded with error"
     echo "${downloaded_sha256} << download"
     echo "${SHA256} << SAVED"
     echo "be caraful it's Paper Team..."
fi
#code down bellow is work but not for files from PaperMC...
# Download the Purpur server JAR
# while true; do
#   # download
#   curl -O "$DOWNLOAD_URL"
#   echo `ls .`
#   #mathing sha
#  downloaded_sha256=$(sha256sum "velocity.jar" | awk '{print $1}')
#   # Compair SHA256
#   if [ "$downloaded_sha256" = "${SHA256}" ]; then
#     echo "Velocity server downloaded successfully."
#     mv ${LATEST_VERSION}-${LATEST_BUILD}.jar velocity.jar
#     break
#   else
#     echo "Velocity server downloaded with error"
#     echo "${downloaded_sha256} << download"
#     echo "${SHA256} << SAVED"
#     SHA256=$(curl -s "https://api.papermc.io/v2/projects/velocity/versions/${LATEST_VERSION}/builds/")
#     rm velocity.jar
#   fi
# done


