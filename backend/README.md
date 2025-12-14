# AI Digital Twin - Backend

The backend service for the AI Digital Twin, built with **FastAPI** and **Python 3.12**. It acts as the brain of the digital twin, managing the conversation logic, interfacing with **Amazon Bedrock** for LLM generation, and handling memory persistence.

## 🧠 Core Features

- **LLM Integration**: Uses `boto3` to converse with Amazon Bedrock (Model: `amazon.nova-micro-v1:0`).
- **Context Injection**: Dynamically loads personality data (facts, style, LinkedIn profile) to instruct the LLM.
- **Memory Management**: Persists conversation history to maintain context (Local JSON or S3).
- **Serverless Ready**: Designed to run on AWS Lambda (via `Mangum` adapter).

## 📂 Project Structure

```bash
.
├── server.py           # Main FastAPI entry point
├── deploy.py           # Custom script to package app for Lambda
├── lambda_handler.py   # Mangum adapter for AWS Lambda
├── context.py          # System prompt generation logic
├── resources.py        # Data loader (reads data/*)
├── requirements.txt    # Python dependencies
└── data/               # ⚠️ PERSONALITY DATA (Not committed to Git)
    ├── facts.json      # Structured bio data
    ├── style.txt       # Communication style guidelines
    ├── summary.txt     # Professional summary
    └── linkedin.pdf    # PDF export of LinkedIn profile
```

## ⚙️ Configuration

The application uses environment variables for configuration. Create a `.env` file for local development:

```bash
# .env
AWS_REGION=us-east-1
BEDROCK_MODEL_ID=amazon.nova-micro-v1:0
USE_S3=false            # Set to 'true' in production
S3_BUCKET=              # Required if USE_S3=true
CORS_ORIGINS=http://localhost:3000
```

## 💾 Personality Data (`data/`)

To "train" the twin, you must provide the following files in the `backend/data/` directory. These files are loaded at startup by `resources.py`.

1.  **`facts.json`**: Key-value pairs of biographical data.
    ```json
    {
      "name": "Jane",
      "full_name": "Jane Doe",
      "location": "San Francisco",
      "role": "Software Engineer"
    }
    ```
2.  **`style.txt`**: Text describing how the twin should speak (tone, brevity, quirks).
3.  **`summary.txt`**: A long-form biographical summary.
4.  **`linkedin.pdf`**: A PDF export of your LinkedIn profile (text is extracted for context).

## 🚀 Local Development

### Prerequisites

- Python 3.12+
- AWS Credentials configured (via `aws configure`) with access to Bedrock.

### Setup

1.  Create a virtual environment:
    ```bash
    python -m venv .venv
    # Windows:
    .venv\Scripts\activate
    # Mac/Linux:
    source .venv/bin/activate
    ```
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Run the development server:
    ```bash
    uvicorn server:app --reload
    ```
    The API will be available at `http://localhost:8000`.

## 📦 Deployment (Lambda)

We use a custom `deploy.py` script to package the application because Lambda requires specific Linux-compatible binaries.

```bash
# From the backend directory
python deploy.py
# Or via uv
uv run --with pip deploy.py
```

This script:

1.  Installs dependencies into a local `lambda-package` directory (using pip).
2.  Copies application code and `data/`.
3.  Zips everything into `lambda-deployment.zip`.

This zip file is then referenced by the Terraform infrastructure for deployment.
