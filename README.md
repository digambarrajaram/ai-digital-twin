# AI Digital Twin

An end-to-end **AI Digital Twin** platform that creates a conversational, memory-enabled representation of a person or persona. The project includes a modern web frontend, a scalable backend API, persistent conversation memory, cloud-native AI via AWS Bedrock, full AWS infrastructure managed with Terraform, and CI/CD automation using GitHub Actions.

This repository is structured to mirror a real-world production system, from local development to fully automated multi-environment cloud deployment.

---

## Project Architecture Overview

- **Frontend**: Next.js (App Router) application providing a chat interface
- **Backend**: FastAPI service serving the Digital Twin API
- **AI Runtime**: AWS Bedrock (Amazon Nova models)
- **Memory**: Local JSON files (development) or Amazon S3 (production)
- **Infrastructure**: AWS Lambda, API Gateway, S3, CloudFront
- **IaC**: Terraform with environment isolation (dev / test / prod)
- **CI/CD**: GitHub Actions with OIDC-based AWS authentication

---

## Repository Structure

```
.
├── backend/                # FastAPI backend and AI logic
│   ├── data/               # Personal/context data for the Digital Twin
│   │   ├── facts.json
│   │   ├── summary.txt
│   │   ├── style.txt
│   │   └── linkedin.pdf
│   ├── context.py          # Prompt construction using personal data
│   ├── resources.py        # Data loaders (PDF, JSON, text)
│   ├── server.py           # FastAPI application (Bedrock-enabled)
│   ├── lambda_handler.py   # AWS Lambda entry point
│   ├── deploy.py           # Lambda packaging script
│   ├── requirements.txt    # Backend dependencies
│   └── .env.example        # Example backend environment variables
│
├── frontend/               # Next.js frontend
│   ├── app/                # App Router pages
│   ├── components/         # React components (chat UI)
│   ├── public/
│   └── package.json
│
├── memory/                 # Local conversation memory (development only)
│
├── terraform/              # Infrastructure as Code (AWS)
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── github-oidc.tf      # GitHub Actions IAM role (one-time setup)
│   └── backend-setup.tf    # Terraform remote state bootstrap (one-time)
│
├── scripts/                # Deployment and teardown scripts
│   ├── deploy.sh
│   ├── deploy.ps1
│   ├── destroy.sh
│   └── destroy.ps1
│
├── .github/workflows/      # GitHub Actions CI/CD pipelines
│   └── deploy.yml
│
├── .gitignore
├── .env.example
└── README.md
```

---

## Backend Overview

The backend is a **FastAPI** application designed to run both locally and in AWS Lambda.

### Key Features

- Conversational API (`/chat`)
- Persistent session-based memory
- Pluggable memory storage:

  - Local filesystem (development)
  - Amazon S3 (production)

- AWS Bedrock integration using Amazon Nova models
- Context-aware prompt construction from structured personal data

### Memory Model

Each conversation is assigned a `session_id`. Messages are stored as structured JSON and appended on every interaction. Only recent messages are included in the inference context to control token usage.

---

## Frontend Overview

The frontend is a **Next.js App Router** application with a responsive chat interface.

### Highlights

- React + TypeScript
- Tailwind CSS styling
- Real-time chat UX
- Session persistence via backend `session_id`
- Configurable API endpoint for local or cloud deployments

---

## AI & Prompting

The Digital Twin’s behavior is driven by:

- Structured facts (`facts.json`)
- Narrative summaries (`summary.txt`)
- Communication style guidelines (`style.txt`)
- Optional PDF-based context (e.g. LinkedIn profile)

All data is combined into a single, deterministic system prompt that enforces:

- No hallucination
- Professional tone
- Persona consistency
- Jailbreak resistance

---

## Infrastructure (Terraform)

All cloud resources are defined using **Terraform**, enabling reproducible deployments.

### Managed Resources

- AWS Lambda (backend API)
- API Gateway (HTTP API)
- S3 (frontend hosting + memory storage)
- CloudFront (global CDN)
- IAM roles and policies

### Environments

Terraform workspaces are used to isolate environments:

- `dev`
- `test`
- `prod`

Each environment has its own:

- Lambda function
- API Gateway
- S3 buckets
- CloudFront distribution

---

## CI/CD with GitHub Actions

The project includes a full CI/CD pipeline:

- Automatic deployment on push
- Manual environment selection
- Secure AWS authentication using OIDC (no long-lived secrets)
- Terraform state stored remotely in S3 with DynamoDB locking

---

## Local Development

### Backend

```bash
cd backend
uv add -r requirements.txt
uv run uvicorn server:app --reload
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend runs on `http://localhost:3000` and connects to the local backend by default.

---

## Deployment

### Automated (Recommended)

- Push to GitHub
- GitHub Actions builds and deploys infrastructure and application

### Manual

```bash
./scripts/deploy.sh dev
```

---

## Teardown

To completely remove infrastructure:

```bash
./scripts/destroy.sh dev
```

This safely removes all cloud resources for the selected environment.

---

## Security Notes

- No secrets are committed to the repository
- AWS access uses IAM roles and OIDC
- Terraform state is encrypted and locked
- Memory buckets are private by default

---

## License

This project is intended for educational and professional portfolio use. Customize and extend it to fit your own Digital Twin use case.
