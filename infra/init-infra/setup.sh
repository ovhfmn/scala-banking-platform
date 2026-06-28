#!/bin/bash

# Remove any existing UID/GID lines (correct or broken)
sed -i '/^UID=/d; /^GID=/d' .env

# Add fresh, correctly computed numeric values
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env

# Verify
cat .env
echo "Host UID/GID populated into .env successfully!"