# Step-by-Step Setup Guide

Everything runs on your own laptop using Docker. No cloud account or credit card needed.

**What you will end up with**

```
GitHub repo ──> Jenkins (in Docker) ──> Test ──> Docker build ──> Terraform ──> Running app container (localhost:3000)
```

---

## Part 0 - Install prerequisites (one time)

| Tool | Why | Check |
|------|-----|-------|
| Docker Desktop (Windows/Mac) or Docker Engine (Linux) | Runs Jenkins and the app | `docker --version` |
| Git | Source control | `git --version` |
| A GitHub account | Hosts your repository | - |
| (Optional) Node.js 20 | Run the app locally before pushing | `node --version` |
| (Optional) Terraform | Run Terraform manually for screenshots | `terraform version` |

Windows users: turn on **WSL 2 backend** in Docker Desktop and run the commands below in PowerShell or WSL.
Make sure Docker Desktop is **running** (whale icon is steady).

---

## Part 1 - Put the project on GitHub

1. Unzip the project and open a terminal inside the folder `jenkins-terraform-project`.
2. On github.com create a **new public repository** named `jenkins-terraform-project` (no README, no .gitignore).
3. Run:

```bash
git init
git add .
git commit -m "Initial commit: app, Jenkinsfile, Terraform"
git branch -M main
git remote add origin https://github.com/<YOUR-USERNAME>/jenkins-terraform-project.git
git push -u origin main
```

4. Refresh GitHub and confirm you see `Jenkinsfile`, `app/`, `terraform/`, `jenkins/`.
   **Screenshot 1:** the GitHub repository page.

---

## Part 2 - (Optional) Test the app locally

```bash
cd app
npm install
npm test
npm start          # open http://localhost:3000 then Ctrl+C
cd ..
```

---

## Part 3 - Start Jenkins in Docker

The `jenkins/` folder builds a Jenkins image that already contains Node.js, Docker CLI and Terraform.

```bash
cd jenkins
docker compose up -d --build
```

The first build takes a few minutes. Then:

```bash
docker logs jenkins 2>&1 | grep -A3 "initial admin password"
```

(Or: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`)

1. Open **http://localhost:8080**.
2. Paste the admin password.
3. Choose **Install suggested plugins** and wait.
4. Create your admin user (note the username/password) and click **Save and Finish**.

Verify the tools inside Jenkins:

```bash
docker exec jenkins node --version
docker exec jenkins docker --version
docker exec jenkins terraform version
```

**Screenshot 2:** Jenkins dashboard.
**Screenshot 3:** the three version commands above.

> **Linux note:** if the pipeline later says `permission denied ... docker.sock`, run
> `docker exec -u root jenkins chmod 666 /var/run/docker.sock` (classroom use only).

---

## Part 4 - Create the pipeline job

1. Dashboard -> **New Item**.
2. Name: `cicd-terraform-pipeline`, choose **Pipeline**, click OK.
3. Scroll to **Pipeline** section and set:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/<YOUR-USERNAME>/jenkins-terraform-project.git`
   - Branch Specifier: `*/main`
   - Script Path: `Jenkinsfile`
4. (Optional but good for marks) under **Build Triggers** tick **Poll SCM** and enter `H/2 * * * *`.
   The Jenkinsfile also declares this trigger, so it is applied after the first run.
5. **Save**.

**Screenshot 4:** the job configuration (Pipeline section showing the repo URL and script path).

If the repo is private, add credentials: Manage Jenkins -> Credentials -> Add (username + GitHub personal access token) and select them in the job. A public repo avoids this.

---

## Part 5 - Run the pipeline

1. Click **Build Now**.
2. Open build **#1** -> **Pipeline Overview** (or Stage View) and **Console Output**.
3. Expected stages, all green:
   `Checkout -> Install Dependencies -> Test -> Build Docker Image -> Terraform Init & Validate -> Terraform Plan -> Deploy (Terraform Apply) -> Smoke Test`
4. Open **http://localhost:3000** (home page) and **http://localhost:3000/health** (`{"status":"UP"}`).

**Screenshot 5:** stage view all green.
**Screenshot 6:** console output ending with `Finished: SUCCESS`.
**Screenshot 7:** the running app in the browser.
**Screenshot 8:** `docker ps` showing the container `cicd-demo-app` (label managed-by terraform).

First run can take 3-5 minutes because Terraform downloads the Docker provider and npm downloads packages.

---

## Part 6 - Prove it is automated (code change -> new deployment)

1. Edit `app/src/app.js` and change the heading text, e.g. `Version 2`.
2. Update the matching assertion in `app/test/app.test.js` only if you changed the text it checks (`Jenkins CI/CD`).
3. ```bash
   git add . && git commit -m "Change home page text" && git push
   ```
4. Within ~2 minutes Jenkins starts build **#2** by itself (or click Build Now).
5. Refresh http://localhost:3000 and see the new text.

**Screenshot 9:** Jenkins build history showing #1 and #2, with #2 triggered by SCM change.

### Show a failing test (great for the demo)

Change `expect(res.body.result).toBe(5)` to `toBe(6)`, push, and watch the **Test** stage fail and
the pipeline stop before deployment. Revert and push again to recover.
**Screenshot 10:** the red failed build.

---

## Part 7 - Terraform on its own (for the Terraform screenshots)

Terraform is also used by the pipeline, but you should demonstrate it manually too.
Needs Terraform on your laptop (https://developer.hashicorp.com/terraform/install) and the image built:

```bash
cd app
docker build -t cicd-demo-app:latest .
cd ../terraform
```

If running on Docker Desktop for Windows, set the host once:
`terraform apply -var='docker_host=npipe:////./pipe/docker_engine'`
(on Linux/Mac the default `unix:///var/run/docker.sock` works).

First remove the container Jenkins created so Terraform does not clash on the name/port:

```bash
docker rm -f cicd-demo-app
```

Then run and screenshot each command:

```bash
terraform init          # Screenshot 11
terraform validate      # Screenshot 12
terraform plan          # Screenshot 13  (shows 1 resource to add)
terraform apply         # type yes ->  Screenshot 14
terraform output        # Screenshot 15
docker ps
terraform destroy       # type yes ->  Screenshot 16 (shows IaC can also remove infra)
```

> Terraform keeps a local `terraform.tfstate`. If Jenkins later complains the container already exists,
> run `docker rm -f cicd-demo-app` and rebuild in Jenkins (Jenkins uses its own state in its workspace).

---

## Part 8 - Record the demonstration

Use the script in `docs/DEMO_SCRIPT.md` (about 6-8 minutes). Record with Zoom/Teams/Meet/OBS
(whatever your instructor asked for - "online demonstration"). Keep your face/voice on if required.

---

## Part 9 - Submit

Upload to Moodle:
1. `Jenkinsfile`
2. The `terraform/` folder (zip it) - include `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `modules/`
3. Screenshots (PDF or images, labelled)
4. GitHub repository link
5. Recording link/file

The assignment is past its Moodle due date (12 Nov), so message your instructor to ask whether a late submission is accepted.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `docker: command not found` inside the pipeline | You are not using the custom Jenkins image. Rebuild: `cd jenkins && docker compose up -d --build` |
| `permission denied ... /var/run/docker.sock` | `docker exec -u root jenkins chmod 666 /var/run/docker.sock` |
| `port is already allocated` on 3000 | Another app uses 3000. Change `HOST_PORT` in Jenkinsfile (both the env value and `APP_URL`) |
| Smoke test cannot reach `host.docker.internal` | Keep `extra_hosts` in `docker-compose.yml`; on Linux it needs Docker 20.10+ |
| `Container name "/cicd-demo-app" is already in use` | `docker rm -f cicd-demo-app` then re-run |
| Terraform provider download fails | Check internet/proxy; re-run `terraform init` |
| `npm install` slow/fails in Jenkins | Re-run build; check the internet connection |
| Pipeline can't clone repo | Check URL, branch name is `main`, repo is public |
| Jenkins shows "No such DSL method" | The suggested plugins were not installed; Manage Jenkins -> Plugins -> install Pipeline, Git |
