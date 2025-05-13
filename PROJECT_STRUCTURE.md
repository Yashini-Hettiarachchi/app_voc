# NVLD Vocabulary Learning Application - Project Structure

This document provides a comprehensive overview of the project structure for the NVLD Vocabulary Learning Application, a Flutter-based mobile application designed to help children with Non-Verbal Learning Disability (NVLD) improve their vocabulary skills.

## Root Directory Structure

```
nvld_voc/
├── android/                # Android platform-specific code
├── assets/                 # Application assets (images, fonts, etc.)
│   ├── backgrounds/        # Background images for screens
│   ├── fonts/              # Custom fonts
│   ├── icons/              # App icons and UI elements
│   ├── images/             # Images used in the app
│   │   ├── desk/           # Images for difference recognition activities
│   │   └── kitchen/        # More images for activities
│   ├── instructions/       # PDF instructions for activities
│   ├── audios/             # Audio files for the app
│   └── videos/             # Video files for tutorials
├── backend/                # FastAPI backend server
│   ├── main.py             # Main server file
│   └── requirements.txt    # Backend dependencies
├── ios/                    # iOS platform-specific code
├── lib/                    # Main Flutter application code
│   ├── constants/          # App constants and configuration
│   ├── models/             # Data models
│   ├── navigations/        # Screen navigation and UI
│   └── widgets/            # Reusable UI components
├── linux/                  # Linux platform-specific code
├── macos/                  # macOS platform-specific code
├── test/                   # Test files
├── web/                    # Web platform-specific code
├── windows/                # Windows platform-specific code
├── pubspec.yaml            # Flutter dependencies
└── README.md               # Project documentation
```

## Detailed Structure

### `lib/` Directory (Main Application Code)

```
lib/
├── constants/              # App constants and configuration
│   ├── env.dart            # Environment configuration
│   └── styles.dart         # UI styles and themes
├── models/                 # Data models
│   └── session_provider.dart # User session management
├── navigations/            # Screen navigation and UI
│   ├── chatbot_screen.dart        # Chatbot interface
│   ├── difference_find_screen.dart # Difference recognition activity
│   ├── difference_levels_screen.dart # Levels for difference recognition
│   ├── direction_levels_screen.dart # Direction recognition levels
│   ├── home_screen.dart            # Main home screen
│   ├── image_test_screen.dart      # Image-based vocabulary tests
│   ├── landing_screen.dart         # Initial landing page
│   ├── previous_vocabulary_records_screen.dart # History view
│   ├── profile_screen.dart         # User profile
│   ├── puzzle_levels_screen.dart   # Puzzle activity levels
│   ├── signin_window.dart          # Login screen
│   ├── signup_window.dart          # Registration screen
│   ├── vocabulary_list_screen.dart # Vocabulary levels selection
│   ├── vocabulary_screen.dart      # Main vocabulary activity
│   ├── vocablury_results_screen.dart # Results after completing activity
│   └── vocabuloary_performance_screen.dart # Performance analytics
└── widgets/                # Reusable UI components
    ├── custom_card.dart    # Custom card widget
    ├── idea_card.dart      # Idea presentation card
    └── long_card.dart      # Long format card for lists
```

### `backend/` Directory (Server-Side Code)

```
backend/
├── main.py                 # Main FastAPI server
├── models/                 # Data models for the API
├── routes/                 # API route handlers
├── services/               # Business logic services
├── utils/                  # Utility functions
└── requirements.txt        # Python dependencies
```

## Key Files

### Configuration Files

- **pubspec.yaml**: Defines Flutter dependencies and assets configuration
- **lib/constants/env.dart**: Environment configuration including API endpoints and vocabulary levels
- **lib/constants/styles.dart**: UI styling constants

### Core Application Files

- **lib/main.dart**: Entry point of the Flutter application
- **lib/models/session_provider.dart**: Manages user session and authentication
- **lib/navigations/home_screen.dart**: Main dashboard after login
- **lib/navigations/vocabulary_list_screen.dart**: Vocabulary levels selection screen
- **lib/navigations/vocabulary_screen.dart**: Main vocabulary activity screen

### Vocabulary Function Files

- **lib/navigations/vocabulary_screen.dart**: Implements the main vocabulary activity with multiple input methods (voice, handwriting, multiple choice)
- **lib/navigations/vocabulary_list_screen.dart**: Manages level selection and difficulty progression
- **lib/navigations/vocablury_results_screen.dart**: Displays results and generates reports
- **lib/navigations/vocabuloary_performance_screen.dart**: Shows performance analytics and progress tracking

### Backend Files

- **backend/main.py**: Main FastAPI server with API endpoints
- **backend/models/**: Data models for vocabulary records and user data

## Platform-Specific Directories

- **android/**: Android platform configuration and native code
- **ios/**: iOS platform configuration and native code
- **linux/**: Linux platform configuration
- **macos/**: macOS platform configuration
- **windows/**: Windows platform configuration
- **web/**: Web platform configuration

## Assets Organization

```
assets/
├── backgrounds/            # Background images for screens
├── fonts/                  # Custom fonts
│   ├── font01/             # ABeeZee font family
│   └── font02/             # Rubik font family
├── icons/                  # App icons and UI elements
│   ├── win2.gif            # Success animation
│   ├── studymore.gif       # Study reminder animation
│   └── tryagain.gif        # Retry animation
├── images/                 # Images used in the app
│   ├── desk/               # Images for difference recognition
│   ├── kitchen/            # Kitchen-related images
│   ├── body_parts/         # Body parts images
│   ├── colors/             # Color images
│   ├── fruits/             # Fruit images
│   ├── objects/            # Common object images
│   ├── animals/            # Animal images
│   ├── buildings/          # Building images
│   ├── vehicles/           # Vehicle images
│   ├── places/             # Place images
│   └── professions/        # Profession images
├── instructions/           # PDF instructions
│   └── vocabulary booklet.pdf # Vocabulary instructions
├── audios/                 # Audio files
└── videos/                 # Video tutorials
```

## Dependencies

The application uses several key dependencies:

- **Flutter SDK**: Core framework for cross-platform development
- **http**: For API requests to the backend
- **provider**: For state management
- **shared_preferences**: For local storage
- **speech_to_text**: For voice recognition
- **syncfusion_flutter_signaturepad**: For handwriting input
- **flutter_tts**: For text-to-speech functionality
- **fl_chart**: For performance visualization
- **flutter_pdfview**: For viewing PDF instructions

## Build and Run

To build and run the application:

1. Ensure Flutter SDK is installed
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch the application

For the backend:

1. Navigate to the backend directory
2. Install dependencies with `pip install -r requirements.txt`
3. Run the server with `python main.py`
