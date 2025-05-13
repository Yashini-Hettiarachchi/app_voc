# Hosting Your NVLD Vocabulary Application on Hostinger

This guide provides step-by-step instructions for hosting your Flutter web application and Python backend on Hostinger.

## Overview

Your application consists of two main components:
1. **Flutter Web Frontend**: The user interface built with Flutter
2. **Python FastAPI Backend**: The server-side API that handles data storage and processing

## Prerequisites

- A Hostinger account with a hosting plan that supports Python
- Domain name (can be purchased through Hostinger)
- FTP client (like FileZilla) or Git for uploading files
- Flutter SDK installed on your development machine
- Python 3.8+ installed on your development machine

## Step 1: Prepare Your Flutter Web Application

1. **Build the Flutter web application**:
   ```bash
   cd /path/to/your/app
   flutter build web --release
   ```
   This will create optimized web files in the `build/web` directory.

2. **Update the server URL in your environment configuration**:
   - Open `lib/constants/env.dart`
   - Update the `serverUrl` to point to your future Hostinger domain:
   ```dart
   // Server Details
   static const String serverUrl = 'https://yourdomain.com/api';
   ```
   - Rebuild the web application after making this change

## Step 2: Set Up Hostinger Account and Hosting Plan

1. **Sign up for Hostinger** at [hostinger.com](https://www.hostinger.com/)
2. **Choose a hosting plan** that supports Python applications
   - Premium or Business plans are recommended for running Python applications
3. **Set up your domain name**
   - You can either purchase a new domain through Hostinger or
   - Use an existing domain and update DNS settings

## Step 3: Deploy the Backend API

1. **Prepare your backend code**:
   - Make sure your `requirements.txt` file is up to date:
   ```
   fastapi==0.95.0
   uvicorn==0.21.1
   gunicorn==20.1.0
   python-multipart==0.0.6
   pydantic==1.10.7
   pymongo==4.3.3
   motor==3.1.2
   certifi==2022.12.7
   ```

2. **Access your Hostinger control panel**:
   - Log in to your Hostinger account
   - Navigate to the hosting section

3. **Set up Python environment**:
   - In the Hostinger control panel, find the "Python" or "Advanced" section
   - Create a new Python application
   - Select Python 3.8 or higher
   - Set the application path to `/api` or your preferred path
   - Set the WSGI application path to `main:app`

4. **Upload your backend files**:
   - Use FTP or the File Manager in Hostinger to upload your backend files
   - Upload to the directory specified in your Python application setup
   - Make sure to include all necessary files (main.py, requirements.txt, etc.)

5. **Install dependencies**:
   - Connect to your hosting via SSH (if available in your plan)
   - Navigate to your backend directory
   - Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Linux/Mac
   ```
   - Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

6. **Configure the application**:
   - Create a `.env` file in your backend directory with necessary configuration:
   ```
   DATABASE_URL=your_mongodb_connection_string
   ```
   - Update your MongoDB connection string in the main.py file if needed

7. **Set up a WSGI/ASGI server**:
   - Create a `Procfile` in your backend directory:
   ```
   web: gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
   ```
   - This configures Gunicorn to run your FastAPI application

## Step 4: Deploy the Flutter Web Frontend

1. **Upload your Flutter web build**:
   - Use FTP or the File Manager to upload the contents of the `build/web` directory
   - Upload to the root directory of your hosting (usually `public_html`)

2. **Configure web server**:
   - In the Hostinger control panel, find the "Website" section
   - Make sure the document root is set to the directory where you uploaded your Flutter web files

3. **Set up URL rewriting for Flutter routing**:
   - Create a `.htaccess` file in your web root directory with the following content:
   ```
   RewriteEngine On
   RewriteBase /
   
   # If the request is not for a file or directory
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   
   # Rewrite all other URLs to index.html
   RewriteRule ^(.*)$ index.html [L]
   ```
   - This ensures that all routes are handled by Flutter's router

## Step 5: Configure CORS and Security

1. **Update CORS settings in your backend**:
   - Modify your FastAPI CORS middleware to allow requests from your domain:
   ```python
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["https://yourdomain.com"],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

2. **Set up HTTPS**:
   - In the Hostinger control panel, find the SSL section
   - Enable SSL for your domain
   - Choose "Let's Encrypt" for a free SSL certificate

## Step 6: Test Your Deployment

1. **Test the backend API**:
   - Visit `https://yourdomain.com/api` to verify the backend is running
   - Test specific endpoints like `https://yourdomain.com/api/predict?grade=2&time_taken=45`

2. **Test the frontend application**:
   - Visit `https://yourdomain.com` to verify the Flutter web app loads
   - Test all major functionality:
     - User authentication
     - Vocabulary levels and questions
     - API integration with both the external API and your backend
     - Report generation

3. **Test the external API integration**:
   - Make sure the application can still connect to `https://yasiruperera.pythonanywhere.com/predict`
   - Verify the fallback mechanism works if the external API is unavailable

## Troubleshooting

### Common Issues and Solutions

1. **CORS Errors**:
   - Check your CORS configuration in the backend
   - Verify that your frontend is using the correct URL for API requests

2. **404 Errors on Flutter Routes**:
   - Verify your `.htaccess` configuration
   - Make sure all routes are being redirected to `index.html`

3. **Backend Not Running**:
   - Check the Python application configuration in Hostinger
   - Verify that all dependencies are installed
   - Check the application logs for errors

4. **Database Connection Issues**:
   - Verify your MongoDB connection string
   - Make sure your database is accessible from Hostinger

## Maintenance and Updates

1. **Updating the Frontend**:
   - Make changes to your Flutter code locally
   - Rebuild the web application: `flutter build web --release`
   - Upload the new build to Hostinger

2. **Updating the Backend**:
   - Make changes to your Python code locally
   - Upload the updated files to Hostinger
   - Restart the Python application in the Hostinger control panel

## Conclusion

By following this guide, you should have successfully deployed your NVLD Vocabulary application on Hostinger. The application should be accessible via your domain name, with both the frontend and backend components working together seamlessly.

Remember to regularly back up your data and monitor your application's performance to ensure it continues to run smoothly.
