from fastapi import FastAPI, HTTPException, File, UploadFile, Form, Depends, status, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import numpy as np
import pandas as pd
import joblib
import os
import uvicorn
from datetime import datetime
import traceback
import certifi
import json
import random

app = FastAPI(title="Vocabulary Learning API", 
              description="API for vocabulary learning and prediction",
              version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Model for prediction request
class PredictionRequest(BaseModel):
    grade: int = Field(..., description="Current grade level")
    time_taken: int = Field(..., description="Time taken in seconds")

# Model for vocabulary record
class VocabularyRecord(BaseModel):
    user_id: str
    activity: str
    type: str
    score: float
    time_taken: int
    difficulty: int
    suggestions: Optional[List[str]] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)

# In-memory storage for records (replace with database in production)
vocabulary_records = []

# Mock model for prediction (replace with actual model in production)
def predict_grade(grade, time_taken):
    # Simple logic: if time_taken is less than threshold, increase grade
    # otherwise keep same or decrease
    if time_taken < 500:  # Fast completion
        adjustment = min(1, 5 - grade)  # Don't go above grade 5
        status = "increase"
    elif time_taken > 1000:  # Slow completion
        adjustment = max(-1, 1 - grade)  # Don't go below grade 1
        status = "decrease"
    else:  # Average completion
        adjustment = 0
        status = "same"
    
    adjusted_grade = grade + adjustment
    
    return {
        "input_data": {
            "original_grade": grade,
            "time_taken": time_taken
        },
        "adjusted_grade": adjusted_grade,
        "adjustment": adjustment,
        "status": status
    }

@app.get("/")
def read_root():
    return {"message": "Welcome to the Vocabulary Learning API"}

@app.get("/predict")
def predict(grade: int = Query(..., description="Current grade level"), 
            time_taken: int = Query(..., description="Time taken in seconds")):
    try:
        result = predict_grade(grade, time_taken)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/predict")
def predict_post(request: PredictionRequest):
    try:
        result = predict_grade(request.grade, request.time_taken)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/vocabulary-records")
def create_record(record: VocabularyRecord):
    try:
        vocabulary_records.append(record.dict())
        return {"message": "Record created successfully", "id": len(vocabulary_records) - 1}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/vocabulary-records")
def get_records():
    return vocabulary_records

@app.get("/vocabulary-records/user/{user_id}")
def get_user_records(user_id: str):
    user_records = [r for r in vocabulary_records if r["user_id"] == user_id]
    
    # Calculate comparison with other users
    all_scores = [r["score"] for r in vocabulary_records]
    user_scores = [r["score"] for r in user_records]
    
    avg_score = sum(all_scores) / len(all_scores) if all_scores else 0
    user_avg = sum(user_scores) / len(user_scores) if user_scores else 0
    
    comparison = {
        "user_average": user_avg,
        "global_average": avg_score,
        "percentile": 50  # Mock percentile
    }
    
    return {"records": user_records, "comparison": comparison}

@app.post("/api/recognize-word-ocr")
async def recognize_word(file: UploadFile = File(...)):
    try:
        # In a real implementation, this would use OCR to recognize handwriting
        # For now, we'll return a mock response
        
        # Mock list of possible recognized words
        possible_words = ["apple", "banana", "cat", "dog", "elephant", 
                         "fish", "giraffe", "house", "ice", "jacket"]
        
        recognized_text = random.choice(possible_words)
        
        return {"recognized_text": recognized_text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
