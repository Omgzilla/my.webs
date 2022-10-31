#!/bin/bash

echo "Generate site and upload"
echo "Options:"
echo "[1]Generate & Upload development site"
echo "[2]Upload development site"
read OPTION

case $OPTION in
    1) # Generate/Upload development
        hugo
        git add .
        echo -n "Enter commit: "
        read -r COMMIT
        git commit -m "$COMMIT"
        git push -uf origin main
        ;;
    2) # Upload development
        git add .
        echo -n "Enter commit: "
        read -r COMMIT
        git commit -m "$COMMIT"
        git push -uf origin main
        ;;
 esac
