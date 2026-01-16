# Generate App Icons

The app icon SVGs are the single source of truth. To generate PNG files:

## Using ImageMagick (recommended):
```bash
# From project root, run:
convert -background none -resize 1024x1024 assets/icons/app_icon.svg assets/icons/app_icon.png
convert -background none -resize 1024x1024 assets/icons/app_icon_adaptive.svg assets/icons/app_icon_adaptive.png
convert -background none -resize 1024x1024 assets/icons/app_icon.svg assets/icons/app_icon_mac.png

# Generate all size variants:
mkdir -p assets/icons/generated
convert -background none -resize 1024x1024 assets/icons/app_icon.svg assets/icons/generated/app_icon_1024.png
convert -background none -resize 512x512 assets/icons/app_icon.svg assets/icons/generated/app_icon_512.png
convert -background none -resize 256x256 assets/icons/app_icon.svg assets/icons/generated/app_icon_256.png
convert -background none -resize 128x128 assets/icons/app_icon.svg assets/icons/generated/app_icon_128.png
convert -background none -resize 64x64 assets/icons/app_icon.svg assets/icons/generated/app_icon_64.png
convert -background none -resize 32x32 assets/icons/app_icon.svg assets/icons/generated/app_icon_32.png
convert -background none -resize 16x16 assets/icons/app_icon.svg assets/icons/generated/app_icon_16.png
```

## After generating icons:
```bash
# Run flutter_launcher_icons to update all platform icons
dart run flutter_launcher_icons
```

## Icon Design:
- Bold "R" letter for "Recogniz.ing"
- Red recording dot at end of R's right leg
- Blue to teal to emerald gradient (trust, reliability, accuracy)
- Material Design 3 compliant (220px corner radius)
