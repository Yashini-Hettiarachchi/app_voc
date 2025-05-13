# AWS Deployment for NVLD Vocabulary Application

This README provides a quick reference for deploying the NVLD Vocabulary application to AWS.

## Prerequisites

1. **AWS Account**: Create an account at [aws.amazon.com](https://aws.amazon.com/)
2. **AWS CLI**: Install from [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. **EB CLI**: Install using `pip install awsebcli`
4. **Flutter SDK**: For building the web application
5. **Python 3.8+**: For running the backend locally

## Quick Start

1. **Configure AWS CLI**:
   ```bash
   aws configure
   ```
   Enter your AWS Access Key ID, Secret Access Key, region (e.g., us-east-1), and output format (json)

2. **Initialize Elastic Beanstalk**:
   ```bash
   eb init
   ```
   Follow the prompts to set up your application

3. **Create Elastic Beanstalk Environment**:
   ```bash
   eb create nvld-vocabulary-api
   ```

4. **Update Environment Variables**:
   - Go to AWS Elastic Beanstalk Console
   - Select your application and environment
   - Go to Configuration > Software
   - Add environment variables:
     - MONGODB_CONNECTION_URL: your MongoDB connection string
     - Any other environment variables your application needs

5. **Update Frontend Configuration**:
   - Open `lib/constants/env.dart`
   - Update the `serverUrl` to point to your Elastic Beanstalk URL
   - Build the Flutter web application:
   ```bash
   flutter build web --release
   ```

6. **Create S3 Bucket for Frontend**:
   ```bash
   aws s3 mb s3://your-bucket-name
   ```

7. **Configure S3 for Static Website Hosting**:
   ```bash
   aws s3 website s3://your-bucket-name --index-document index.html --error-document index.html
   ```

8. **Set Bucket Policy for Public Access**:
   Create a file named `bucket-policy.json` with the following content:
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
   Apply the policy:
   ```bash
   aws s3api put-bucket-policy --bucket your-bucket-name --policy file://bucket-policy.json
   ```

9. **Upload Frontend to S3**:
   ```bash
   aws s3 sync build/web s3://your-bucket-name
   ```

10. **Create CloudFront Distribution** (Optional but recommended):
    - Go to AWS CloudFront Console
    - Create a new distribution
    - Select your S3 bucket as the origin
    - Configure as needed

## Deployment Scripts

For convenience, we've provided deployment scripts:

- **Windows**: Run `deploy_aws.bat`
- **Linux/Mac**: Run `./deploy_aws.sh` (make it executable first with `chmod +x deploy_aws.sh`)

Make sure to update the S3 bucket name and CloudFront distribution ID in these scripts before running them.

## Detailed Documentation

For more detailed instructions, refer to the [AWS_DEPLOYMENT_GUIDE.md](AWS_DEPLOYMENT_GUIDE.md) file.

## Troubleshooting

- **Backend Deployment Issues**:
  - Check Elastic Beanstalk logs in the AWS Console
  - Run `eb logs` to view logs from the command line

- **Frontend Deployment Issues**:
  - Verify S3 bucket permissions
  - Check CloudFront distribution settings
  - Test S3 website endpoint directly

- **CORS Issues**:
  - Verify CORS configuration in the FastAPI backend
  - Check that the frontend is using the correct URL

## Monitoring and Maintenance

- **Elastic Beanstalk Dashboard**: Monitor backend health and performance
- **CloudWatch**: Set up alarms for performance metrics
- **S3 Analytics**: Monitor storage usage and access patterns
- **CloudFront Monitoring**: Track CDN performance and cache hit rates

## Cost Management

- **AWS Free Tier**: Many services have a free tier for 12 months
- **Budget Alerts**: Set up budget alerts in AWS Billing
- **Resource Cleanup**: Delete unused resources to avoid charges
