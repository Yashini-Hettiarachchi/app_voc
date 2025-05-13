# Vocabulary Function Backend

This is the backend service for the NVLD Vocabulary Learning App. It provides APIs for vocabulary difficulty prediction, word recognition, and performance tracking.

## Features

- **Vocabulary Difficulty Prediction**: Predicts appropriate difficulty level based on user performance
- **Word Recognition**: OCR-based handwriting recognition for written answers
- **Performance Tracking**: Stores and analyzes user performance data
- **RESTful API**: Easy integration with the Flutter frontend

## API Endpoints

- `GET /predict?grade={grade}&time_taken={time_taken}`: Predicts appropriate difficulty level
- `POST /predict`: Predicts difficulty level (JSON body)
- `POST /vocabulary-records`: Stores a new vocabulary activity record
- `GET /vocabulary-records`: Retrieves all vocabulary records
- `GET /vocabulary-records/user/{user_id}`: Retrieves records for a specific user
- `POST /api/recognize-word-ocr`: Recognizes handwritten words from uploaded images

## Setup

1. Install dependencies:
```
pip install -r requirements.txt
```

2. Run the server:
```
python main.py
```

The server will start on http://localhost:8000

## Deployment

For production deployment, consider using:
- Docker for containerization
- Gunicorn as a WSGI server
- Nginx as a reverse proxy
- A proper database (MongoDB, PostgreSQL) instead of in-memory storage

## Environment Variables

Create a `.env` file with the following variables:
```
PORT=8000
DATABASE_URL=your_database_connection_string
```
