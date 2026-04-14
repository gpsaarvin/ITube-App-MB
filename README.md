# iTube Learn

iTube Learn is an AI-powered learning platform that generates structured
roadmaps and matches YouTube tutorials for each topic.

## Setup

1. Install Flutter 3.x and ensure `flutter doctor` is green.
2. Install dependencies:
	 ```bash
	 flutter pub get
	 ```
3. Firebase setup:
	 - Go to the Firebase Console project **ai-road-map-80d4a**.
	 - Download **google-services.json** and place it at
		 `android/app/google-services.json`.
	 - Download **GoogleService-Info.plist** and place it at
		 `ios/Runner/GoogleService-Info.plist`.
	 - The web API key is **AIzaSyCjXsd4daIOv3sgACBamoATYzJFksHSkkI** (already
		 embedded in code).

## Run

```bash
flutter run
```

## Notes

- Firestore rules are defined in `firestore.rules`.
- OpenRouter and YouTube API keys are hardcoded in
	`lib/core/constants/api_constants.dart` as requested.
