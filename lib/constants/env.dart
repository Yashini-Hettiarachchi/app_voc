import 'dart:ui';
import 'package:flutter/material.dart';

class ENVConfig {
  // Server Details
  // For local development use: 'http://localhost:8000'
  // For production use your AWS Elastic Beanstalk URL: 'https://your-eb-environment.elasticbeanstalk.com'
  // For Hostinger deployment: 'https://yourdomain.com/api'

  // IMPORTANT: Update this URL with your actual AWS Elastic Beanstalk URL before deployment
  static const String serverUrl = 'http://localhost:8000'; // Development
  // static const String serverUrl = 'https://your-eb-environment.elasticbeanstalk.com';  // Production

  // API Route
  static const String loginRoute = '/api/login';

  static final List<Map<String, dynamic>> levels = [
    {
      "title": "Level 1: Word Matching 🔤",
      "description": "Match words with their meanings",
      "difficulty": 0,
      "type": "basic",
      "color": Colors.blue,
      "background": "assets/backgrounds/level1.jpg",
      "questions": [
        {
          "question": "Which word means 'a part of the body'?",
          "options": ["Hand", "Book", "Tree", "Car"],
          "answer": "Hand"
        },
        {
          "question": "Which word means 'the color of the sky'?",
          "options": ["Blue", "Red", "Green", "Yellow"],
          "answer": "Blue"
        },
        {
          "question": "Which word means 'a sweet fruit'?",
          "options": ["Apple", "Car", "House", "Dog"],
          "answer": "Apple"
        },
        {
          "question": "Which word means 'something you sit on'?",
          "options": ["Chair", "Table", "Bed", "Desk"],
          "answer": "Chair"
        },
        {
          "question": "Which word means 'a tool for writing'?",
          "options": ["Pencil", "Eraser", "Ruler", "Scissors"],
          "answer": "Pencil"
        },
        {
          "question": "Which word means 'an animal that barks'?",
          "options": ["Dog", "Cat", "Bird", "Fish"],
          "answer": "Dog"
        },
        {
          "question": "Which word means 'a place where you live'?",
          "options": ["House", "School", "Park", "Store"],
          "answer": "House"
        },
        {
          "question": "Which word means 'a vehicle with four wheels'?",
          "options": ["Car", "Bike", "Boat", "Plane"],
          "answer": "Car"
        },
        {
          "question": "Which word means 'a place where you learn'?",
          "options": ["School", "Hospital", "Park", "Beach"],
          "answer": "School"
        },
        {
          "question": "Which word means 'a person who teaches'?",
          "options": ["Teacher", "Doctor", "Farmer", "Driver"],
          "answer": "Teacher"
        }
      ]
    },
    {
      "title": "Level 1: Filling Blanks ✏️",
      "description": "Complete the sentences with correct words",
      "difficulty": 0,
      "type": "basic",
      "color": Colors.green,
      "background": "assets/backgrounds/level2.jpg",
      "questions": [
        {
          "question": "I have two ___ on my face.",
          "options": ["eyes", "ears", "noses", "mouths"],
          "answer": "eyes"
        },
        {
          "question": "The sky is ___ in color.",
          "options": ["blue", "red", "green", "yellow"],
          "answer": "blue"
        },
        {
          "question": "I eat an ___ every day.",
          "options": ["apple", "orange", "banana", "grape"],
          "answer": "apple"
        },
        {
          "question": "I sit on a ___ in the classroom.",
          "options": ["chair", "table", "bed", "desk"],
          "answer": "chair"
        },
        {
          "question": "I write with a ___.",
          "options": ["pencil", "eraser", "ruler", "scissors"],
          "answer": "pencil"
        },
        {
          "question": "My pet ___ barks at strangers.",
          "options": ["dog", "cat", "bird", "fish"],
          "answer": "dog"
        },
        {
          "question": "I live in a ___ with my family.",
          "options": ["house", "school", "park", "store"],
          "answer": "house"
        },
        {
          "question": "My father drives a ___ to work.",
          "options": ["car", "bike", "boat", "plane"],
          "answer": "car"
        },
        {
          "question": "I learn new things at ___.",
          "options": ["school", "hospital", "park", "beach"],
          "answer": "school"
        },
        {
          "question": "The ___ teaches us math and science.",
          "options": ["teacher", "doctor", "farmer", "driver"],
          "answer": "teacher"
        }
      ]
    },
    {
      "title": "Level 1: Visual Identification 👁️",
      "description": "Identify objects from pictures 🖼️",
      "difficulty": 0,
      "type": "basic",
      "color": Colors.orange,
      "background": "assets/backgrounds/level3.jpg",
      "questions": [
        {
          "question": "👋 What body part is this?",
          "imagePath": "assets/images/body_parts/hand.png",
          "options": ["Hand", "Foot", "Ear", "Nose"],
          "answer": "Hand"
        },
        {
          "question": "🎨 What color is this?",
          "imagePath": "assets/images/colors/blue.png",
          "options": ["Blue", "Red", "Green", "Yellow"],
          "answer": "Blue"
        },
        {
          "question": "🍎 What fruit is this?",
          "imagePath": "assets/images/fruits/apple.png",
          "options": ["Apple", "Orange", "Banana", "Grape"],
          "answer": "Apple"
        },
        {
          "question": "🪑 What is this object?",
          "imagePath": "assets/images/objects/chair.png",
          "options": ["Chair", "Table", "Bed", "Desk"],
          "answer": "Chair"
        },
        {
          "question": "✏️ What is this object?",
          "imagePath": "assets/images/objects/pencil.png",
          "options": ["Pencil", "Eraser", "Ruler", "Scissors"],
          "answer": "Pencil"
        },
        {
          "question": "🐕 What animal is this?",
          "imagePath": "assets/images/animals/dog.png",
          "options": ["Dog", "Cat", "Bird", "Fish"],
          "answer": "Dog"
        },
        {
          "question": "🏠 What is this building?",
          "imagePath": "assets/images/buildings/house.png",
          "options": ["House", "School", "Hospital", "Store"],
          "answer": "House"
        },
        {
          "question": "🚗 What vehicle is this?",
          "imagePath": "assets/images/vehicles/car.png",
          "options": ["Car", "Bike", "Bus", "Train"],
          "answer": "Car"
        },
        {
          "question": "🏫 What place is this?",
          "imagePath": "assets/images/places/school.png",
          "options": ["School", "Hospital", "Park", "Beach"],
          "answer": "School"
        },
        {
          "question": "👩‍🏫 What profession is this?",
          "imagePath": "assets/images/professions/teacher.png",
          "options": ["Teacher", "Doctor", "Farmer", "Driver"],
          "answer": "Teacher"
        }
      ]
    },
    {
      "title": "Level 3: Transportation 🚗",
      "cardPack": "Themes: Vehicles & Travel",
      "description": "Learn about different modes of transportation",
      "difficulty": 1,
      "type": "normal",
      "color": const Color(0xFF2196F3),
      "questions": [
        {
          "question": "🚗 I drive a ______ to work.",
          "options": ["Car", "Bicycle", "Bus", "Train"],
          "answer": "Car"
        },
        {
          "question": "✈️ I fly in an ______ to travel far.",
          "options": ["Airplane", "Helicopter", "Rocket", "Balloon"],
          "answer": "Airplane"
        },
        {
          "question": "🚲 I ride a ______ to school.",
          "options": ["Bicycle", "Car", "Bus", "Train"],
          "answer": "Bicycle"
        },
        {
          "question": "🚂 A ______ runs on tracks.",
          "options": ["Train", "Bus", "Car", "Bicycle"],
          "answer": "Train"
        },
        {
          "question": "🚌 I take the ______ to the city.",
          "options": ["Bus", "Car", "Train", "Bicycle"],
          "answer": "Bus"
        },
        {
          "question": "🚢 A ______ floats on water.",
          "options": ["Ship", "Airplane", "Car", "Train"],
          "answer": "Ship"
        },
        {
          "question": "🚁 A ______ can hover in the air.",
          "options": ["Helicopter", "Airplane", "Rocket", "Balloon"],
          "answer": "Helicopter"
        },
        {
          "question": "🚤 A small ______ moves fast on water.",
          "options": ["Boat", "Ship", "Submarine", "Raft"],
          "answer": "Boat"
        },
        {
          "question": "🚀 A ______ goes to space.",
          "options": ["Rocket", "Airplane", "Helicopter", "Balloon"],
          "answer": "Rocket"
        },
        {
          "question": "🚲 I pedal a ______ to move.",
          "options": ["Bicycle", "Car", "Bus", "Train"],
          "answer": "Bicycle"
        }
      ]
    },
    {
      "title": "Level 4: Nature & Environment 🌿",
      "cardPack": "Themes: Weather & Seasons",
      "description": "Learn about natural phenomena and seasons",
      "difficulty": 1,
      "type": "normal",
      "color": const Color(0xFFFF5722),
      "questions": [
        {
          "question": "☀️ The ______ shines during the day.",
          "options": ["Sun", "Moon", "Star", "Cloud"],
          "answer": "Sun"
        },
        {
          "question": "🌧️ Water falls from the sky as ______.",
          "options": ["Rain", "Snow", "Hail", "Fog"],
          "answer": "Rain"
        },
        {
          "question": "❄️ White flakes fall as ______ in winter.",
          "options": ["Snow", "Rain", "Hail", "Fog"],
          "answer": "Snow"
        },
        {
          "question": "🌪️ A strong spinning wind is a ______.",
          "options": ["Tornado", "Hurricane", "Storm", "Rain"],
          "answer": "Tornado"
        },
        {
          "question": "🌊 A large wave in the ocean is a ______.",
          "options": ["Tsunami", "Tide", "Wave", "Current"],
          "answer": "Tsunami"
        },
        {
          "question": "🌋 A mountain that erupts is a ______.",
          "options": ["Volcano", "Hill", "Mountain", "Valley"],
          "answer": "Volcano"
        },
        {
          "question": "🌪️ A violent storm with wind is a ______.",
          "options": ["Hurricane", "Tornado", "Storm", "Rain"],
          "answer": "Hurricane"
        },
        {
          "question": "🌫️ Thick mist in the air is called ______.",
          "options": ["Fog", "Cloud", "Rain", "Snow"],
          "answer": "Fog"
        },
        {
          "question": "🌩️ Bright light in the sky during a storm is ______.",
          "options": ["Lightning", "Thunder", "Rain", "Wind"],
          "answer": "Lightning"
        },
        {
          "question": "🌬️ Moving air is called ______.",
          "options": ["Wind", "Rain", "Snow", "Hail"],
          "answer": "Wind"
        }
      ]
    },
    {
      "title": "Level 5: Calculation Improvement 🧮",
      "cardPack": "Themes: Numbers & Math",
      "description": "Combine word recognition with basic arithmetic",
      "difficulty": 2,
      "type": "basic",
      "color": const Color(0xFF673AB7),
      "questions": [
        {
          "question": "🔢 What is 2 + 2?",
          "options": ["4", "5", "3", "6"],
          "answer": "4"
        },
        {
          "question": "🖐️ How many fingers are on one hand?",
          "options": ["Five", "Four", "Six", "Three"],
          "answer": "Five"
        },
        {
          "question": "🎲 What number comes after 9?",
          "options": ["10", "8", "11", "7"],
          "answer": "10"
        },
        {
          "question": "🔢 What is 5 - 3?",
          "options": ["2", "3", "1", "4"],
          "answer": "2"
        },
        {
          "question": "🧮 What is 3 x 3?",
          "options": ["9", "6", "12", "15"],
          "answer": "9"
        },
        {
          "question": "📏 How many sides does a triangle have?",
          "options": ["3", "4", "5", "6"],
          "answer": "3"
        },
        {
          "question": "🔢 What is 10 divided by 2?",
          "options": ["5", "4", "6", "3"],
          "answer": "5"
        },
        {
          "question": "🎲 What number comes before 1?",
          "options": ["0", "2", "3", "4"],
          "answer": "0"
        },
        {
          "question": "🔢 What is 7 + 5?",
          "options": ["12", "10", "11", "13"],
          "answer": "12"
        },
        {
          "question": "📐 How many sides does a square have?",
          "options": ["4", "3", "5", "6"],
          "answer": "4"
        }
      ]
    },
    {
      "title": "Level 6: Time Identification ⏰",
      "cardPack": "Themes: Time & Clocks",
      "description": "Develop time-reading skills",
      "difficulty": 3,
      "type": "normal",
      "color": const Color(0xFF3F51B5),
      "questions": [
        {
          "question": "⏰ What time is it when the clock shows 12:00?",
          "options": ["Noon", "Midnight", "Morning", "Evening"],
          "answer": "Noon"
        },
        {
          "question": "🕒 How many hours are in a day?",
          "options": ["24", "12", "36", "48"],
          "answer": "24"
        },
        {
          "question": "🕑 What time is it when the clock shows 2:00?",
          "options": [
            "Two o'clock",
            "Three o'clock",
            "One o'clock",
            "Four o'clock"
          ],
          "answer": "Two o'clock"
        },
        {
          "question": "🕓 How many minutes are in an hour?",
          "options": ["60", "30", "45", "90"],
          "answer": "60"
        },
        {
          "question": "⏳ How many seconds are in a minute?",
          "options": ["60", "100", "30", "45"],
          "answer": "60"
        },
        {
          "question": "🕕 What time is it when the clock shows 6:00?",
          "options": [
            "Six o'clock",
            "Seven o'clock",
            "Five o'clock",
            "Eight o'clock"
          ],
          "answer": "Six o'clock"
        },
        {
          "question": "🕛 What time is it when the clock shows 12:00 at night?",
          "options": ["Midnight", "Noon", "Morning", "Evening"],
          "answer": "Midnight"
        },
        {
          "question": "🕗 What time is it when the clock shows 8:00?",
          "options": [
            "Eight o'clock",
            "Nine o'clock",
            "Seven o'clock",
            "Ten o'clock"
          ],
          "answer": "Eight o'clock"
        },
        {
          "question": "⏰ How many hours are in half a day?",
          "options": ["12", "6", "24", "18"],
          "answer": "12"
        },
        {
          "question": "🕐 What time is it when the clock shows 1:00?",
          "options": [
            "One o'clock",
            "Two o'clock",
            "Twelve o'clock",
            "Three o'clock"
          ],
          "answer": "One o'clock"
        }
      ]
    },
    {
      "title": "Level 7: Advanced Vocabulary 📚",
      "cardPack": "Themes: Professions & Nature",
      "description": "Learn advanced vocabulary through professions and nature",
      "difficulty": 4,
      "type": "normal",
      "color": const Color(0xFF9C27B0),
      "questions": [
        {
          "question": "👩‍🏫 Who teaches students in a school?",
          "options": ["Teacher", "Doctor", "Nurse", "Chef"],
          "answer": "Teacher"
        },
        {
          "question": "🔧 What do you call a person who fixes cars?",
          "options": ["Mechanic", "Chef", "Teacher", "Doctor"],
          "answer": "Mechanic"
        },
        {
          "question": "🏔️ What is a tall mountain covered with snow called?",
          "options": ["Peak", "Valley", "Hill", "Plain"],
          "answer": "Peak"
        },
        {
          "question": "👨‍🍳 What do you call a person who cooks food?",
          "options": ["Chef", "Mechanic", "Teacher", "Doctor"],
          "answer": "Chef"
        },
        {
          "question": "🌊 What flows in a valley and carries water?",
          "options": ["River", "Mountain", "Hill", "Plain"],
          "answer": "River"
        },
        {
          "question":
              "🌳 What do you call a large plant with a trunk and branches?",
          "options": ["Tree", "Bush", "Flower", "Grass"],
          "answer": "Tree"
        },
        {
          "question": "🦁 What is the king of the jungle?",
          "options": ["Lion", "Tiger", "Bear", "Wolf"],
          "answer": "Lion"
        },
        {
          "question": "🌋 What do you call a mountain that erupts with lava?",
          "options": ["Volcano", "Hill", "Mountain", "Valley"],
          "answer": "Volcano"
        },
        {
          "question": "👨‍🚀 Who travels to space?",
          "options": ["Astronaut", "Pilot", "Driver", "Sailor"],
          "answer": "Astronaut"
        },
        {
          "question": "🌌 What do you call the collection of stars in the sky?",
          "options": ["Galaxy", "Planet", "Star", "Moon"],
          "answer": "Galaxy"
        }
      ]
    }
  ];
}
