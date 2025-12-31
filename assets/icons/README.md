# App Icon Assets

## Icon Design: "R" with Recording Dot

The app icon features a bold letter "R" (for "Recogniz.ing") with a red recording dot at the end of the right leg, symbolizing the app's voice recording functionality.

### Core Elements:
1. **"R" Letter**: Bold geometric sans-serif "R" in white
2. **Recording Dot**: Red circle (#EF4444) at the end of R's right leg
3. **Background**: Blue to teal to emerald gradient (#1E40AF → #0891B2 → #10B981)

### Color Scheme:
- **Background Gradient**: Deep blue (#1E40AF) → Cyan/Teal (#0891B2) → Emerald (#10B981)
- **Letter**: White (#FFFFFF)
- **Recording Dot**: Red (#EF4444) with white stroke

### Required Files:
- `app_icon.svg` - Source SVG (1024x1024 viewBox)
- `app_icon.png` - 1024x1024px PNG for main icon
- `app_icon_adaptive.svg` - Adaptive icon SVG (transparent background)
- `app_icon_adaptive.png` - 1024x1024px PNG for Android adaptive icon
- `app_icon_mac.png` - 1024x1024px PNG for macOS

### Design Specifications:
- **Canvas**: 1024x1024
- **Corner Radius**: 220px (Material Design 3)
- **"R" Position**: Centered (512, 512)
- **Recording Dot**: At (785, 765) - end of R's right leg

### Design Guidelines:
- Clean, minimalist design following 2025 trends
- Geometric sans-serif typography
- Trustworthy blue-green gradient for reliability
- Red accent creates immediate "recording" association

### Regenerating Icons:
```bash
# 1. Edit SVG files as needed
# 2. Generate PNG from SVG using ImageMagick:
convert -background none -resize 1024x1024 app_icon.svg app_icon.png
convert -background none -resize 1024x1024 app_icon_adaptive.svg app_icon_adaptive.png
convert -background none -resize 1024x1024 app_icon.svg app_icon_mac.png

# 3. Run flutter_launcher_icons
dart run flutter_launcher_icons
```
