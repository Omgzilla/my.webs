#!/bin/bash

echo "Generate site and upload"
echo "Options:"
echo "[1]Generate & Upload production site"
echo "[2]Upload production site"
echo "[3]Generate & Upload development site"
echo "[4]Upload development site"
echo "[5]Generate/Upload dev & prod"
read OPTION

case $OPTION in
    1) # Generate/Upload production
        hugo
        cd public
        git add .
        echo -n "Enter commit: "
        read -r COMMIT
        git commit -m "$COMMIT"
        git push -uf origin main
        ;;
    2) # Upload production
        cd public
        git add .
        echo -n "Enter commit: "
        read -r COMMIT
        git commit -m "$COMMIT"
        git push -uf origin main
        ;;
    3) # Generate/Upload development
        hugo
        git add .
        echo -n "Enter commit: "
        read -r COMMIT
        git commit -m "$COMMIT"
        git push -uf origin main
        ;;
    4) # Upload development
        git add .
        echo -n "Enter commit: "
        read -r COMMIT
        git commit -m "$COMMIT"
        git push -uf origin main
        ;;
    5) # Generate, upload dev then prod
        hugo
        git add .
        echo -n "Enter dev commit: "
        read -r COMMIT-DEV
        git commit -m "$COMMIT-DEV"
        git push -uf origin main
        cd public
        git add .
        echo -n "Enter prod commit: "
        read -r COMMIT-PROD
        git commit -m "$COMMIT-PROD"
        git push -uf origin main
        ;;
esac
