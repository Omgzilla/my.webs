#!/bin/bash

# Update by upload my.webs content
git add .
echo "Enter commit: "
read -r commit
git commit -m "$commit"
git push -u origin main

# Upload public to omgzilla.github.io
cd public
echo "Adding content in public/*"
git add .
echo "Enter comment: "
read -r p-commit
git commit -m "$p-commit"
git push -u origin main
