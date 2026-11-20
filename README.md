# Jenkins CI/CD + Terraform Mini Project

A small Node.js (Express) application with a complete CI/CD pipeline in Jenkins and
Infrastructure as Code in Terraform.

## Architecture

```
Developer ──push──> GitHub ──poll/webhook──> Jenkins (Docker)
                                                │
   Checkout → Install → Test → Docker Build → Terraform (init/validate/plan/apply) → Smoke Test
                                                                    │
                                                                    ▼
                                                      Docker container "cicd-demo-app"
                                                          http://localhost:3000
```

## Project structure

```
jenkins-terraform-project/
├── Jenkinsfile                  # Declarative pipeline
├── app/                         # Node.js application
│   ├── src/app.js, server.js
│   ├── test/app.test.js         # Jest + Supertest tests
│   ├── Dockerfile
│   └── package.json
├── terraform/                   # Infrastructure as Code
│   ├── versions.tf              # Provider + version constraints
│   ├── variables.tf
│   ├── main.tf                  # Calls the module
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── modules/docker_app/      # Reusable module (docker_container)
├── jenkins/                     # Jenkins-in-Docker setup (Node, Docker CLI, Terraform preinstalled)
│   ├── Dockerfile
│   └── docker-compose.yml
└── docs/
    ├── SETUP_GUIDE.md           # Full step-by-step instructions
    └── DEMO_SCRIPT.md           # Recording script + viva Q&A
```

## Application endpoints

| Endpoint | Result |
|----------|--------|
| `/` | HTML home page |
| `/health` | `{"status":"UP"}` |
| `/add/:a/:b` | `{"result": a+b}` (400 if not numbers) |

## Quick start

```bash
cd jenkins && docker compose up -d --build     # Jenkins on http://localhost:8080
```

Then follow [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) to create the pipeline job and run it.

## Pipeline stages

1. Checkout (Git)
2. Install Dependencies (`npm install`)
3. Test (`npm test`, coverage archived)
4. Build Docker Image (tagged with build number and `latest`)
5. Terraform Init & Validate
6. Terraform Plan
7. Deploy (Terraform Apply)
8. Smoke Test (`/health`)

## Terraform

Uses the `kreuzwerker/docker` provider so everything is free and local.
The configuration is split into variables, outputs and a reusable module
(`modules/docker_app`), and can be adapted to a cloud provider by swapping the resource.

```bash
cd terraform
terraform init && terraform validate && terraform plan && terraform apply
```
