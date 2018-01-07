#!/bin/bash

while true; do
    printf "."
    curl -s -X "POST" -d "nyan=pass" "http://nyanpass.com/add.php" > /dev/null
done
