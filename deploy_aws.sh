#!/bin/bash

echo "===== NVLD Vocabulary App AWS Deployment Script ====="

echo
echo "Step 1: Building Flutter web application..."
flutter build web --release

echo
echo "Step 2: Deploying backend to AWS Elastic Beanstalk..."
eb deploy

echo
echo "Step 3: Deploying frontend to S3..."
echo "IMPORTANT: You need to configure your S3 bucket name first!"
echo "Update the following command with your actual S3 bucket name:"
echo "aws s3 sync build/web s3://your-bucket-name"

echo
echo "Step 4: Invalidating CloudFront cache (if configured)..."
echo "IMPORTANT: You need to configure your CloudFront distribution ID first!"
echo "Update the following command with your actual CloudFront distribution ID:"
echo "aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths \"/*\""

echo
echo "Deployment completed!"
echo "Remember to update the serverUrl in lib/constants/env.dart to point to your AWS Elastic Beanstalk URL."
echo
