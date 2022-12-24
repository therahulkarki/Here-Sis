#!/bin/bash

# Check if a URL list file and payloads file were provided
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "ERROR: No URL list file or payloads file provided."
    exit 1
fi

# Set the output file to /dev/null by default
output_file="/dev/null"

# Check if the -o option was provided
while getopts ":o:" opt; do
    case $opt in
        o)
            # Set the output file to the provided value
            output_file=$OPTARG
            ;;
        \?)
            echo "ERROR: Invalid option -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "ERROR: Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Read the URL list file
while read url
do
    # Extract the base URL and parameters
    base_url=$(echo "$url" | sed 's/\?.*$//')
    params=$(echo "$url" | sed 's/^[^\?]*\?//')

    # Split the parameters into an array
    IFS='&' read -ra param_array <<< "$params"

    # Check each parameter for open redirection vulnerabilities
    for param in "${param_array[@]}"
    do
        # Read the payloads file
        while read payload
        do
            # Append the parameter with a redirect URL to the base URL
            redirect_url="$base_url?$param&$payload"

            # Send a request to the URL with the redirect parameter and follow the redirect
            response=$(curl -L -s -w %{url_effective} "$redirect_url")

            # Check if the final destination of the redirect is different from the base URL
            if [ "$response" != "$base_url" ]
            then
                # Check if the final destination of the redirect is a valid URL
                if [[ "$response" =~ ^https?:// ]]
                then
                    # Output the possible open redirection vulnerability to the terminal
                    echo "POSSIBLE OPEN REDIRECTION VULNERABILITY: $redirect_url"
                    # Save the output to the file
                    echo "POSSIBLE OPEN REDIRECTION VULNERABILITY: $redirect_url" >> "$output_file"
                fi
            fi

            # Add a delay between requests to allow the web application more time to process the request and respond
            sleep 1
        done < "$2"
    done
done < "$1"
