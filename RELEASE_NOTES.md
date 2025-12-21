## Release v1.0.3 🎤

### ✨ New Features
- Modern transcription cards with smooth hover effects and animations
- Keyboard shortcuts for quick navigation (Ctrl/Cmd+1-5)
- Enhanced Floating Action Button with improved visual feedback
- Improved error handling with categorized messages
- Better loading states and user feedback

### 🔧 Improvements
- Fixed duplicate app shell code (consolidated to single implementation)
- Fixed VoiceRecordingUseCase tight coupling with static methods
- Updated StorageService to use async interface methods
- Fixed RecordingResult type issues
- Enhanced provider organization and state management

### 🏗️ Architecture
- Clean Architecture patterns properly implemented
- Interface-based design for better testability
- Improved cross-platform build scripts
- Added GitHub Actions workflows for automated releases

### 📦 Downloads

#### macOS (58MB)
- recognizing-1.0.3-macos.zip
- Extract and move to Applications folder
- Right-click and Open to bypass Gatekeeper

#### Windows (Available via GitHub Actions)
1. Go to Actions → "Build Windows Release"
2. Run workflow with version `1.0.3`
3. Download from Artifacts section

### ⚙️ Installation

**macOS:**
1. Download the ZIP file
2. Extract `recognizing.app`
3. Move to `/Applications` folder
4. Right-click → Open (if Gatekeeper warning appears)

**Windows:**
1. Use GitHub Actions to build
2. Download ZIP from artifacts
3. Extract all files
4. Run `recognizing.exe`

### 🎯 Quick Start
1. Install the app
2. Get your Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
3. Open app → Settings → Enter API key
4. Start recording with the mic button or Cmd+Shift+Space

### 🐛 Bug Reports
Report issues at: https://github.com/nicavcrm/recogniz.ing/issues