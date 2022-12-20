#!/bin/bash

a=""

echo -e "\033[38;2;255;165;0m   __   _   _          __    \033[0m"
echo -e "\033[38;2;255;165;0m  / /  (_) (_)__ _____/ /__  \033[0m"
echo -e "$a$a$a$a$a$a$a$a$a$a / _ \/ / / / _ \`/ __/  '_/        "
echo -e "\033[1;32m$a$a$a$a$a/_//_/_/_/ /\_,_/\__/_/\_\  \033[0m"
echo -e "\033[1;32m$a$a$a$a$a      |___/ \033[0m"

echo ""
sleep 1;
# parse command line arguments
while getopts ":u:p:s:v:" opt; do
  case $opt in
    u)
      URLS_FILE=$OPTARG
      ;;
    p)
      PAYLOADS_FILE=$OPTARG
      ;;
    s)
      SINGLE_PAYLOAD=$OPTARG
      ;;
    v)
      VULN_FILE=$OPTARG
      ONLY_VULNERABLE=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# check if required arguments were provided
if [ -z "$URLS_FILE" ]; then
  echo "Usage: bash openredirect.sh -u <urls file> [-p <payloads file>] [-s <single payload>] [--positive] [-v <vulnerable URLs file>]" >&2
  exit 1
fi

# use single payload if provided, otherwise read payloads from file :)
if [ -n "$SINGLE_PAYLOAD" ]; then
  payloads=$SINGLE_PAYLOAD
else
  if [ -z "$PAYLOADS_FILE" ]; then
    echo "Usage: bash openredirect.sh -u <urls file> [-p <payloads file>] [-s <single payload>] [--positive] [-v <vulnerable URLs file>]" >&2
    exit 1
  fi
  payloads=$(cat $PAYLOADS_FILE)
fi

# read 
while read -r url; do
  # attempt to redirect to the payload 
  response=$(curl -L "$url$payload" -w "%{http_code}" -s)

  # check if the redirect was successful
  if [ "$response" == "302" ]; then
    # print a success message
    echo -e "\033[31m[*]Open redirect vulnerability found in:\033[0m \033[1;32m$url\033m[0m"
    # save the URL to the vulnerable URLs file, if provided
    if [ -n "$VULN_FILE" ]; then
      echo "$url" >> "$VULN_FILE"
    fi
  elif [ "$ONLY_VULNERABLE" != "true" ]; then
    # print a failure message
    echo -e "\033[36m[*]No open redirect vulnerability found in:\033[0m \033[1;37m$url\033[0m"
  fi
done < "$URLS_FILE"
