# App Icon Assets

## Icon Design Concept: "Voice to Text Flow"

The app icon should represent the transformation of voice into text with these visual elements:

### Core Elements:
1. **Sound Waves**: 2-3 curved lines on the left representing sound/audio
2. **Text Lines**: 3-4 horizontal lines on the right representing text
3. **Transformation Arrow**: A subtle arrow or gradient connecting sound to text
4. **Microphone Icon**: Optional small microphone symbol integrated into the design

### Color Scheme:
- **Primary**: Blue (#2196F3) to Cyan (#00BCD4) gradient
- **Background**: White or very light gray
- **Accent**: Dark blue or black for text elements

### Required Files:
- `app_icon.png` - 1024x1024px PNG for main icon
- `app_icon_adaptive.png` - 1024x1024px PNG for Android adaptive icon (transparent background)
- `app_icon_mac.png` - 512x512px PNG for macOS

### Design Guidelines:
- Keep it simple and recognizable at small sizes
- Use flat design with subtle gradients
- Ensure good contrast on both light and dark backgrounds
- Avoid text in the icon
- Center the main visual elements
- Maintain rounded corners where appropriate

### Implementation:
1. Create the icon using a design tool (Figma, Illustrator, etc.)
2. Export in the required sizes
3. Run `flutter pub get` to install flutter_launcher_icons
4. Run `dart run flutter_launcher_icons` to generate all platform-specific icons