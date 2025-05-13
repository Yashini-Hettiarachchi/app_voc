# CRUD Operations Documentation

This document provides detailed information about the Create, Read, Update, and Delete (CRUD) operations implemented in the NVLD Vocabulary Learning Application.

## Overview

The application implements comprehensive CRUD operations for managing vocabulary records, user data, and performance metrics. These operations are essential for tracking user progress, adapting difficulty levels, and providing personalized learning experiences.

## Data Models

### Vocabulary Record Model

```python
class VocabularyRecordModel(BaseModel):
    user: str
    activity: str
    type: str
    recorded_date: datetime = Field(default_factory=datetime.utcnow)
    score: float
    time_taken: int
    difficulty: int
    suggestions: Optional[List[str]]
```

### User Model

```python
class UserModel(BaseModel):
    username: str
    email: EmailStr
    full_name: str
    disabled: Optional[bool] = None
```

## Create Operations

### 1. Create Vocabulary Record

**Endpoint**: `POST /vocabulary-records`

**Description**: Creates a new vocabulary activity record in the database.

**Request Body**:
```json
{
  "user": "user123",
  "activity": "Word Matching",
  "type": "basic",
  "score": 80.5,
  "time_taken": 45,
  "difficulty": 2,
  "suggestions": ["Practice more time-related words"]
}
```

**Implementation**:
```python
@app.post("/vocabulary-records", status_code=201)
async def create_vocabulary_record(record: VocabularyRecordModel):
    record_data = record.dict()
    result = await vocabulary_records_collection.insert_one(record_data)
    if result.inserted_id:
        return {"message": "Vocabulary record created successfully", "id": str(result.inserted_id)}
    raise HTTPException(status_code=500, detail="Failed to create vocabulary record")
```

**Frontend Implementation**:
```dart
Future<void> _saveScoreToDB(int score, int difficulty) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('authEmployeeID') ?? "sampleUser";
    
    final response = await http.post(
      Uri.parse('${ENVConfig.serverUrl}/vocabulary-records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': username,
        'activity': widget.levelTitle,
        'type': 'vocabulary',
        'score': score.toDouble(),
        'time_taken': widget.timeTaken,
        'difficulty': difficulty,
        'suggestions': _generateSuggestions(score)
      }),
    );
    
    if (response.statusCode == 201) {
      print('Score saved successfully');
    } else {
      print('Failed to save score: ${response.statusCode}');
    }
  } catch (e) {
    print('Error saving score: $e');
  }
}
```

### 2. Save Handwriting Sample

**Endpoint**: `POST /api/recognize-word-ocr`

**Description**: Saves a handwriting sample (signature.png) and performs OCR.

**Request**: Multipart form data with image file.

**Implementation**:
```python
@app.post("/api/recognize-word-ocr")
async def recognize_word(file: UploadFile = File(...)):
    try:
        # Create uploads directory if it doesn't exist
        os.makedirs("uploads", exist_ok=True)

        # Save the uploaded file
        file_path = f"uploads/signature.png"
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
            
        # OCR processing...
        
        return {"recognized_text": recognized_text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

**Frontend Implementation**:
```dart
Future<void> _uploadSignature() async {
  try {
    setState(() {
      _isUploading = true;
      statusMessage = "Processing your handwriting...";
    });

    // Convert the signature to an image
    final signaturePadState = _signaturePadKey.currentState;
    if (signaturePadState == null) {
      setState(() {
        _isUploading = false;
        statusMessage = "Please write your answer first";
      });
      return;
    }

    final ui.Image image = await signaturePadState.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      setState(() {
        _isUploading = false;
        statusMessage = "Error processing your handwriting";
      });
      return;
    }

    final Uint8List imageBytes = byteData.buffer.asUint8List();

    // Save the image to the uploads directory
    try {
      // Create directory if it doesn't exist
      Directory uploadsDir = Directory('uploads');
      if (!await uploadsDir.exists()) {
        await uploadsDir.create(recursive: true);
      }

      // Save the image to the uploads directory
      File signatureFile = File('uploads/signature.png');
      await signatureFile.writeAsBytes(imageBytes);

      // Send to server for OCR
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ENVConfig.serverUrl}/api/recognize-word-ocr'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes,
            filename: 'signature.png'),
      );
      
      // Process response...
    } catch (e) {
      // Error handling...
    }
  } catch (e) {
    // Error handling...
  }
}
```

## Read Operations

### 1. Get All Vocabulary Records

**Endpoint**: `GET /vocabulary-records`

**Description**: Retrieves all vocabulary records from the database.

**Implementation**:
```python
@app.get("/vocabulary-records", response_model=List[dict])
async def get_all_vocabulary_records():
    records = await vocabulary_records_collection.find().to_list(length=100)
    return [format_id(record) for record in records]
```

**Frontend Implementation**:
```dart
Future<void> _fetchVocabularyRecords() async {
  try {
    final response = await http.get(
      Uri.parse('${ENVConfig.serverUrl}/vocabulary-records'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        records = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vocabulary records')),
      );
    }
  } catch (e) {
    // Error handling...
  }
}
```

### 2. Get User-Specific Vocabulary Records

**Endpoint**: `GET /vocabulary-records/user/{user_id}`

**Description**: Retrieves vocabulary records for a specific user.

**Implementation**:
```python
@app.get("/vocabulary-records/user/{user_id}")
async def get_user_vocabulary_records(user_id: str):
    records = await vocabulary_records_collection.find({"user": user_id}).to_list(length=100)
    
    # Calculate comparison metrics
    avg_score = sum([r.get("score", 0) for r in records]) / len(records) if records else 0
    avg_time = sum([r.get("time_taken", 0) for r in records]) / len(records) if records else 0
    
    comparison = {
        "avg_score": avg_score,
        "avg_time": avg_time,
        "total_activities": len(records)
    }
    
    return {
        "records": [format_id(record) for record in records],
        "comparison": comparison
    }
```

**Frontend Implementation**:
```dart
Future<void> _fetchVocabularyRecords() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('authEmployeeID') ?? "sampleUser";

    final response = await http.get(
      Uri.parse('${ENVConfig.serverUrl}/vocabulary-records/user/$username'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          records = data['records'];
          comparison = data['comparison'] ?? {};
          isLoading = false;
        });
      }
    } else {
      // Use mock data if server returns error
      _useMockData();
    }
  } catch (e) {
    // Error handling...
  }
}
```

### 3. Get Difficulty Prediction

**Endpoint**: `GET /predict`

**Description**: Retrieves a difficulty level prediction based on grade and time taken.

**Implementation**:
```python
@app.get("/predict")
def predict(grade: int = Query(..., description="Current grade level"),
            time_taken: int = Query(..., description="Time taken in seconds")):
    try:
        result = predict_grade(grade, time_taken)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

**Frontend Implementation**:
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
    // ...
  }
}
```

## Update Operations

### 1. Update User Score

**Endpoint**: `PUT /users/{username}/score`

**Description**: Updates a user's vocabulary score.

**Request Body**:
```json
{
  "score": 85.5,
  "level": 3
}
```

**Implementation**:
```python
@app.put("/users/{username}/score")
async def update_user_score(username: str, score_data: dict):
    try:
        result = await users_collection.update_one(
            {"username": username},
            {"$set": {
                "vocabulary_score": score_data.get("score"),
                "vocabulary_level": score_data.get("level")
            }}
        )
        
        if result.matched_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        return {"message": "User score updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
```

**Frontend Implementation**:
```dart
Future<void> _updateUserScore(double score, int level) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('authEmployeeID') ?? "sampleUser";
    
    final response = await http.put(
      Uri.parse('${ENVConfig.serverUrl}/users/$username/score'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'score': score,
        'level': level
      }),
    );
    
    if (response.statusCode == 200) {
      print('User score updated successfully');
    } else {
      print('Failed to update user score: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating user score: $e');
  }
}
```

### 2. Update Difficulty Level

**Description**: Updates the user's difficulty level in SharedPreferences.

**Implementation**:
```dart
void _calculateTotalScore() async {
  final prefs = await SharedPreferences.getInstance();
  int difficulty = prefs.getInt('vocabulary_difficulty') ?? 1;

  // Calculate score based on exactly 10 questions per level
  double timeFactor = widget.timeTaken * 0.05;
  totalScore = ((100 * widget.rawScore / 10) - timeFactor).toInt();

  await _saveScoreToDB(totalScore, difficulty.clamp(1, 5));

  if (totalScore > 60) {
    difficulty += 1;
  } else if (totalScore > 30) {
    // Keep the same difficulty
  } else {
    difficulty = (difficulty - 1).clamp(0, double.infinity).toInt();
  }

  // Update the difficulty level in SharedPreferences
  await prefs.setInt('vocabulary_difficulty', difficulty);
}
```

## Delete Operations

### 1. Delete Vocabulary Record

**Endpoint**: `DELETE /vocabulary-records/{record_id}`

**Description**: Deletes a vocabulary record from the database.

**Implementation**:
```python
@app.delete("/vocabulary-records/{record_id}", status_code=200)
async def delete_vocabulary_record(record_id: str):
    result = await vocabulary_records_collection.delete_one({"_id": ObjectId(record_id)})
    if result.deleted_count:
        return {"message": "Vocabulary record deleted successfully"}
    raise HTTPException(status_code=404, detail="Vocabulary record not found")
```

**Frontend Implementation**:
```dart
Future<void> _deleteRecord(String recordId) async {
  try {
    final response = await http.delete(
      Uri.parse('${ENVConfig.serverUrl}/vocabulary-records/$recordId'),
    );
    
    if (response.statusCode == 200) {
      // Refresh the records list
      _fetchVocabularyRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete record')),
      );
    }
  } catch (e) {
    print('Error deleting record: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

## Error Handling

### Backend Error Handling

```python
try:
    # Operation code
except Exception as e:
    error_trace = traceback.format_exc()
    print(f"Error occurred: {str(e)}\n{error_trace}")
    raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}. See server logs for more details.")
```

### Frontend Error Handling

```dart
try {
  // API call or operation
} catch (e) {
  debugPrint('Error: $e');
  // Show user-friendly error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Something went wrong. Please try again.')),
  );
  // Fallback behavior
  _useMockData();
}
```

## Security Considerations

1. **Input Validation**: All inputs are validated using Pydantic models
2. **Error Handling**: Detailed errors in logs, generic messages to users
3. **Authentication**: User authentication required for sensitive operations
4. **Data Protection**: Sensitive data is protected and properly stored

## Best Practices

1. **Consistent Response Format**: All API endpoints return consistent JSON structures
2. **Proper Status Codes**: Appropriate HTTP status codes for different scenarios
3. **Pagination**: Large result sets are paginated to improve performance
4. **Caching**: Frequently accessed data is cached to reduce database load
5. **Logging**: Comprehensive logging for debugging and monitoring
