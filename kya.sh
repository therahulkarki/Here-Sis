#!/bin/bash

# usage: bash openredirect.sh -u <urls file> -p <payloads file> [-s <single payload>] [-z]

# parse command line arguments
while getopts ":u:p:s:z" opt; do
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
    z)
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
  echo "Usage: bash openredirect.sh -u <urls file> [-p <payloads file>] [-s <single payload>] [-z]" >&2
  exit 1
fi

# use single payload if provided, otherwise read payloads from file
if [ -n "$SINGLE_PAYLOAD" ]; then
  payloads=$SINGLE_PAYLOAD
else
  if [ -z "$PAYLOADS_FILE" ]; then
    echo "Usage: bash openredirect.sh -u <urls file> [-p <payloads file>] [-s <single payload>] [-z]" >&2
    exit 1
  fi
  payloads=$(cat $PAYLOADS_FILE)
fi

# read in URLs
while read -r url; do
  # attempt to redirect to the payload
  response=$(curl -L "$url$payload" -w "%{http_code}" -s)

  # check if the redirect was successful
  if [ "$response" == "302" ]; then
    # print a success message in red color
    echo -e "\033[31m[*]Open redirect vulnerability found in:\033[0m \033[1;32m$ur\033m[0m"
  elif [ "$ONLY_VULNERABLE" != "true" ]; then
    # print a failure message
    echo -e "\033[36m[*]No open redirect vulnerability found in:\033[0m \033[1;37m$url\033[0m"
  fi
done < "$URLS_FILE"
