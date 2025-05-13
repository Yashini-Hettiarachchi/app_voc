# Setup and Testing Guide

This document provides detailed instructions for setting up, running, and testing the NVLD Vocabulary Learning Application.

## Project Setup

### Prerequisites

1. **Flutter SDK**:
   - Install Flutter SDK (latest stable version)
   - Run `flutter doctor` to verify installation

2. **Python Environment**:
   - Python 3.8+ required
   - Virtual environment recommended

3. **MongoDB**:
   - Install MongoDB Community Edition
   - Start MongoDB service

4. **IDE**:
   - Visual Studio Code with Flutter and Dart extensions (recommended)
   - Android Studio with Flutter plugin (alternative)

### Frontend Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Yashini-Hettiarachchi/nvld_voc.git
   cd nvld_voc
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure environment**:
   - Check `lib/constants/env.dart` for configuration settings
   - Update `serverUrl` to point to your backend server

4. **Run the application**:
   ```bash
   flutter run
   ```

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Create virtual environment** (optional but recommended):
   ```bash
   python -m venv venv
   # On Windows
   venv\Scripts\activate
   # On macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables**:
   - Create a `.env` file in the backend directory
   - Add necessary configuration (MongoDB URI, API keys, etc.)

5. **Run the server**:
   ```bash
   python main.py
   ```
   The server will start on http://localhost:8000

## Testing the Application

### Manual Testing Checklist

#### 1. Vocabulary Function

- [ ] **Level Navigation**:
  - Verify all levels are displayed
  - Confirm locked levels show lock icon
  - Test level selection for accessible levels

- [ ] **Adaptive Difficulty**:
  - Complete a level with high score
  - Verify next difficulty level unlocks
  - Complete a level with low score
  - Verify difficulty adjustment

- [ ] **Input Methods**:
  - Test voice recognition input
  - Test handwriting recognition input
  - Test multiple choice selection

- [ ] **Performance Tracking**:
  - Complete a level and check results screen
  - Verify score calculation
  - Check performance history screen

#### 2. API Testing

- [ ] **Prediction API**:
  - Test external API: `https://yasiruperera.pythonanywhere.com/predict?grade=2&time_taken=45`
  - Test local API: `http://localhost:8000/predict?grade=2&time_taken=45`
  - Verify fallback mechanism by disabling external API

- [ ] **Vocabulary Records API**:
  - Test creating a new record
  - Test retrieving user records
  - Test deleting a record

- [ ] **OCR API**:
  - Test handwriting recognition endpoint
  - Verify signature.png is saved correctly

### Automated Testing

#### Frontend Tests

Run Flutter tests:
```bash
flutter test
```

Key test files:
- `test/vocabulary_function_test.dart`: Tests for vocabulary functionality
- `test/api_service_test.dart`: Tests for API integration

#### Backend Tests

Run Python tests:
```bash
cd backend
pytest
```

Key test files:
- `tests/test_prediction.py`: Tests for prediction functionality
- `tests/test_ocr.py`: Tests for OCR functionality

## Troubleshooting

### Common Issues and Solutions

#### 1. Backend Connection Issues

**Problem**: Frontend cannot connect to backend server.

**Solutions**:
- Verify backend server is running
- Check `serverUrl` in `lib/constants/env.dart`
- Ensure network permissions are granted
- Check for firewall or antivirus blocking connections

#### 2. Voice Recognition Issues

**Problem**: Voice recognition not working properly.

**Solutions**:
- Ensure microphone permissions are granted
- Check internet connection (required for some speech recognition)
- Speak clearly and in a quiet environment
- Verify `speech_to_text` package is properly configured

#### 3. Handwriting Recognition Issues

**Problem**: Handwriting recognition not working.

**Solutions**:
- Verify OCR API is configured correctly
- Check if `uploads` directory exists and is writable
- Ensure signature pad is working properly
- Test with clear, simple handwriting first

#### 4. MongoDB Connection Issues

**Problem**: Backend cannot connect to MongoDB.

**Solutions**:
- Verify MongoDB service is running
- Check connection string in environment variables
- Ensure network allows MongoDB connections
- Check MongoDB user permissions

## Deployment

### Backend Deployment

1. **Deploy to PythonAnywhere**:
   - Create a PythonAnywhere account
   - Upload backend code
   - Install dependencies using pip
   - Configure WSGI file to point to your FastAPI app
   - Set up environment variables

2. **Alternative: Deploy to Heroku**:
   - Create a Heroku account
   - Install Heroku CLI
   - Create a `Procfile`:
     ```
     web: gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
     ```
   - Deploy using Git:
     ```bash
     heroku create
     git push heroku main
     ```

### Frontend Deployment

1. **Build Flutter Web**:
   ```bash
   flutter build web
   ```

2. **Deploy to Firebase Hosting**:
   - Install Firebase CLI
   - Initialize Firebase:
     ```bash
     firebase init hosting
     ```
   - Deploy to Firebase:
     ```bash
     firebase deploy --only hosting
     ```

## Performance Optimization

### Backend Optimization

1. **Database Indexing**:
   - Create indexes for frequently queried fields
   - Use projection to limit returned fields

2. **Caching**:
   - Implement Redis for caching frequent queries
   - Cache prediction results

### Frontend Optimization

1. **Asset Optimization**:
   - Compress images
   - Use appropriate image formats

2. **State Management**:
   - Use efficient state management (Provider)
   - Minimize rebuilds

## Security Considerations

1. **API Security**:
   - Implement rate limiting
   - Use HTTPS for all API calls
   - Validate all inputs

2. **Data Protection**:
   - Encrypt sensitive data
   - Implement proper authentication
   - Follow data protection regulations

## Monitoring and Maintenance

1. **Error Logging**:
   - Implement error logging
   - Set up alerts for critical errors

2. **Performance Monitoring**:
   - Track API response times
   - Monitor database performance

3. **Regular Updates**:
   - Keep dependencies updated
   - Apply security patches
