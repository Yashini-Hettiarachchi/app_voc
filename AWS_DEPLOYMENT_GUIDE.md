# Hosting Your NVLD Vocabulary Application on AWS

This guide provides step-by-step instructions for hosting your Flutter web application and Python backend on AWS.

## Overview

Your application consists of two main components:
1. **Flutter Web Frontend**: The user interface built with Flutter
2. **Python FastAPI Backend**: The server-side API that handles data storage and processing

## Prerequisites

- An AWS account
- AWS CLI installed and configured
- EB CLI (Elastic Beanstalk Command Line Interface) installed
- Flutter SDK installed on your development machine
- Python 3.8+ installed on your development machine

## Step 1: Prepare Your Flutter Web Application

1. **Update the server URL in your environment configuration**:
   - Open `lib/constants/env.dart`
   - Update the `serverUrl` to point to your future AWS Elastic Beanstalk URL:
   ```dart
   // Server Details
   static const String serverUrl = 'https://your-eb-environment.elasticbeanstalk.com';
   ```

2. **Build the Flutter web application**:
   ```bash
   cd /path/to/your/app
   flutter build web --release
   ```
   This will create optimized web files in the `build/web` directory.

## Step 2: Set Up AWS Account and Services

1. **Create an AWS account** if you don't have one at [aws.amazon.com](https://aws.amazon.com/)

2. **Install and configure AWS CLI**:
   - Install AWS CLI: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - Configure AWS CLI:
   ```bash
   aws configure
   ```
   - Enter your AWS Access Key ID, Secret Access Key, region (e.g., us-east-1), and output format (json)

3. **Install EB CLI**:
   ```bash
   pip install awsebcli
   ```

## Step 3: Deploy the Backend to AWS Elastic Beanstalk

1. **Initialize Elastic Beanstalk application**:
   ```bash
   cd /path/to/your/backend
   eb init
   ```
   - Select your region
   - Create a new application or select an existing one
   - Select Python as the platform
   - Choose Python version (3.8 or higher)
   - Set up SSH for instance access (optional)

2. **Create an environment**:
   ```bash
   eb create nvld-vocabulary-api
   ```
   - This will create a new environment with the name "nvld-vocabulary-api"
   - Wait for the environment to be created (this may take several minutes)

3. **Configure environment variables**:
   - Go to the AWS Elastic Beanstalk Console
   - Select your application and environment
   - Go to Configuration > Software
   - Add environment variables:
     - MONGODB_CONNECTION_URL: your MongoDB connection string
     - Any other environment variables your application needs

4. **Deploy your application**:
   ```bash
   eb deploy
   ```
   - This will deploy your application to the Elastic Beanstalk environment

5. **Verify the deployment**:
   ```bash
   eb open
   ```
   - This will open your application in a web browser
   - You should see the FastAPI documentation page

## Step 4: Deploy the Flutter Web Frontend to S3 and CloudFront

1. **Create an S3 bucket**:
   - Go to the AWS S3 Console
   - Click "Create bucket"
   - Enter a unique bucket name (e.g., nvld-vocabulary-app)
   - Select your region
   - Uncheck "Block all public access" (since we want to host a public website)
   - Acknowledge the warning
   - Click "Create bucket"

2. **Configure the bucket for static website hosting**:
   - Select your bucket
   - Go to the "Properties" tab
   - Scroll down to "Static website hosting"
   - Click "Edit"
   - Select "Enable"
   - Enter "index.html" for both Index document and Error document
   - Click "Save changes"

3. **Set bucket policy for public access**:
   - Go to the "Permissions" tab
   - Click "Bucket policy"
   - Enter the following policy (replace `your-bucket-name` with your actual bucket name):
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadGetObject",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::your-bucket-name/*"
       }
     ]
   }
   ```
   - Click "Save changes"

4. **Upload your Flutter web build**:
   ```bash
   aws s3 sync build/web s3://your-bucket-name
   ```
   - This will upload all files from the `build/web` directory to your S3 bucket

5. **Create a CloudFront distribution**:
   - Go to the AWS CloudFront Console
   - Click "Create distribution"
   - For "Origin domain", select your S3 bucket website endpoint
   - For "Default root object", enter "index.html"
   - Configure other settings as needed
   - Click "Create distribution"
   - Wait for the distribution to deploy (this may take up to 15 minutes)

6. **Configure CloudFront for SPA routing**:
   - Go to the CloudFront Console
   - Select your distribution
   - Go to the "Error pages" tab
   - Click "Create custom error response"
   - For "HTTP error code", select "404: Not Found"
   - Select "Yes" for "Customize error response"
   - For "Response page path", enter "/index.html"
   - For "HTTP Response code", select "200: OK"
   - Click "Create"

## Step 5: Configure DNS and SSL (Optional)

1. **Register a domain with Route 53** (or use an existing domain):
   - Go to the Route 53 Console
   - Click "Registered domains" > "Register domain"
   - Follow the steps to register a domain

2. **Create a hosted zone**:
   - Go to the Route 53 Console
   - Click "Hosted zones" > "Create hosted zone"
   - Enter your domain name
   - Select "Public hosted zone"
   - Click "Create"

3. **Request an SSL certificate**:
   - Go to the AWS Certificate Manager Console
   - Click "Request a certificate"
   - Select "Request a public certificate"
   - Enter your domain name (and optionally, *.yourdomain.com for subdomains)
   - Select "DNS validation"
   - Click "Request"
   - Follow the steps to validate your domain

4. **Update CloudFront distribution**:
   - Go to the CloudFront Console
   - Select your distribution
   - Click "Edit"
   - Under "Custom SSL Certificate", select your certificate
   - Under "Alternate domain names (CNAMEs)", add your domain name
   - Click "Save changes"

5. **Create Route 53 record**:
   - Go to the Route 53 Console
   - Select your hosted zone
   - Click "Create record"
   - Enter your domain name
   - Select "A - Routes traffic to an IPv4 address and some AWS resources"
   - Select "Alias"
   - Select "Alias to CloudFront distribution"
   - Select your CloudFront distribution
   - Click "Create records"

## Step 6: Test Your Deployment

1. **Test the backend API**:
   - Visit `https://your-eb-environment.elasticbeanstalk.com` to verify the backend is running
   - Test specific endpoints like `https://your-eb-environment.elasticbeanstalk.com/predict?grade=2&time_taken=45`

2. **Test the frontend application**:
   - Visit your CloudFront URL or custom domain to verify the Flutter web app loads
   - Test all major functionality:
     - User authentication
     - Vocabulary levels and questions
     - API integration with both the external API and your backend
     - Report generation

## Maintenance and Updates

1. **Updating the Backend**:
   ```bash
   cd /path/to/your/backend
   # Make your changes
   eb deploy
   ```

2. **Updating the Frontend**:
   ```bash
   cd /path/to/your/app
   # Make your changes
   flutter build web --release
   aws s3 sync build/web s3://your-bucket-name
   ```
   - You may need to invalidate the CloudFront cache:
   ```bash
   aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
   ```

## Troubleshooting

### Common Issues and Solutions

1. **CORS Errors**:
   - Check your CORS configuration in the backend
   - Verify that your frontend is using the correct URL for API requests

2. **404 Errors on Flutter Routes**:
   - Verify your CloudFront error page configuration
   - Make sure all routes are being redirected to `index.html`

3. **Backend Not Running**:
   - Check the Elastic Beanstalk logs
   - Verify that all dependencies are installed
   - Check the environment variables

4. **Database Connection Issues**:
   - Verify your MongoDB connection string
   - Make sure your database is accessible from AWS

## Conclusion

By following this guide, you should have successfully deployed your NVLD Vocabulary application on AWS. The application should be accessible via your CloudFront URL or custom domain, with both the frontend and backend components working together seamlessly.

Remember to regularly back up your data and monitor your application's performance to ensure it continues to run smoothly.
