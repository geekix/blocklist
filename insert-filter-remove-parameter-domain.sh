#!/bin/bash

read -p "Enter the domain that you want to add: " domain

declare blocklist="./blocklist.txt"

declare domain=$(echo $domain | sed -E 's/^\s*.*:\/\///g') # remove any https:// or http://.
declare domain=$(echo $domain | sed 's:/*$::') # remove any trailing slash.

read -p "Enter the parameter that you want to remove: " param

declare blocklistRule="||${domain}^\$removeparam=${param}"

echo $blocklistRule

if [ "$domain" == "" ]; then
    echo "No domain provided."
    exit
fi

if [ "$domain" == "v" ]; then
    echo "Wrong paste command."
    exit
fi

if [ "$domain" == "[A[A" ]; then
    echo "syntax error [A[A."
    exit
fi

if [ "$param" == "" ]; then
    echo "No parameter provided"
    exit
fi

# Only check for default blocklist as pihole list should contain same domains.
if grep -q "$blocklistRule" "$blocklist"; then
        echo "Rule already present"
    else
        echo "checking for updates..."
        git pull origin master && git pull github master

        if grep -q "$blocklistRule" "$blocklist"; then
            echo "This rule has already been added before you"
        else
            printf "$blocklistRule\n" >> "$blocklist"
            git commit -am "remove parameter ${param} for $domain" && git push origin master && git push github master
        fi
fi

