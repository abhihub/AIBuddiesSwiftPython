# AIBuddies - Your macOS AI Companion 🐕

A delightful macOS desktop app featuring Leo Pet, your friendly AI assistant that sits as a floating icon on your screen.

## Features

- **Floating Icon**: Always-visible circular icon in the bottom-right corner
- **Chat Interface**: Beautiful chat window with Leo Pet
- **OpenAI Integration**: Powered by GPT for intelligent responses
- **Native macOS Experience**: Behaves like a native Mac application
- **Notification System**: Visual indicators when AI responds
- **Easy Setup**: Simple API key configuration

## Architecture

- **Frontend**: SwiftUI macOS app
- **Backend**: Python script with OpenAI API integration
- **Integration**: Python backend bundled within the macOS app

## Project Structure

```
AIBuddies/
├── AIBuddies.xcodeproj/     # Xcode project
├── AIBuddies/               # Swift source files
│   ├── AIBuddiesApp.swift   # Main app entry point
│   ├── ContentView.swift    # Main content view
│   ├── FloatingIconView.swift # Floating icon implementation
│   ├── ChatWindowView.swift # Chat interface
│   ├── ChatManager.swift    # Chat logic and Python integration
│   ├── ai_backend.py       # Python OpenAI backend
│   ├── requirements.txt    # Python dependencies
│   └── AIBuddies.entitlements # App permissions
├── build_and_distribute.sh  # Build script
├── exportOptions.plist     # Export configuration
└── README.md              # This file
```

## Building

1. **Prerequisites**:
   - Xcode 15 or later
   - macOS 13.0 or later
   - Python 3 with OpenAI library

2. **Build Commands**:
   ```bash
   # Make build script executable
   chmod +x build_and_distribute.sh
   
   # Build and create distribution
   ./build_and_distribute.sh
   ```

3. **Manual Build**:
   - Open `AIBuddies.xcodeproj` in Xcode
   - Select AIBuddies scheme
   - Build for Release
   - Archive and export

## Installation for Users

1. Download the AIBuddies.app
2. Drag to Applications folder
3. Open the app (right-click > Open if unsigned)
4. Enter your OpenAI API key when prompted
5. The floating icon will appear in the bottom-right
6. Click the icon to start chatting!

## Configuration

- **API Key**: Set via the prompt when first launching
- **Settings**: Stored in macOS UserDefaults
- **Python Backend**: Bundled within the app resources

## Key Components

### FloatingIconView
- Always-on-top circular icon
- Positioned in bottom-right corner
- Shows notification indicator
- Opens chat window on click

### ChatWindowView
- Mobile-style chat interface
- Blue gradient background matching design
- Message bubbles for user/AI
- Loading animations

### ChatManager
- Handles OpenAI API communication via Python
- Manages conversation history
- Controls notification states
- Window management

## Python Integration

The app bundles a Python script (`ai_backend.py`) that:
- Accepts messages as command-line arguments
- Calls OpenAI API with the message
- Returns JSON response with AI reply
- Maintains conversation context

## Distribution

The build script creates:
- Signed macOS application
- Installation instructions
- ZIP or DMG distribution package

## Development Notes

- Uses SwiftUI for modern macOS UI
- Implements NSWindow for floating behavior
- Python subprocess for AI backend
- Bundle resources for Python script inclusion
- Sandboxed with network permissions

## Future Enhancements

- Multiple AI models support
- Custom themes and appearances  
- Voice chat capabilities
- Plugin system for extensions
- Mac App Store distribution