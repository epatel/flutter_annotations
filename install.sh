#!/bin/bash

# Flutter Annotations Builder Installer
# Downloads and extracts only the builder folder from the flutter_annotations repository
# Usage: /bin/bash -c "$(curl -fsSL https://path/to/this/install.sh)"

set -e

ZIP_URL="https://github.com/epatel/flutter_annotations/archive/refs/heads/main.zip"
ZIP_FILE="flutter_annotations_main.zip"
TEMP_DIR="temp_extract"
BUILDER_FOLDER="builder"

echo "This will download and extract the flutter_annotations builder folder to the current directory."
echo "Current directory: $(pwd)"
echo ""
read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo "Downloading flutter_annotations from GitHub..."
curl -L -o "$ZIP_FILE" "$ZIP_URL"

echo "Creating temporary extraction directory..."
mkdir -p "$TEMP_DIR"

echo "Extracting zip file..."
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

echo "Moving builder folder to current directory..."
if [ -d "$TEMP_DIR/flutter_annotations-main/builder" ]; then
    cp -r "$TEMP_DIR/flutter_annotations-main/builder" .
    echo "Builder folder extracted successfully!"
else
    echo "Error: Builder folder not found in the extracted archive"
    exit 1
fi

echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
rm "$ZIP_FILE"

echo "Done! The builder folder is now available in the current directory."