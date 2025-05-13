# Environment Configuration Guide for Hostinger Deployment

This guide explains how to configure your application's environment settings for deployment on Hostinger.

## Understanding the Environment Configuration

Your application uses the `lib/constants/env.dart` file to store configuration settings, including:

1. **Server URL**: The base URL for your backend API
2. **API Routes**: Specific endpoints for different functionalities
3. **Vocabulary Levels**: The structure and content of vocabulary levels

## Current Configuration

Currently, your `env.dart` file has the following server configuration:

```dart
// Server Details
static const String serverUrl = 'http://localhost:8000';
```

This points to a local development server, which won't be accessible when your application is deployed on Hostinger.

## Required Changes for Hostinger Deployment

### 1. Update the Server URL

You need to modify the `serverUrl` to point to your backend API on Hostinger:

```dart
// Server Details
static const String serverUrl = 'https://yourdomain.com/api';
```

Replace `yourdomain.com` with your actual domain name on Hostinger.

### 2. Create a Production-Ready Configuration

For better maintainability, consider creating a configuration that can switch between development and production environments:

```dart
// Server Details
static const bool isProduction = true; // Set to true for production deployment

// Choose the appropriate server URL based on environment
static const String serverUrl = isProduction 
    ? 'https://yourdomain.com/api'  // Production server
    : 'http://localhost:8000';      // Development server
```

This approach allows you to easily switch between environments by changing a single boolean value.

## External API Configuration

Your application also uses an external API at `yasiruperera.pythonanywhere.com/predict`. This API call is hardcoded in your vocabulary screen:

```dart
final response = await http.get(
  Uri.parse('https://yasiruperera.pythonanywhere.com/predict?grade=$grade&time_taken=$timeTaken'),
);
```

### Considerations for the External API

1. **Keep the Direct Reference**: Since this is an external service, you should keep the direct URL reference in your code.

2. **Fallback Mechanism**: Your code already implements a fallback to your local API if the external API fails. This is good practice and should be maintained:

```dart
// Fall back to local API if external fails
try {
  final localResponse = await http.get(
    Uri.parse('${ENVConfig.serverUrl}/predict?grade=$grade&time_taken=$timeTaken'),
  );
  // Process response...
} catch (localApiError) {
  // Handle error...
}
```

When deployed on Hostinger, this fallback will use your hosted backend API instead of the local one.

## MongoDB Connection String

In your backend code (`main.py`), you have a MongoDB connection string:

```python
MONGODB_CONNECTION_URL = "mongodb+srv://dbuser:111222333@cluster0.3ktcg.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
```

### Securing the MongoDB Connection

For production deployment, it's recommended to:

1. **Use Environment Variables**: Move sensitive information like database credentials to environment variables
2. **Update Password**: Consider changing the database password before deployment
3. **Restrict Access**: Configure MongoDB Atlas to only accept connections from your Hostinger server's IP address

Example of using environment variables in Python:

```python
import os
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env file

MONGODB_CONNECTION_URL = os.getenv("MONGODB_CONNECTION_URL")
```

Then create a `.env` file on your Hostinger server with:

```
MONGODB_CONNECTION_URL=mongodb+srv://dbuser:new_secure_password@cluster0.3ktcg.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
```

## CORS Configuration

Your backend needs to allow cross-origin requests from your frontend domain. Update the CORS middleware in your FastAPI application:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Replace with your actual domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Steps to Update Configuration

1. **Update Frontend Configuration**:
   - Modify `lib/constants/env.dart` with the new server URL
   - Rebuild the Flutter web application: `flutter build web --release`

2. **Update Backend Configuration**:
   - Create a `.env` file for sensitive information
   - Update the CORS settings in `main.py`
   - Deploy the updated backend to Hostinger

3. **Test the Configuration**:
   - Verify that the frontend can connect to the backend
   - Test the external API integration
   - Ensure the fallback mechanism works correctly

## Conclusion

By properly configuring your environment settings, your application will be able to communicate with both your backend API on Hostinger and the external vocabulary prediction API. This ensures that all functionality works correctly in the production environment.
