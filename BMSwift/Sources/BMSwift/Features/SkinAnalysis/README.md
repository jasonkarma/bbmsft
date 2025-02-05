# Skin Analysis Feature

## Required Info.plist Entries

Add these entries to your app's Info.plist:

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to analyze your skin condition</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to analyze your skin from existing photos</string>
```

## Usage

```swift
import BMSwift

// Present the skin analysis view
@State private var showSkinAnalysis = false

Button("Analyze Skin") {
    showSkinAnalysis = true
}
.sheet(isPresented: $showSkinAnalysis) {
    SkinAnalysisView(isPresented: $showSkinAnalysis)
}
```

## Features

- Take photos using camera
- Select photos from library
- Analyze skin condition
- Get detailed scores and recommendations
- Automatic image caching
- Error handling

## Error Cases

The feature handles these error scenarios:
- Camera permission denied
- Photo library permission denied
- Image compression failure
- Upload failures
- API rate limits
- Network errors

## Dependencies

- Imgur API for image hosting
- RapidAPI for skin analysis
