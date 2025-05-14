from flask import Flask, jsonify, request
from flask_cors import CORS
import os

# Initialize Flask app
application = Flask(__name__)
CORS(application)

# Sample vocabulary data
vocabulary_records = []

@application.route('/')
def hello():
    return 'Hello World from Flask!'

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
        "status": "success",
        "message": "This is a simple prediction endpoint"
    })

@application.route('/vocabulary-records', methods=['GET', 'POST'])
def handle_records():
    if request.method == 'POST':
        try:
            record = request.get_json()
            vocabulary_records.append(record)
            return jsonify({"message": "Record created successfully", "id": len(vocabulary_records) - 1})
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    else:
        return jsonify(vocabulary_records)

@application.route('/vocabulary-records/user/<user_id>', methods=['GET'])
def get_user_records(user_id):
    user_records = [record for record in vocabulary_records if record.get('user_id') == user_id]
    return jsonify(user_records)

# Run the application
if __name__ == '__main__':
    # Use PORT environment variable if available, otherwise default to 8000
    port = int(os.environ.get('PORT', 8000))
    application.run(host='0.0.0.0', port=port)
