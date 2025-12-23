# Generate App Icons

The app icon SVG has been created at `app_icon.svg`. To generate the required PNG files:

## Using online tool (easiest):
1. Open `app_icon.svg` in a browser
2. Right-click and "Save as PNG" as `app_icon.png` (1024x1024)
3. Use an online tool like https://convertio.co/svg-png/ for conversion

## Using ImageMagick (if installed):
```bash
# Install ImageMagick first
# macOS: brew install imagemagick
# Ubuntu: sudo apt-get install imagemagick

# Convert to PNG
convert app_icon.svg -resize 1024x1024 app_icon.png
convert app_icon.svg -resize 1024x1024 -background transparent -alpha remove app_icon_adaptive.png
convert app_icon.svg -resize 512x512 app_icon_mac.png
```

## After generating icons:
1. Run `flutter pub get` to ensure flutter_launcher_icons is installed
2. Run `dart run flutter_launcher_icons` to generate all platform icons
3. The generated icons will be placed in:
   - android/app/src/main/res/
   - ios/Runner/Assets.xcassets/AppIcon.appiconset/
   - windows/runner/resources/
   - macos/Runner/Assets.xcassets/AppIcon.iconset/

## Icon Design:
- Represents voice (sound waves) transforming into text (lines)
- Uses blue to cyan gradient
- Clean, modern design suitable for all platforms