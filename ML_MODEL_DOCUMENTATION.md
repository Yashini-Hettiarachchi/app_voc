# Machine Learning Model Documentation

This document provides detailed information about the machine learning model used in the NVLD Vocabulary Learning Application for predicting appropriate difficulty levels.

## Overview

The vocabulary function uses a machine learning model to predict the appropriate difficulty level for a user based on their current performance. This adaptive approach ensures that children are challenged appropriately without becoming frustrated or bored.

## Model Architecture

### Model Selection

The application evaluates multiple classification models to determine the most effective predictor:

1. **Logistic Regression**: A linear model for classification
2. **Decision Tree**: A tree-based model that makes decisions based on feature values
3. **Random Forest**: An ensemble of decision trees for improved accuracy
4. **XGBoost**: A gradient boosting framework known for performance and accuracy

The best-performing model is selected based on accuracy metrics and deployed in the application.

### Implementation

The model training and selection process is implemented in the backend:

```python
# Define models
models = {
    "Logistic Regression": LogisticRegression(max_iter=1000),
    "Decision Tree": DecisionTreeClassifier(max_depth=2),
    "Random Forest": RandomForestClassifier(n_estimators=50, max_depth=2),
    "XGBoost": XGBClassifier(use_label_encoder=False, eval_metric='logloss', max_depth=2)
}

best_accuracy = 0
for name, model in models.items():
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"{name}: Accuracy = {acc:.4f}")
    if acc > best_accuracy:
        best_accuracy = acc
        best_model = model

# Save the best model
joblib.dump(best_model, 'best_model.pkl')
```

## Features and Preprocessing

### Input Features

The model uses the following features:

1. **Grade Level**: The current difficulty level of the user (1-5)
2. **Time Taken**: The time taken to complete the vocabulary exercise (in seconds)
3. **Noise**: A small random value to introduce variability and prevent overfitting

### Preprocessing Steps

1. **Grade Encoding**: Convert categorical grade levels to numerical values
2. **Time Normalization**: Scale time values to a standard range (0-1)
3. **Feature Engineering**: Add noise as a feature to improve generalization

```python
# Encode grade (assuming label encoder was used during training)
le_grade = LabelEncoder()
le_grade.fit(['A', 'B', 'C', 'D', 'F'])  # Adjust based on your actual grades
input_data['grade'] = le_grade.transform(input_data['grade'])

# Normalize time_taken
scaler = MinMaxScaler()
scaler.fit([[0], [100]])  # Adjust range based on your data
input_data[['time_taken']] = scaler.transform(input_data[['time_taken']])
```

## Prediction Process

### API Endpoint

The primary prediction endpoint is hosted at `yasiruperera.pythonanywhere.com/predict`, with a local fallback implementation in the backend.

### External API

The external API accepts grade level and time taken as parameters and returns an adjusted grade level:

```
GET https://yasiruperera.pythonanywhere.com/predict?grade=2&time_taken=45
```

Response:
```json
{
  "input_data": {
    "original_grade": 2,
    "time_taken": 45
  },
  "adjusted_grade": 1,
  "adjustment": -1,
  "status": "success"
}
```

### Local Fallback Implementation

The local implementation mimics the behavior of the external API:

```python
def predict_grade(grade, time_taken):
    # For grade 1, keep it at 1 regardless of time
    if grade == 1:
        adjustment = 0
        status = "success"
    # For higher grades, tend to decrease the grade to be more conservative
    elif grade > 1:
        adjustment = -1
        status = "success"
    else:
        adjustment = 0
        status = "success"

    adjusted_grade = grade + adjustment
    adjusted_grade = max(1, adjusted_grade)  # Ensure adjusted_grade is at least 1

    return {
        "input_data": {
            "original_grade": grade,
            "time_taken": time_taken
        },
        "adjusted_grade": adjusted_grade,
        "adjustment": adjustment,
        "status": status
    }
```

## Integration with Frontend

The frontend application calls the prediction API to determine which levels should be accessible:

```dart
Future<Map<String, dynamic>> _getPrediction(int grade, int timeTaken) async {
  // First try the external API
  try {
    final response = await http
        .get(
          Uri.parse(
              'https://yasiruperera.pythonanywhere.com/predict?grade=$grade&time_taken=$timeTaken'),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'original_grade': data['input_data']['original_grade'] ?? grade,
        'adjusted_grade': data['adjusted_grade'] ?? grade,
        'adjustment': data['adjustment'] ?? 0,
        'status': data['status'] ?? 'unknown'
      };
    }
  } catch (externalApiError) {
    // Fall back to local API if external fails
    try {
      final localResponse = await http
          .get(
            Uri.parse(
                '${ENVConfig.serverUrl}/predict?grade=$grade&time_taken=$timeTaken'),
          )
          .timeout(const Duration(seconds: 3));

      if (localResponse.statusCode == 200) {
        final data = jsonDecode(localResponse.body);
        return {
          'original_grade': data['input_data']['original_grade'] ?? grade,
          'adjusted_grade': data['adjusted_grade'] ?? grade,
          'adjustment': data['adjustment'] ?? 0,
          'status': data['status'] ?? 'success'
        };
      }
    } catch (localApiError) {
      // If both APIs fail, return the original grade
      return {
        'original_grade': grade,
        'adjusted_grade': grade,
        'adjustment': 0,
        'status': 'error'
      };
    }
  }
}
```

## Level Locking Mechanism

The prediction result is used to determine which levels are accessible to the user:

```dart
// Get prediction for level adjustment using actual performance data
try {
  // Use the prediction API to determine if the level should be accessible
  final prediction = await _getPrediction(currentDifficulty, lastTimeTaken);
  final adjustedGrade = prediction['adjusted_grade'];

  // Store the adjusted grade in SharedPreferences
  await prefs.setInt('vocabulary_difficulty', adjustedGrade);

  // Update the levelsToShow based on adjusted grade
  if (mounted) {
    setState(() {
      levelsToShow = adjustedGrade;
    });
  }

  // Check if the level should be accessible
  if (levelData['difficulty'] > adjustedGrade) {
    // Show dialog if level is locked
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Locked 🔒'),
        content: Text('You need to complete previous levels first.'),
        // ...
      ),
    );
    return;
  }
}
```

## Performance Metrics

### Model Evaluation

The model is evaluated using the following metrics:

1. **Accuracy**: Percentage of correct predictions
2. **Precision**: Ratio of true positives to all positive predictions
3. **Recall**: Ratio of true positives to all actual positives
4. **F1 Score**: Harmonic mean of precision and recall

### Monitoring and Improvement

The model's performance is monitored through:

1. **User Progression**: Tracking how users move through difficulty levels
2. **Completion Rates**: Measuring successful level completions
3. **Time Analysis**: Analyzing time spent on different difficulty levels

## Future Enhancements

1. **Additional Features**: Incorporate more features such as:
   - Historical performance
   - Error patterns
   - Learning style preferences

2. **Advanced Models**: Explore more sophisticated models:
   - Neural networks for better pattern recognition
   - Reinforcement learning for adaptive difficulty

3. **Personalization**: Develop user-specific models that learn individual learning patterns

4. **Real-time Adaptation**: Adjust difficulty within a level based on ongoing performance
