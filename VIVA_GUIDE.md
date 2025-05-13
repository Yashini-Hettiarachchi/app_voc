# NVLD Vocabulary Function - Viva Preparation Guide

This guide will help you prepare for your final year research viva presentation, focusing on the vocabulary function component of your NVLD application.

## 1. Project Overview

### Key Points to Emphasize

- **Research Problem**: Children with NVLD struggle with vocabulary acquisition and retention
- **Solution Approach**: Adaptive learning system with multiple input modalities
- **Innovation**: ML-based difficulty adjustment and multimodal interaction
- **Impact**: Improved vocabulary acquisition for children with special needs

### Vocabulary Function Highlights

- **Adaptive Difficulty**: Levels unlock based on performance
- **Multimodal Input**: Voice, handwriting, and multiple choice
- **Theme-Based Learning**: Organized by familiarity
- **Performance Analytics**: Detailed tracking and visualization

## 2. Technical Implementation

### Vocabulary Function Architecture

```
Frontend (Flutter)
    ↓
API Calls (HTTP)
    ↓
Backend (FastAPI)
    ↓
ML Model (Prediction)
```

### Key Components to Discuss

#### 1. Level Structure
- 10 questions per level
- Random selection from question pool
- Themed organization (familiar to unfamiliar)
- Bonus levels for calculation and time skills

#### 2. Adaptive Difficulty System
- **Implementation Details**:
  - External API integration (yasiruperera.pythonanywhere.com/predict)
  - Local fallback prediction
  - SharedPreferences for storing difficulty level
  - Lock/unlock visualization

- **Code Example**:
```dart
Future<Map<String, dynamic>> _getPrediction(int grade, int timeTaken) async {
  try {
    // External API call
    final response = await http.get(
      Uri.parse('https://yasiruperera.pythonanywhere.com/predict?grade=$grade&time_taken=$timeTaken'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'original_grade': data['input_data']['original_grade'],
        'adjusted_grade': data['adjusted_grade'],
        'adjustment': data['adjustment'],
        'status': data['status']
      };
    }
  } catch (error) {
    // Fallback to local API
    // ...
  }
}
```

#### 3. Input Methods
- **Voice Recognition**:
  - Using speech_to_text package
  - Error handling and fallbacks
  - User feedback mechanisms

- **Handwriting Recognition**:
  - SfSignaturePad implementation
  - OCR integration
  - Signature.png storage in uploads folder

- **Multiple Choice**:
  - UI implementation
  - Answer validation
  - Feedback mechanisms

#### 4. CRUD Operations
- **Create**: Storing vocabulary records
- **Read**: Fetching questions and performance data
- **Update**: Modifying difficulty levels
- **Delete**: Removing user records

## 3. Machine Learning Model

### Model Selection Process
- Evaluated multiple models:
  - Logistic Regression
  - Decision Tree
  - Random Forest
  - XGBoost
- Selected best performer based on accuracy

### Features Used
- Grade level (current difficulty)
- Time taken to complete
- Performance metrics

### Prediction Process
- Input: Current grade and time taken
- Output: Adjusted grade recommendation
- Implementation in both external and local APIs

## 4. Demo Preparation

### Key Functionality to Demonstrate
1. **Level Navigation**: Show the level selection screen with locked/unlocked levels
2. **Multiple Input Methods**: Demonstrate voice, handwriting, and multiple choice
3. **Adaptive Difficulty**: Show how completing levels affects difficulty
4. **Performance Tracking**: Display the analytics screens

### Potential Questions and Answers

#### Q: How does the vocabulary function determine when to lock/unlock levels?
A: The function uses a machine learning model that takes the current grade level and time taken as inputs. It predicts an adjusted grade level, which determines which levels are accessible. This creates a personalized learning path based on the child's performance.

#### Q: Why did you choose to implement multiple input methods?
A: Children with NVLD often have varying strengths and challenges. Some may excel at speaking but struggle with writing, or vice versa. Multiple input methods ensure that all children can engage with the content in ways that suit their abilities.

#### Q: How does the handwriting recognition work?
A: The handwriting recognition uses a signature pad component where children write their answers. The image is saved as signature.png in the uploads folder and sent to our OCR service, which uses Google Cloud Vision API to recognize the text. We also implemented a fallback mechanism that uses pattern matching when OCR is unavailable.

#### Q: What happens if the external prediction API is unavailable?
A: We implemented a local fallback prediction system that mimics the behavior of the external API. This ensures the application remains functional even without internet connectivity, which is crucial for educational applications that might be used in various settings.

## 5. Technical Challenges

### Challenges to Discuss

1. **Voice Recognition Accuracy**:
   - Challenge: Varying accents and background noise affected accuracy
   - Solution: Implemented multiple recognition attempts and fallback options

2. **Handwriting Recognition**:
   - Challenge: OCR accuracy with children's handwriting
   - Solution: Combined OCR with pattern matching and expected answer comparison

3. **Offline Functionality**:
   - Challenge: Maintaining prediction capability without internet
   - Solution: Implemented local prediction model as fallback

4. **Performance Optimization**:
   - Challenge: Ensuring smooth operation on lower-end devices
   - Solution: Optimized image processing and implemented lazy loading

## 6. Research Contributions

### Key Contributions to Highlight

1. **Adaptive Learning Model**: Novel approach to difficulty adjustment for children with NVLD
2. **Multimodal Input Framework**: Integrated system supporting multiple input methods
3. **Theme-Based Vocabulary Structure**: Organized approach from familiar to unfamiliar
4. **Performance Analytics**: Comprehensive tracking system for vocabulary development

### Research Findings

- Improved vocabulary retention compared to traditional methods
- Higher engagement levels through adaptive difficulty
- Reduced frustration through multimodal input options

## 7. Future Work

### Potential Enhancements

1. **Advanced ML Models**: Incorporating more features for better prediction
2. **Expanded Themes**: Additional vocabulary categories and difficulty levels
3. **Improved Voice Recognition**: Enhanced accuracy for children's speech patterns
4. **Collaborative Learning**: Adding multiplayer vocabulary games

## 8. Conclusion

### Key Takeaways

1. The vocabulary function provides an adaptive, engaging learning experience
2. Multiple input methods accommodate different learning styles
3. ML-based difficulty adjustment creates personalized learning paths
4. Comprehensive analytics track progress and guide intervention

### Final Statement

This research demonstrates how technology can be leveraged to create personalized learning experiences for children with special needs, specifically addressing vocabulary acquisition challenges faced by children with NVLD.
