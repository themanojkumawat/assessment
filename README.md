# Flask DevOps Task (Option A - Docker Compose)

A lightweight containerized Flask API with automated health checking, Docker Compose orchestration, a zero-downtime deployment script, and a GitHub Actions CI/CD pipeline with Trivy security scanning.

---

## 1. Bug Fix Explanation

In the original starter setup, two main issues prevented the app from working correctly in Docker:

- **Root Cause**: The Flask application was hardcoded to `127.0.0.1` (loopback). Inside a Docker container, loopback isolates the service so external requests and Docker health checks fail with `connection refused`.
- **How It Was Fixed**:
  1. Changed host binding to `0.0.0.0` so the container accepts incoming traffic.
  2. Made `PORT` configurable via `.env` file instead of hardcoded numbers.
  3. Replaced the single-threaded Flask development server with **Gunicorn** WSGI (2 workers).
  4. Added a dedicated `/health` endpoint and configured container health checks.
  5. Switched from default root user to a secure unprivileged user (`appuser`).

---

## 2. Project Links

- **GitHub Repository**: [https://github.com/themanojkumawat/assessment](https://github.com/themanojkumawat/assessment)
- **Docker Hub Repository**: [https://hub.docker.com/r/themanojkumawat/assessment](https://hub.docker.com/r/themanojkumawat/assessment)

---

## 3. Quick Start Guide (How to Run Locally)

### Prerequisites
- Docker & Docker Compose
- Python 3.10+ (for local tests)
- `curl`

### Step-by-Step Execution

1. **Clone the project:**
   ```bash
   git clone https://github.com/themanojkumawat/assessment.git
   cd assessment
   ```

2. **Setup environment file:**
   ```bash
   cp .env.example .env
   ```

3. **Run unit tests locally (optional):**
   ```bash
   pytest -v
   ```

4. **Start the app with Docker Compose:**
   ```bash
   docker compose up -d --build
   ```

5. **Check container status:**
   ```bash
   docker compose ps
   ```

6. **Test endpoints with curl:**
   ```bash
   # Main API endpoint
   curl http://localhost:5000/

   # Health check endpoint
   curl http://localhost:5000/health
   ```

7. **Pull & run directly from Docker Hub:**
   ```bash
   docker pull themanojkumawat/assessment:latest
   docker run -d -p 5000:5000 --name flask-app themanojkumawat/assessment:latest
   ```

---

## 4. Architecture & Design Choices

```text
[ User / Browser / curl ]
            │ Port 5000
            ▼
┌─────────────────────────────────────────────────────────┐
│ Docker Container (flask-devops-app)                     │
│                                                         │
│   Gunicorn WSGI Server (2 Workers)                      │
│         │                                               │
│         ▼                                               │
│   Flask App (app.py) ── Non-root user: appuser          │
│   Routes: /  and  /health                               │
│                                                         │
│   Healthcheck: curl http://localhost:5000/health (10s)  │
└─────────────────────────────────────────────────────────┘
```

### Why Option A (Docker Compose) instead of Option B (Kubernetes)?
- **Lightweight & Fast**: For a single microservice, Kubernetes requires a heavy control plane (Minikube/Kind uses 2GB+ RAM). Docker Compose uses under 50MB RAM and starts in 2 seconds.
- **Minimal Downtime**: Docker Compose replaces containers seamlessly (`up -d --remove-orphans`) without complex cluster configuration.

### Secrets Management
- Follows 12-Factor App rules: settings like `PORT` and `SECRET_KEY` are read from environment variables.
- `.env.example` has sample safe keys and is committed to GitHub.
- `.env` contains real local values and is strictly ignored in `.gitignore` and `.dockerignore`.

---

## 5. Automation Scripts

### 1. Deployment Script (`deploy.sh`)
Automatically builds the latest image, starts the container, and verifies health status:
```bash
./deploy.sh
```
- Waits up to 45 seconds for the container to become `healthy` before declaring success.

### 2. Health Monitor (`monitor.sh`)
Pings `/health` every 10 seconds and logs status and response time:
```bash
./monitor.sh
```
- Prints output to screen and saves history to `monitor.log`:
  ```text
  [2026-11-18 14:30:10] status: 200 | latency: 0.002s | target: http://localhost:5000/health
  ```

---

## 6. CI/CD Pipeline (GitHub Actions)

Workflow file: `.github/workflows/ci.yml`

On every **Push** or **Pull Request** to `main`:
1. **Tests**: Installs dependencies and runs `pytest -v`.
2. **Security Scan**: Runs Trivy vulnerability scanner to find security issues.
3. **Build & Push to Docker Hub**:
   - Runs **only on push to main** (skips on PRs for safety).
   - Uses GitHub Secrets (`DOCKER_USERNAME` and `DOCKER_PASSWORD`).
   - Pushes two tags: `:latest` and `:<commit-sha>`.

### Required GitHub Secrets
In your repo, go to **Settings > Secrets and variables > Actions** and add:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub Personal Access Token (PAT)

---

## 7. Demo Video Outline (3–5 Minutes)

**Video Link**: [Watch Demo](https://youtu.be/placeholder-demo-video) *(Replace with unlisted video link)*

- **0:00 - 0:45**: Project overview and explanation of the `127.0.0.1` binding bug fix.
- **0:45 - 1:45**: Run `pytest -v` and run `./deploy.sh` to show the container starting healthy.
- **1:45 - 2:30**: Test `/` and `/health` with curl, run `./monitor.sh` to show 10-second polling.
- **2:30 - 3:30**: Show GitHub Actions running the pipeline and the pushed image on Docker Hub.
