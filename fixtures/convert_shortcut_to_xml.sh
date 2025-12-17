#!/bin/bash

# AI Voice Typing Shortcut to XML Converter
# Usage: ./convert_shortcut_to_xml.sh [path_to_shortcut]

SHORTCUT_NAME="ai-voice-typing.shortcut"
OUTPUT_NAME="ai-voice-typing-readable.xml"

# Check if shortcut path is provided
if [ $# -eq 1 ]; then
    INPUT_FILE="$1"
else
    # Try to find the shortcut file
    if [ -f "$SHORTCUT_NAME" ]; then
        INPUT_FILE="$SHORTCUT_NAME"
    elif [ -f "~/Desktop/$SHORTCUT_NAME" ]; then
        INPUT_FILE="$HOME/Desktop/$SHORTCUT_NAME"
    elif [ -f "~/Downloads/$SHORTCUT_NAME" ]; then
        INPUT_FILE="$HOME/Downloads/$SHORTCUT_NAME"
    else
        echo "Error: Cannot find $SHORTCUT_NAME"
        echo "Please provide the path to your shortcut file:"
        echo "  ./convert_shortcut_to_xml.sh /path/to/ai-voice-typing.shortcut"
        exit 1
    fi
fi

echo "Converting shortcut to XML..."
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_NAME"

# Convert to XML
plutil -convert xml1 "$INPUT_FILE" -o "$OUTPUT_NAME"

if [ $? -eq 0 ]; then
    echo "✓ Conversion successful!"
    echo "XML file created: $OUTPUT_NAME"

    # Try to open with default editor
    if command -v code &> /dev/null; then
        echo "Opening with VS Code..."
        code "$OUTPUT_NAME"
    elif command -v open &> /dev/null; then
        echo "Opening with default application..."
        open "$OUTPUT_NAME"
    fi
else
    echo "✗ Conversion failed!"
    exit 1
fi