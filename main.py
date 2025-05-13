# Import the FastAPI app from the backend module
from backend.main import app

# This file is needed for Elastic Beanstalk to find the application
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
