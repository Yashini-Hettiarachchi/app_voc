from flask import Flask, jsonify, request

# Initialize Flask app
application = Flask(__name__)

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
    }
}

# In-memory storage
users = []
vocabulary_records = []

@application.route('/')
def home():
    return jsonify({
        "message": "Welcome to the NVLD Vocabulary Learning API",
        "status": "success"
    })

@application.route('/predict', methods=['GET'])
def predict():
    grade = request.args.get('grade', default=1, type=int)
    time_taken = request.args.get('time_taken', default=60, type=int)
    
    # Simple logic to adjust grade based on time taken
    adjustment = 0
    if time_taken < 30:
        adjustment = 1  # If fast, increase difficulty
    elif time_taken > 90:
        adjustment = -1  # If slow, decrease difficulty
    
    adjusted_grade = max(1, grade + adjustment)
    
    return jsonify({
        "input_data": {
            "original_grade": grade,
            "time_taken": time_taken
        },
        "adjusted_grade": adjusted_grade,
        "adjustment": adjustment,
        "status": "success"
    })

@application.route('/vocabulary-levels', methods=['GET'])
def get_vocabulary_levels():
    levels = {}
    for level, data in vocabulary_data.items():
        levels[level] = {
            "theme": data["theme"],
            "word_count": len(data["words"])
        }
    return jsonify(levels)

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
        new_user = {
            'id': len(users) + 1,
            'username': data['username'],
            'email': data['email'],
            'password': data['password']  # In a real app, hash this password
        }
        
        users.append(new_user)
        
        # Return user info without password
        user_info = {k: v for k, v in new_user.items() if k != 'password'}
        return jsonify({"message": "User registered successfully", "user": user_info})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@application.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # Check if required fields are provided
        if not all(k in data for k in ['username', 'password']):
            return jsonify({"error": "Missing username or password"}), 400
        
        # Find the user
        user = next((user for user in users if user['username'] == data['username']), None)
        
        if not user or user['password'] != data['password']:
            return jsonify({"error": "Invalid username or password"}), 401
        
        # Return user info without password
        user_info = {k: v for k, v in user.items() if k != 'password'}
        return jsonify({"message": "Login successful", "user": user_info})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Run the application
if __name__ == '__main__':
    application.run(host='0.0.0.0', port=5000)
