#!/usr/bin/env bash

# Define the default values
HULY_VERSION="v0.6.295"
DOCKER_NAME="huly"
CONFIG_FILE="huly.conf"


if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
clear

while true; do
    read -p "Enter the host address (domain name or IP) [default: ${HOST_ADDRESS:-localhost}]: " input
    _HOST_ADDRESS="${input:-${HOST_ADDRESS:-localhost}}"
    #TODO: proper validation
    #if [[ "$_HOST_ADDRESS" =~ ^[a-zA-Z0-9.-]+$ || "$_HOST_ADDRESS" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        break
    #else
    #   echo "Invalid host address. Please enter a valid domain name or IP."
    #fi
done
clear

while true; do
    read -p "Enter the port for HTTP [default: ${HTTP_PORT:-80}]: " input
    _HTTP_PORT="${input:-${HTTP_PORT:-80}}"
    if [[ "$_HTTP_PORT" =~ ^[0-9]+$ && "$_HTTP_PORT" -ge 1 && "$_HTTP_PORT" -le 65535 ]]; then
        break
    else
        echo "Invalid port. Please enter a number between 1 and 65535."
    fi
done
clear
# TODO: true/false
while true; do
    read -p "Will you serve Huly over SSL? (y/N) [default: ${SECURE}]: " SECURE_INPUT
    case "$SECURE_INPUT" in
        [Yy]* )
            SECURE="s";break;;
        [Nn]* )
            SECURE="";break;;
        * )
            echo "Invalid input. Please enter Y or N.";;
    esac
done
clear

SECRET=false
if [ "$1" == "--secret" ]; then
  SECRET=true
fi

if [ ! -f huly.secret ] || [ "$SECRET" == true ]; then
  openssl rand -hex 32 > huly.secret
  echo "Secret generated and stored in huly.secret"
else
  echo -e "\033[33mhuly.secret already exists, not overwriting."
  echo "Run this script with --secret to generate a new secret."
fi


export SECURE
export HOST_ADDRESS=$_HOST_ADDRESS
export HTTP_PORT=$_HTTP_PORT
export HULY_SECRET=$(cat huly.secret)

envsubst < template.huly.conf > $CONFIG_FILE

echo -e "\033[1;32mSetup is complete!\033[0m"

read -p "Do you want to run 'docker compose up -d' now to start Huly? (Y/n): " RUN_DOCKER
case "${RUN_DOCKER:-Y}" in  
    [Yy]* )  
         echo -e "\033[1;32mRunning 'docker compose up -d' now...\033[0m"
         docker compose up -d
         ;;
    [Nn]* )
        echo "You can run 'docker compose up -d' later to start Huly."
        ;;
   
esac
