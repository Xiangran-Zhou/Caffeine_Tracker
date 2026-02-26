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

## Download & Install (App Users)

This app is intended to be downloaded and used as a macOS application (not cloned and built from source).

Download here:

- [Download Caffeine Tracker for macOS](https://github.com/Xiangran-Zhou/Caffeine_Tracker/releases/latest/download/Caffeine-Tracker-macOS.zip)

1. Download the latest `Caffeine Tracker` app package from the release page (for example a `.zip` containing `Caffeine Tracker.app`).
2. Unzip the download if needed.
3. Drag `Caffeine Tracker.app` into your `Applications` folder.
4. Open the app from `Applications`.

## First Launch (macOS Trust / Security Prompt)

Because the app may be downloaded from the internet, macOS may block it on first launch.

If macOS shows a warning:

1. Try opening the app once (it may be blocked).
2. Open `System Settings` -> `Privacy & Security`.
3. Find the message about `Caffeine Tracker` being blocked.
4. Click `Open Anyway` (or confirm trust).
5. Open the app again and confirm.

After this, the app should open normally.

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
