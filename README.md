# NVLD Vocabulary Learning Application

## Final Year Research Project at SLIIT

This application is designed to help children with Non-Verbal Learning Disability (NVLD) improve their vocabulary skills through an adaptive, interactive learning platform.

## Project Overview

The NVLD Vocabulary Learning Application provides a structured, theme-based approach to vocabulary learning with adaptive difficulty levels. The system uses machine learning to adjust difficulty based on user performance, creating a personalized learning experience.

### Key Features

- **Adaptive Difficulty System**: Levels are locked/unlocked based on performance using ML prediction
- **Multiple Input Methods**: Voice recognition, handwriting recognition, and multiple choice
- **Theme-Based Learning**: Vocabulary organized by familiar to unfamiliar themes
- **Performance Tracking**: Comprehensive analytics on user progress
- **Child-Friendly Interface**: Engaging UI with clear instructions and visual feedback

## Technical Architecture

### Frontend (Flutter)
- Cross-platform mobile application built with Flutter
- Interactive UI with multiple learning modes
- Real-time feedback and progress visualization

### Backend (FastAPI)
- RESTful API built with FastAPI
- ML model for difficulty prediction
- OCR integration for handwriting recognition
- User performance data storage and analysis

## Core Functionality

### Vocabulary Function

The vocabulary function is the core component of the application, implementing:

1. **Level Structure**:
   - Each level contains exactly 10 questions
   - Questions are randomly selected from a larger pool
   - Levels are organized by themes (familiar to unfamiliar)
   - Bonus levels for calculation and time-saving skills

2. **Adaptive Difficulty**:
   - "Lock/Unlock" mechanism based on ML prediction
   - API endpoint at yasiruperera.pythonanywhere.com/predict
   - Local fallback prediction when external API is unavailable
   - Difficulty adjustment based on score and time taken

3. **Input Methods**:
   - Voice recognition for spoken answers
   - Handwriting recognition using signature pad
   - Multiple choice selection for basic levels

4. **Performance Tracking**:
   - Score calculation based on correct answers and time
   - Historical performance visualization
   - Comparison with previous attempts

## CRUD Operations

The application implements full CRUD (Create, Read, Update, Delete) operations:

1. **Create**:
   - Create new vocabulary activity records
   - Store user performance data
   - Save handwriting samples

2. **Read**:
   - Retrieve vocabulary questions by level
   - Fetch user performance history
   - Get difficulty prediction

3. **Update**:
   - Update user scores and progress
   - Modify difficulty level based on performance
   - Adjust user preferences

4. **Delete**:
   - Remove vocabulary records
   - Delete user data when requested

## Machine Learning Model

The application uses a machine learning model to predict appropriate difficulty levels:

1. **Model Implementation**:
   - Multiple models evaluated (Logistic Regression, Decision Tree, Random Forest, XGBoost)
   - Best performing model selected and deployed
   - Features include grade level, time taken, and performance metrics

2. **Prediction Process**:
   - Input: Current grade level and time taken
   - Output: Adjusted grade level recommendation
   - Fallback mechanism for offline operation

3. **Integration**:
   - Primary API: yasiruperera.pythonanywhere.com/predict
   - Local API fallback for reliability

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Python 3.8+
- MongoDB (for data storage)

### Installation

1. Clone the repository:
```
git clone https://github.com/Yashini-Hettiarachchi/nvld_voc.git
```

2. Install Flutter dependencies:
```
flutter pub get
```

3. Run the app:
```
flutter run
```

## Backend Setup

The vocabulary function backend can be set up by:

1. Navigate to the backend directory:
```
cd backend
```

2. Install Python dependencies:
```
pip install -r requirements.txt
```

3. Run the backend server:
```
python main.py
```

## Viva Preparation Guide

### Key Points to Discuss

1. **Project Motivation**:
   - Challenges faced by children with NVLD
   - Importance of vocabulary development
   - Gap in existing educational tools

2. **Technical Implementation**:
   - Architecture decisions and trade-offs
   - ML model selection and training process
   - Handling of offline scenarios

3. **Research Methodology**:
   - Literature review findings
   - Testing approach with target users
   - Evaluation metrics and results

4. **Future Enhancements**:
   - Additional features planned
   - Scaling considerations
   - Potential research extensions

## Project Structure

```
project/
├── backend/                # FastAPI backend
│   ├── main.py            # Main server file
│   └── requirements.txt   # Backend dependencies
├── lib/                    # Flutter frontend
│   ├── constants/         # App constants and configuration
│   ├── models/            # Data models
│   ├── navigations/       # Screen navigation
│   └── widgets/           # Reusable UI components
├── pubspec.yaml            # Flutter dependencies
└── README.md              # Project documentation
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact Information

For any questions regarding this research project, please contact:
- Researcher: Yashini Hettiarachchi
- Institution: Sri Lanka Institute of Information Technology (SLIIT)
