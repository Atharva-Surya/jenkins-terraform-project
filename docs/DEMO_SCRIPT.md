# Demo Recording Script (6-8 minutes)

Speak in your own words; these are talking points. Rehearse once before recording.

## 1. Introduction (30 s)
- Name, PRN/roll number, project title.
- "I built a CI/CD pipeline with Jenkins and an Infrastructure-as-Code setup with Terraform for a small Node.js web app."

## 2. Architecture (1 min)
Show the diagram in README.md.
- Developer pushes code to **GitHub**.
- **Jenkins** pulls the code (SCM integration), installs dependencies, runs **Jest tests**, builds a **Docker image**.
- **Terraform** validates, plans and applies - it creates the container that runs the app.
- A **smoke test** calls `/health` to confirm deployment.

## 3. Repository walk-through (1 min)
Open GitHub: `app/`, `Jenkinsfile`, `terraform/`, `jenkins/`.

## 4. Jenkinsfile explanation (1.5 min)
Open the Jenkinsfile and explain each stage in one sentence:
- Checkout - gets code from Git.
- Install Dependencies - `npm install`.
- Test - `npm test`; if it fails the pipeline stops (that's the "gate").
- Build Docker Image - tags image with build number (versioning).
- Terraform Init/Validate/Plan - checks config and previews changes.
- Deploy - `terraform apply` creates/replaces the container.
- Smoke Test - curl `/health`.
- `post` block - success/failure messages. `pollSCM` trigger - automatic builds.

## 5. Terraform explanation (1.5 min)
Open `terraform/`:
- `versions.tf` - provider (Docker) and version pinning.
- `variables.tf` - inputs with defaults and a validation rule.
- `main.tf` - calls the reusable **module** `modules/docker_app`.
- Module creates a `docker_container` resource.
- `outputs.tf` - prints container name and URL.
- Mention the workflow: `init -> validate -> plan -> apply -> destroy`, and the **state file**.
- "Same code with a cloud provider would create a VM; I used Docker so it is free and local."

## 6. Live execution (2 min)
- Click **Build Now**, show Stage View turning green, open Console Output (point at the Terraform plan and apply).
- Open `localhost:3000` and `/health`.
- Run `docker ps` to show the Terraform-managed container.

## 7. Show automation (1 min)
- Change page text, commit, push.
- Show Jenkins starting a new build and the page updating.
- (Optional) Show a failing test stopping the deployment.

## 8. Conclusion (30 s)
- CI/CD benefits: fast feedback, fewer manual errors, repeatable deployments.
- IaC benefits: version-controlled, repeatable infrastructure.
- Possible improvements: webhooks, cloud deployment (AWS EC2), remote Terraform state, Slack/email notifications.

---

# Likely Viva Questions

**What is CI/CD?** CI = automatically integrating and testing code on every change. CD = automatically delivering/deploying the tested build.

**What is a Jenkinsfile? Why use it?** A text file defining the pipeline as code, stored in the repo so it is versioned and reviewable.

**Declarative vs Scripted pipeline?** Declarative has a structured `pipeline { stages { } }` syntax (used here); scripted is free-form Groovy.

**What does `agent any` mean?** Run on any available Jenkins executor.

**What does `checkout scm` do?** Checks out the same repo/branch configured in the job.

**Poll SCM vs Webhook?** Polling = Jenkins asks Git periodically. Webhook = Git notifies Jenkins instantly (needs a public URL).

**What happens if tests fail?** The Test stage fails, later stages are skipped, nothing is deployed.

**What is Terraform / IaC?** A tool to define infrastructure in declarative `.tf` files and provision it repeatably.

**Explain init, plan, apply, destroy.** init downloads providers; plan previews changes; apply makes them; destroy removes them.

**What is the state file?** `terraform.tfstate` maps your config to real resources so Terraform knows what exists.

**What is a provider / resource / variable / output / module?** Provider = plugin to talk to a platform (Docker). Resource = a thing to create (container). Variable = input. Output = printed result. Module = reusable group of resources.

**Why Docker provider instead of AWS?** Free, no credentials, same concepts; swapping the provider/resource is enough for a cloud.

**How are Jenkins and Terraform connected?** The Jenkins pipeline runs Terraform commands and passes the build number as `image_tag`.

**Why mount docker.sock?** So Jenkins' Docker CLI and Terraform talk to the host's Docker daemon to build/run containers.
