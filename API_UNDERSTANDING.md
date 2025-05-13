# Vocabulary Function API Understanding

## API Link
The primary API endpoint for the vocabulary function is:
```
https://yasiruperera.pythonanywhere.com/predict
```

## Location in Code
The API is referenced in multiple files:

1. **Main Implementation**: `lib/navigations/vocabulary_list_screen.dart`
   ```dart
   final response = await http
       .get(
         Uri.parse(
             'https://yasiruperera.pythonanywhere.com/predict?grade=$grade&time_taken=$timeTaken'),
       )
       .timeout(const Duration(seconds: 5));
   ```

2. **Documentation**: `VIVA_GUIDE.md` and `ML_MODEL_DOCUMENTATION.md`
   ```dart
   // Example from VIVA_GUIDE.md
   Future<Map<String, dynamic>> _getPrediction(int grade, int timeTaken) async {
     try {
       // External API call
       final response = await http.get(
         Uri.parse('https://yasiruperera.pythonanywhere.com/predict?grade=$grade&time_taken=$timeTaken'),
       );
       // ...
     }
   }
   ```

3. **Testing Documentation**: `SETUP_AND_TESTING.md`
   ```
   Test external API: `https://yasiruperera.pythonanywhere.com/predict?grade=2&time_taken=45`
   ```

## Purpose of the API

The vocabulary function API serves several critical purposes in your application:

1. **Adaptive Difficulty System**:
   - The API analyzes a child's current grade level and the time they took to complete activities
   - It returns an adjusted grade level that's appropriate for the child's abilities
   - This enables the "lock/unlock" functionality for vocabulary levels

2. **Machine Learning Integration**:
   - The API implements a machine learning model that predicts the appropriate difficulty level
   - It considers both the current grade and time taken to make predictions
   - This is part of your research project's ML model integration

3. **Fallback Mechanism**:
   - Your code implements a fallback to a local API if the external API fails
   - This ensures the application remains functional even if the external service is unavailable
   ```dart
   // Fall back to local API if external fails
   try {
     final localResponse = await http
         .get(
           Uri.parse(
               '${ENVConfig.serverUrl}/predict?grade=$grade&time_taken=$timeTaken'),
         )
         .timeout(const Duration(seconds: 3));
     // ...
   }
   ```

## API Request Format

The API accepts two parameters:
- `grade`: The current grade level of the child (integer)
- `time_taken`: The time taken to complete an activity in seconds (integer)

Example request:
```
GET https://yasiruperera.pythonanywhere.com/predict?grade=2&time_taken=45
```

## API Response Format

The API returns a JSON response with the following structure:
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

Where:
- `input_data`: Contains the original parameters sent to the API
- `adjusted_grade`: The recommended difficulty level based on the ML model
- `adjustment`: The difference between original and adjusted grade
- `status`: Indicates if the prediction was successful

## Integration with Your Application

Your application uses this API to:
1. Determine which vocabulary levels should be accessible to the child
2. Adapt the difficulty based on the child's performance
3. Store performance records for generating reports
4. Provide appropriate feedback and suggestions

## Hosting Considerations for Hostinger

When hosting your application on Hostinger, you'll need to:

1. **Keep the External API Reference**:
   - The external API at yasiruperera.pythonanywhere.com should continue to be used
   - It contains the trained ML model for predictions

2. **Deploy Your Local Backend**:
   - Your local backend (FastAPI) should be deployed to Hostinger
   - This serves as a fallback and handles other functionality like storing records

3. **Update Environment Configuration**:
   - In `lib/constants/env.dart`, update the `serverUrl` to point to your Hostinger backend URL
   - Keep the direct reference to the external API in the vocabulary screen

4. **Configure CORS**:
   - Ensure your backend has proper CORS settings to allow requests from your hosted frontend
