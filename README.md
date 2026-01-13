# Pitch Timer

A timer for public speakers that changes screen color from green to red as time runs out.

## Features

- ⏱️ **Customizable Duration** - Set minutes and seconds
- 🎨 **Visual Color Transitions**:
  - Green: 100% - 50% time remaining
  - Yellow: 50% - 25% time remaining
  - Red: 25% - 0% time remaining
- ⏯️ **Pause/Resume** - Control your presentation flow
- 🔄 **Reset** - Start over anytime
- 📱 **Screen Wake Lock** - Keeps screen on during timer
- 🎯 **Simple Design** - Clean, minimalist Material 3 interface

## Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- iOS/Android development environment

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd pitch_timer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

1. **Set Duration**
   - Enter minutes and seconds
   - Tap "Start" to begin

2. **Watch the Timer**
   - Large countdown display
   - Background color transitions automatically:
     - Green when you have plenty of time
     - Yellow when you're halfway through
     - Red when time is running out

3. **Control the Timer**
   - Tap "Pause" to pause
   - Tap "Resume" to continue
   - Tap "Reset" to start over

## Technical Details

- **Framework**: Flutter
- **Design**: Material 3
- **Typography**: Inter (Google Fonts)
- **Wake Lock**: wakelock_plus package

## App Series

This app is part of the Funny Apps series by `com.funnyapps`. Each app focuses on a simple, useful, and fun concept with clean design.

## License

[Add your license here]

## Author

[Add your name/contact here]
