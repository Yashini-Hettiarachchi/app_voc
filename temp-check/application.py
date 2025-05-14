from main import app as application

# AWS Elastic Beanstalk looks for an 'application' callable by default
if __name__ == "__main__":
    # Run the app when the script is executed directly
    import uvicorn
    uvicorn.run(application, host="0.0.0.0", port=8000)
