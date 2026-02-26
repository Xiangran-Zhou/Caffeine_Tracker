# Caffeine Tracker

Caffeine Tracker is a macOS menu bar app for logging caffeine intake and viewing an estimated active caffeine level over time using a simple half-life model.

## Features

- Menu bar app (`MenuBarExtra`) with quick access
- Add caffeine intake by:
  - Quick Presets
  - Brand Products (US preset database)
  - Manual mg input
- Intake time selection
- Estimated active caffeine (half-life based)
- Status badge and quick insights
- Bedtime residual estimate (based on your profile bedtime)
- Today's intake list with delete support
- User profile & preferences (weight, bedtime, sensitivity)
- Local storage on device (`UserDefaults`)

## Run Locally (Recommended for This Project)

This is a learning / practice project. The recommended way to use it is to run it locally from source in Xcode.

### Option A: Clone and Run in Xcode (Recommended)

1. Clone the repository:
   - `git clone https://github.com/Xiangran-Zhou/Caffeine_Tracker.git`
2. Open the project in Xcode:
   - `Caffeine_Tracker/Caffeine_Tracker/Caffeine_Tracker.xcodeproj`
3. Select `My Mac` as the run destination.
4. Build and run (`Command + R`).
5. Click the coffee cup icon in the macOS menu bar to open the app panel.

### Option B: Download Source ZIP from GitHub

If you do not want to use Git:

1. Open the repository page:
   - [Caffeine Tracker Repository](https://github.com/Xiangran-Zhou/Caffeine_Tracker)
2. Click `Code` -> `Download ZIP`
3. Unzip the project
4. Open `Caffeine_Tracker/Caffeine_Tracker/Caffeine_Tracker.xcodeproj` in Xcode
5. Run with `My Mac`

## macOS First-Run Notes (Local Build)

- If macOS shows a warning for your local build, use:
  - `Right-click app -> Open`, or
  - `System Settings -> Privacy & Security -> Open Anyway`
- This project is not distributed as a notarized production app release.

## How to Use

1. Launch the app.
2. Click the coffee cup icon in the macOS menu bar.
3. Add an intake using a preset, brand product, or manual input.
4. Adjust time if needed, then click `Add`.
5. Review:
   - Estimated active caffeine
   - Status badge / quick insights
   - Today Timeline (expand to view)
   - Today's Intakes list
6. Delete an intake if you entered it incorrectly.

## Notes

- All values shown in the app are estimates for reference only.
- The app does not provide medical advice.
- Caffeine values can vary by product flavor, region, and packaging.

## Privacy

- No network requests are required for core functionality.
- Data is stored locally on your Mac.

## Support

If you encounter issues (launch problems, picker behavior, incorrect values, etc.), please report them on the project repository issues page.
