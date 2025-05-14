from flask import Flask, jsonify, request
from flask_cors import CORS
import os
import random
import json
import uuid
import hashlib
from datetime import datetime

# Initialize Flask app
application = Flask(__name__)
CORS(application)

# In-memory storage
vocabulary_records = []
users = []  # To store user information

# Sample vocabulary data organized by levels
vocabulary_data = {
    "level1": {
        "theme": "Everyday Objects",
        "words": ["apple", "banana", "cat", "dog", "elephant", "fish", "house", "book", "pen", "car"]
    },
    "level2": {
        "theme": "Colors and Shapes",
        "words": ["red", "blue", "green", "yellow", "circle", "square", "triangle", "rectangle", "oval", "star"]
    },
    "level3": {
        "theme": "School Items",
        "words": ["pencil", "notebook", "teacher", "student", "classroom", "desk", "chair", "backpack", "ruler", "eraser"]
    },
    "level4": {
        "theme": "Animals",
        "words": ["lion", "tiger", "bear", "giraffe", "monkey", "zebra", "penguin", "kangaroo", "dolphin", "whale"]
    },
    "level5": {
        "theme": "Food",
        "words": ["pizza", "burger", "pasta", "rice", "bread", "cheese", "milk", "juice", "water", "cookie"]
    }
}

# Mock prediction function (similar to yasiruperera.pythonanywhere.com/predict)
def predict_grade(grade, time_taken):
    # Simple logic to adjust grade based on time taken
    adjustment = 0
    if time_taken < 30:
        adjustment = 1  # If fast, increase difficulty
    elif time_taken > 90:
        adjustment = -1  # If slow, decrease difficulty

    # Ensure adjusted_grade is at least 1
    adjusted_grade = max(1, grade + adjustment)

    return {
        "input_data": {
            "original_grade": grade,
            "time_taken": time_taken
        },
        "adjusted_grade": adjusted_grade,
        "adjustment": adjustment,
        "status": "success"
    }

@application.route('/')
def home():
    return jsonify({
        "message": "Welcome to the NVLD Vocabulary Learning API",
        "endpoints": [
            "/register - Register a new user",
            "/login - User login",
            "/predict - Get difficulty level prediction",
            "/vocabulary-records - Store and retrieve vocabulary records",
            "/vocabulary-levels - Get vocabulary levels and themes",
            "/vocabulary-quiz - Get vocabulary quiz questions"
        ]
    })

# User registration endpoint
@application.route('/register', methods=['POST'])
def register():
    try:
        data = request.get_json()

        # Check if required fields are provided
        if not all(k in data for k in ['username', 'password', 'email']):
            return jsonify({"error": "Missing required fields"}), 400

        # Check if username already exists
        if any(user['username'] == data['username'] for user in users):
            return jsonify({"error": "Username already exists"}), 400

        # Create a new user
        user_id = str(uuid.uuid4())
        hashed_password = hashlib.sha256(data['password'].encode()).hexdigest()

        new_user = {
            'id': user_id,
            'username': data['username'],
            'email': data['email'],
            'password': hashed_password,
            'created_at': datetime.now().isoformat()
        }

        users.append(new_user)

        # Return user info without password
        user_info = {k: v for k, v in new_user.items() if k != 'password'}
        return jsonify({"message": "User registered successfully", "user": user_info})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# User login endpoint
@application.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()

        # Check if required fields are provided
        if not all(k in data for k in ['username', 'password']):
            return jsonify({"error": "Missing username or password"}), 400

        # Hash the provided password
        hashed_password = hashlib.sha256(data['password'].encode()).hexdigest()

        # Find the user
        user = next((user for user in users if user['username'] == data['username']), None)

        if not user or user['password'] != hashed_password:
            return jsonify({"error": "Invalid username or password"}), 401

        # Return user info without password
        user_info = {k: v for k, v in user.items() if k != 'password'}
        return jsonify({"message": "Login successful", "user": user_info})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@application.route('/predict', methods=['GET', 'POST'])
def predict():
    if request.method == 'POST':
        try:
            data = request.get_json()
            grade = data.get('grade', 1)
            time_taken = data.get('time_taken', 60)
        except:
            grade = 1
            time_taken = 60
    else:
        grade = request.args.get('grade', default=1, type=int)
        time_taken = request.args.get('time_taken', default=60, type=int)

    result = predict_grade(grade, time_taken)
    return jsonify(result)

@application.route('/vocabulary-records', methods=['GET', 'POST'])
def handle_records():
    if request.method == 'POST':
        try:
            record = request.get_json()
            record['timestamp'] = record.get('timestamp', str(datetime.now()))
            vocabulary_records.append(record)
            return jsonify({"message": "Record created successfully", "id": len(vocabulary_records) - 1})
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    else:
        return jsonify(vocabulary_records)

@application.route('/vocabulary-records/user/<user_id>', methods=['GET'])
def get_user_records(user_id):
    user_records = [r for r in vocabulary_records if r.get('user_id') == user_id]

    # Calculate statistics for reports
    if user_records:
        scores = [r.get('score', 0) for r in user_records]
        avg_score = sum(scores) / len(scores)
        max_score = max(scores)
        min_score = min(scores)

        # Generate suggestions based on performance
        suggestions = []
        if avg_score < 50:
            suggestions.append("Practice more with level 1 vocabulary")
        elif avg_score < 70:
            suggestions.append("Try to improve speed while maintaining accuracy")
        else:
            suggestions.append("Great job! Try more challenging levels")

        stats = {
            "average_score": avg_score,
            "highest_score": max_score,
            "lowest_score": min_score,
            "total_activities": len(user_records),
            "suggestions": suggestions
        }
    else:
        stats = {
            "message": "No records found for this user"
        }

    return jsonify({"records": user_records, "statistics": stats})

@application.route('/vocabulary-levels', methods=['GET'])
def get_vocabulary_levels():
    levels = {}
    for level, data in vocabulary_data.items():
        levels[level] = {
            "theme": data["theme"],
            "emoji": get_emoji_for_theme(data["theme"]),
            "word_count": len(data["words"])
        }
    return jsonify(levels)

@application.route('/vocabulary-quiz/<level>', methods=['GET'])
def get_vocabulary_quiz(level):
    if level not in vocabulary_data:
        return jsonify({"error": "Level not found"}), 404

    # Get words for the requested level
    words = vocabulary_data[level]["words"]
    theme = vocabulary_data[level]["theme"]

    # Create 10 quiz questions
    questions = []
    for i in range(10):
        word = random.choice(words)
        # Create a question with the word
        question = {
            "id": i + 1,
            "word": word,
            "emoji": get_emoji_for_word(word),
            "options": generate_options(word, words)
        }
        questions.append(question)

    return jsonify({
        "level": level,
        "theme": theme,
        "emoji": get_emoji_for_theme(theme),
        "questions": questions
    })

# Helper functions
def get_emoji_for_theme(theme):
    emoji_map = {
        "Everyday Objects": "🏠",
        "Colors and Shapes": "🎨",
        "School Items": "🏫",
        "Animals": "🦁",
        "Food": "🍕"
    }
    return emoji_map.get(theme, "📚")

def get_emoji_for_word(word):
    # Simple emoji mapping for common words
    emoji_map = {
        "apple": "🍎", "banana": "🍌", "cat": "🐱", "dog": "🐶",
        "elephant": "🐘", "fish": "🐟", "house": "🏠", "book": "📚",
        "pen": "🖊️", "car": "🚗", "red": "🔴", "blue": "🔵",
        "green": "🟢", "yellow": "🟡", "circle": "⭕", "square": "🟥",
        "triangle": "🔺", "rectangle": "🟩", "star": "⭐", "pencil": "✏️",
        "teacher": "👩‍🏫", "student": "👨‍🎓", "classroom": "🏫", "desk": "🪑",
        "chair": "💺", "backpack": "🎒", "lion": "🦁", "tiger": "🐯",
        "bear": "🐻", "giraffe": "🦒", "monkey": "🐵", "zebra": "🦓",
        "penguin": "🐧", "dolphin": "🐬", "whale": "🐋", "pizza": "🍕",
        "burger": "🍔", "pasta": "🍝", "bread": "🍞", "cheese": "🧀",
        "milk": "🥛", "juice": "🧃", "water": "💧", "cookie": "🍪"
    }
    return emoji_map.get(word, "❓")

def generate_options(correct_word, word_list):
    # Create a list of 4 options including the correct word
    options = [correct_word]
    while len(options) < 4:
        word = random.choice(word_list)
        if word not in options:
            options.append(word)

    # Shuffle the options
    random.shuffle(options)
    return options

# Add datetime import for timestamp
from datetime import datetime

# Run the application
if __name__ == '__main__':
    # Use PORT environment variable if available, otherwise default to 5000
    port = int(os.environ.get('PORT', 5000))
    application.run(host='0.0.0.0', port=port)
