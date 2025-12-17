// Run this script to generate PNG icons from SVGs
// dart run scripts/generate_icons.dart
// Or use an online SVG to PNG converter

void main() {
  print('''
To generate PNG icons for the menu bar:

Option 1: Use an online converter
  1. Go to https://svgtopng.com/ or https://cloudconvert.com/svg-to-png
  2. Upload assets/icons/tray_icon.svg
  3. Set size to 44x44 (for @2x retina)
  4. Download and save as assets/icons/tray_icon.png
  5. Repeat for tray_recording.svg -> tray_recording.png

Option 2: Use ImageMagick (if installed)
  brew install imagemagick
  cd assets/icons
  convert -background none -resize 44x44 tray_icon.svg tray_icon.png
  convert -background none -resize 44x44 tray_recording.svg tray_recording.png

Option 3: Use rsvg-convert (if installed)
  brew install librsvg
  cd assets/icons
  rsvg-convert -w 44 -h 44 tray_icon.svg > tray_icon.png
  rsvg-convert -w 44 -h 44 tray_recording.svg > tray_recording.png

For macOS menu bar, recommended sizes:
  - 22x22 (@1x)
  - 44x44 (@2x for Retina displays)
''');
}
