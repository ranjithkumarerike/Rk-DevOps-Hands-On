# Build Your First Production-Style Workflow with GitHub Actions

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/IV2Focqf11Q/maxresdefault.jpg)](https://www.youtube.com/watch?v=IV2Focqf11Q&ab_channel=CloudWithVarJosh)

---
## ⭐ Support the Project  
If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

* [Introduction](#introduction)  
* [Understanding Actions in GitHub Actions](#understanding-actions-in-github-actions)  
  * [Simple Example: Using Actions with `uses:` and `run:`](#simple-example-using-actions-with-uses-and-run)  
* [GitHub Marketplace](#github-marketplace)  
* [Sources of Actions](#sources-of-actions)  
  * [1. Official GitHub Actions](#1-official-github-actions)  
  * [2. Third-Party and Vendor Actions](#2-third-party-and-vendor-actions)  
  * [3. Organization-Specific Internal Actions](#3-organization-specific-internal-actions)  
* [**Demo 1:** Building and Running a Flask Application using GitHub Actions](#demo-1-building-and-running-a-flask-application-using-github-actions)  
  * [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication)  
  * [Step 2: Creating the Project Structure](#step-2-creating-the-project-structure)  
    * [Step 2.1: Creating the Flask Application](#step-21-creating-the-flask-application)  
    * [Step 2.2: Creating the Dockerfile](#step-22-creating-the-dockerfile)  
    * [Step 2.3: Creating the Requirements File](#step-23-creating-the-requirements-file)  
  * [Step 3: Creating the GitHub Actions Workflow](#step-3-creating-the-github-actions-workflow)  
  * [Step 4: Pushing the Code into GitHub](#step-4-pushing-the-code-into-github)  
  * [Step 5: Workflow Verification and Observation](#step-5-workflow-verification-and-observation)  
* [**Demo 2:** Building and Pushing Docker Images using GitHub Actions](#demo-2-building-and-pushing-docker-images-using-github-actions)  
  * [Step 1: Creating a Private DockerHub Repository](#step-1-creating-a-private-dockerhub-repository)  
    * [Step 1.1: Creating a DockerHub Access Token](#step-11-creating-a-dockerhub-access-token)  
  * [Step 2: Adding DockerHub Credentials into GitHub Secrets](#step-2-adding-dockerhub-credentials-into-github-secrets)  
  * [Step 3: Creating the Workflow](#step-3-creating-the-workflow)  
  * [Step 4: Pushing the Code into GitHub](#step-4-pushing-the-code-into-github-1)  
  * [Step 5: Workflow Verification and Observation](#step-5-workflow-verification-and-observation-1)  
* [Conclusion](#conclusion)  
* [References](#references)  

---

## Introduction

Modern CI/CD pipelines heavily rely on **reusable automation** instead of manually scripting every operational task from scratch. GitHub Actions enables this through reusable automation components called **actions**, which simplify workflow execution and accelerate software delivery.

In this lecture, we will understand:

* what actions are in GitHub Actions
* how `uses:` differs from `run:`
* how reusable actions simplify CI/CD workflows
* different sources of GitHub Actions
* GitHub Marketplace and action selection best practices
* workflow execution inside GitHub-hosted runners
* building and publishing container images using reusable Docker actions

Through practical demos, we will also explore important production concepts such as:

* reusable automation
* GitHub-hosted runners
* smoke testing
* GitHub Secrets
* DockerHub authentication
* ephemeral runner environments
* OCI-compliant container images

By the end of this lecture, you will understand how modern GitHub Actions workflows combine **reusable actions** with **custom scripting** to build scalable production-grade CI/CD automation pipelines.

---

## Understanding Actions in GitHub Actions

![Alt text](/images/3a.png)

In GitHub Actions, **actions** are reusable automation components that perform predefined tasks inside workflows. Instead of manually writing every operation using `run:`, actions allow you to reuse packaged automation logic created by GitHub, third-party vendors, open-source communities, or your own organization.

Modern CI/CD pipelines heavily rely on **reusable automation** instead of manually scripting everything from scratch. Actions commonly help automate:

* **source code checkout**
* runtime installation
* dependency management
* **Docker authentication**
* **container image builds**
* cloud authentication
* Kubernetes deployments
* security scanning
* caching
* artifact uploads
* notifications
* infrastructure provisioning

> **Note:** It is important to distinguish between **GitHub Actions** and **actions**. GitHub Actions is the overall automation and CI/CD platform provided by GitHub, whereas an action is an individual reusable automation component executed inside workflows.
>
> * **GitHub Actions** → the automation platform
> * **actions** → reusable automation building blocks executed within workflows

Actions are typically consumed using the **`uses:` keyword** inside workflow steps, whereas custom shell commands are typically executed using the `run:` keyword.

> **Conceptual Note:** Actions in GitHub Actions are essentially a way of packaging automation logic into **reusable workflow components**. Instead of repeatedly writing the same operational commands across workflows, reusable actions help standardize and simplify automation execution.
>
> This concept is not entirely new to DevOps engineers. Historically, teams have commonly used **shell scripts, Bash scripts, Python scripts, and automation tooling** to package repetitive operational commands into reusable executable units. This helped:
>
> * reduce manual effort
> * minimize human error
> * standardize operational behavior
> * improve automation consistency
> * accelerate execution workflows
>
> GitHub Actions extends this idea further by allowing reusable automation components to be versioned, shared, distributed, and consumed directly inside CI/CD workflows using the `uses:` keyword.


---

### Simple Example: Using Actions with `uses:` and `run:`

The following workflow demonstrates how GitHub Actions workflows commonly use both:

* **`uses:`** for reusable packaged automation
* **`run:`** for organization-specific custom logic and scripting

Example:

```yaml id="f4m8ks"
name: Understanding Actions

on: push

jobs:
  demo-action-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Print Message
        run: echo "Repository successfully checked out"
```

In the above workflow:

* **`actions/checkout@v6`** is an official GitHub Action maintained by GitHub
* it downloads repository code into the runner filesystem
* without this action, the runner initially does not contain repository files
* the **`uses:` keyword** tells GitHub Actions to execute reusable packaged automation logic
* the **`run:` keyword** executes custom shell commands directly on the runner operating system
* **`@v6`** represents the version of the action being consumed

> **Operational Note:** Although actions provide predefined automation logic, developers and DevOps engineers are still responsible for configuring actions correctly for their specific use-case. Most actions expose configurable **inputs, outputs, parameters, execution settings, and authentication options** that influence workflow behavior. For example, the checkout action supports configuring **branches, repository paths, fetch depth, and authentication behavior**. Every action typically provides documentation describing its supported configuration options, expected inputs and outputs, usage patterns, and operational behavior.

> **Note:** Step names in GitHub Actions are technically optional because `steps` simply represents a YAML list and individual step entries are not required to contain a `name` field.
>
> Example:
>
> ```yaml id="h9m4ks"
> steps:
>   - uses: actions/checkout@v6
>   - run: echo "Repository successfully checked out"
> ```
>
> However, in production environments, explicitly naming workflow steps is strongly recommended because step names significantly improve **readability, troubleshooting, workflow visualization, and log navigation**, especially in large CI/CD pipelines.


---

## GitHub Marketplace

Since actions are reusable automation components, GitHub provides a centralized marketplace for discovering and consuming reusable GitHub Actions and workflow automation integrations:

[GitHub Marketplace](https://github.com/marketplace)

The GitHub Marketplace contains:

* **official GitHub Actions** maintained by GitHub
* vendor-maintained actions published by cloud and infrastructure providers
* community-created reusable automation components
* open-source workflow integrations and CI/CD tooling

When selecting actions for production environments:

* prefer actions published by **verified creators** (blue verification badge)
* prefer **widely adopted and actively maintained** actions
* review documentation, repository activity, release history, and issue discussions
* inspect source code whenever possible before introducing actions into production pipelines

> **Important:** An action missing the verification badge is not automatically unsafe or malicious. However, organizations should always perform proper due diligence before using third-party actions in production environments.

Useful evaluation indicators commonly include:

* **GitHub stars** and community adoption
* maintenance activity and release frequency
* issue responsiveness and contributor activity
* source code transparency and documentation quality
* organizational reputation and ecosystem trustworthiness

---

## Sources of Actions

![Alt text](/images/3b.png)

Actions used in GitHub Actions workflows commonly originate from one of the following sources:

1. **Official GitHub Actions**
   Officially maintained and published by GitHub for common workflow automation tasks.

2. **Third-Party and Vendor Actions**
   Published by cloud providers, infrastructure vendors, open-source communities, and external maintainers.

3. **Organization-Specific Internal Actions**
   Custom reusable actions developed internally by organizations to standardize automation across repositories and engineering teams.

> **Operational Insight:** Modern CI/CD pipelines rarely rely only on custom shell scripting. Production workflows heavily leverage **reusable actions** to accelerate delivery, standardize automation behavior, reduce repetitive operational work, and integrate external tooling into workflows.

> **Recommendation:** If both GitHub and a third party provide similar actions for the same task, organizations often prefer the **official GitHub-maintained action** because of tighter platform integration and ecosystem trust.
>
> However, for platform-specific operations, vendor-maintained actions are often preferred. For example, for AWS-specific workflows, many organizations prefer actions maintained by **AWS** because they are typically more aligned with AWS services, authentication models, and feature updates.
>
> That said, there is no strict rule. The action you choose should:
>
> * satisfy your operational use-case
> * be actively maintained
> * be widely adopted by the community
> * have good documentation and support
> * align with your organization's security and operational requirements

---

### 1. Official GitHub Actions

GitHub maintains several **officially supported actions** that are heavily used across production CI/CD pipelines.

Common examples include:

* **`actions/checkout`** → checkout repository code into the runner
* **`actions/setup-java`** → install and configure Java runtimes
* **`actions/setup-python`** → install Python runtimes
* **`actions/cache`** → cache dependencies and build artifacts
* **`actions/upload-artifact`** → upload workflow artifacts
* **`actions/download-artifact`** → retrieve workflow artifacts

These actions are generally:

* **widely adopted**
* actively maintained by GitHub
* production-grade and stable
* deeply integrated with GitHub Actions workflows

> **Operational Note:** Official GitHub Actions are commonly the first choice for standard workflow automation tasks because they are maintained directly by GitHub and are deeply integrated with the GitHub Actions ecosystem.

---

### 2. Third-Party and Vendor Actions

Many cloud providers, infrastructure vendors, and open-source communities also publish reusable GitHub Actions.

Common examples include:

* **`docker/login-action`** → authenticate with Docker registries
* **`docker/build-push-action`** → build and publish Docker images
* **`aws-actions/configure-aws-credentials`** → authenticate with AWS
* **`azure/login`** → authenticate with Microsoft Azure
* **`google-github-actions/auth`** → authenticate with Google Cloud
* **`hashicorp/setup-terraform`** → install Terraform
* **`anchore/sbom-action`** → generate SBOMs

These actions help integrate GitHub Actions with broader:

* **cloud ecosystems**
* container platforms
* infrastructure tooling
* DevOps workflows
* security and compliance tooling

> **Operational Insight:** The large ecosystem of third-party and vendor actions is one of the biggest reasons behind the rapid adoption of GitHub Actions because organizations can quickly integrate existing tooling into workflows without building every automation component from scratch.

---

### 3. Organization-Specific Internal Actions

Large organizations often develop their own **internal reusable actions** to standardize CI/CD behavior across multiple repositories and engineering teams.

Common examples include:

* internal deployment actions
* reusable Kubernetes deployment actions
* organization-wide security scanning actions
* enterprise compliance validation actions
* centralized approval or notification actions
* internal build and release automation workflows

This becomes extremely important at scale because large enterprises often manage **hundreds or thousands of repositories** requiring:

* consistent CI/CD behavior
* centralized governance
* standardized security controls
* reusable operational workflows
* organization-wide automation standards

> **Operational Note:** Internal reusable actions significantly reduce duplication and allow platform engineering teams to centrally manage CI/CD automation patterns, security controls, compliance workflows, and deployment standards across the organization.

---

## Demo 1: Building and Running a Flask Application using GitHub Actions

In this demo, we will build and execute a simple **containerized Flask application** using **GitHub Actions**. The primary goal of this demo is to help you understand how modern GitHub Actions workflows operate inside **GitHub-hosted runners** using a combination of:

* reusable actions (`uses:`)
* custom shell commands (`run:`)

The overall workflow architecture for this demo is shown in the attached workflow diagram.

![Alt text](/images/3c.png)

In this demo pipeline:

1. GitHub Actions acts as the **workflow orchestrator**
2. the repository code is checked out into the runner
3. a Docker image is built inside the runner
4. a container is started inside the runner
5. a smoke test validates successful application startup

This demo is intentionally designed to help you visualize how:

* workflows execute step-by-step inside runners
* reusable actions and shell commands work together
* Docker commands execute directly inside GitHub-hosted infrastructure
* GitHub Actions automates CI workflows using both **actions** and **custom scripting**

By the end of this demo, we will:

* push source code into GitHub
* automatically trigger a workflow using the `push` event
* build a **Docker image** inside the runner
* start a **containerized application** inside the runner
* execute a **smoke test** against the running application
* observe workflow execution directly from the GitHub Actions UI

> **Operational Insight:** In this demo, the **GitHub-hosted runner** behaves like a temporary execution environment where all Docker operations, container startup tasks, and validation checks execute during workflow runtime. After workflow completion, the runner environment is automatically **destroyed**.

> **Terminology Note:** In this lecture, we frequently use the term **Docker image** because we are using Docker tooling to build the image and DockerHub as the container registry. Even the GitHub Action used in Demo 2 (`docker/build-push-action`) uses Docker-specific terminology.
>
> However, the broader industry-standard term is **container image** because the generated image is typically an **OCI-compliant image** (Open Container Initiative compliant). OCI-compliant container images can be built using different tools such as **Docker, Podman, Buildah, and Kaniko**. These standardized images can then be consumed across modern container ecosystems including platforms such as **Kubernetes**.

---

### Step 1: Repository Setup and Authentication

Before starting this demo, ensure that you already:

* have a GitHub repository created
* are authenticated with GitHub
* can push code successfully using Git

These concepts were covered extensively in **Lecture 01.**
* [Lecture 01 Video](https://youtu.be/w4c_NIjO3XI?)
* [Lecture 01 GitHub Notes](https://github.com/CloudWithVarJosh/GitHub-Actions-Basics-To-Production/tree/main/01-GitHub-Actions?)

For this lecture, we will use the following repository:

* **Repository Name:** `cwvj-gha-practice`
* **Visibility:** Private

> **Operational Note:** GitHub Actions workflows execute directly inside repositories. Whenever workflow YAML files are pushed into the repository, GitHub automatically detects and evaluates them based on configured workflow triggers.

---

### Step 2: Creating the Project Structure

We will now create a small **containerized Python application** using the Flask framework.

For simplicity, we will place all application files under a directory called:

```text id="f4m8ks"
project-files
```

Recommended directory structure:

```text id="m7q2pk"
project-files/
├── app.py
├── Dockerfile
├── requirements.txt
└── .github/
    └── workflows/
        └── 01-actions-demo.yaml
```

---

#### Step 2.1: Creating the Flask Application

Create the following Flask application:

**`app.py`**

```python id="x8q2pw"
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify(
        message="Welcome to Cloud With VarJosh",
        platform="GitHub Actions",
        runtime="Docker + Flask"
    )

@app.get("/health")
def health():
    return jsonify(status="healthy"), 200

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", 5000))
    )
```

**Understanding the Application**

This application:

* creates a lightweight Flask web server
* exposes an application endpoint at `/`
* exposes a health-check endpoint at `/health`
* listens on port `5000`
* runs inside a Docker container

The `/health` endpoint is especially important because production CI/CD pipelines commonly use:

* health endpoints
* smoke tests
* readiness validation
* liveness checks

to validate successful application startup.

---

**Optional Deep Dive**

* `from flask import Flask, jsonify`: imports the Flask framework and the `jsonify` helper used for returning JSON responses.

* `import os`: imports Python's operating system module. Used here to read environment variables such as `PORT`.

* `app = Flask(__name__)`: creates the Flask application object which acts as the main web application instance.

* `@app.get("/")`: defines an HTTP GET endpoint for the root path `/`. This endpoint returns application information in JSON format.

* `jsonify(...)`: converts Python objects into valid JSON HTTP responses. APIs commonly return JSON responses in modern applications.

* `@app.get("/health")`: defines a health-check endpoint used to validate successful application startup and runtime health.

* `return jsonify(status="healthy"), 200`: returns a JSON response with HTTP status code `200`, indicating successful application health.

* `host="0.0.0.0"`: allows the application to listen on all network interfaces inside the container. This is required for external accessibility from outside the container.

* `port=int(os.getenv("PORT", 5000))`: reads the port value from the `PORT` environment variable. If the variable is not defined, Flask defaults to port `5000`.

> **Operational Note:** Production CI/CD pipelines commonly use health-check endpoints such as `/health` for smoke testing, readiness validation, liveness checks, monitoring systems, and automated deployment validation workflows.


---

#### Step 2.2: Creating the Dockerfile

Create the following Dockerfile:

**`Dockerfile`**

```dockerfile id="h9m4ks"
FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

**Understanding the Dockerfile**

* `FROM python:3.13-slim`: uses the official lightweight Python 3.13 base image. Provides the runtime required to execute the Flask application.

* `WORKDIR /app`: sets `/app` as the working directory inside the container. Subsequent commands execute relative to this directory.

* `COPY requirements.txt .`: copies the dependency file into the container image. Makes the requirements file available during image build.

* `RUN pip install --no-cache-dir -r requirements.txt`: installs Python dependencies inside the image. The `--no-cache-dir` flag prevents `pip` from storing downloaded package cache files inside the image layers, helping reduce final image size and improve image efficiency.

* `COPY app.py .`: copies the Flask application source code into the image. Places the application inside the container working directory.

* `EXPOSE 5000`: documents that the application listens on port `5000`. Improves container readability and operational clarity.

* `CMD ["python", "app.py"]`: defines the default startup command for the container. Automatically starts the Flask application during container startup.

> **Operational Note:** GitHub-hosted Ubuntu runners already include Docker pre-installed. This allows workflows to directly execute Docker commands such as `docker build`, `docker run`, and `docker push` inside workflow steps.


---

#### Step 2.3: Creating the Requirements File

Create the following dependency file:

**`requirements.txt`**

```text id="t6m2qp"
flask==3.1.1
```

This file defines the Python dependencies required by the application.

In this demo, we are using **Flask**, which is a lightweight Python web framework commonly used for:

* REST APIs
* microservices
* backend applications
* lightweight web applications

The line:

```text id="m7q2pk"
flask==3.1.1
```

tells Python to install:

* the Flask package
* specifically version `3.1.1`

> **Operational Note:** The `requirements.txt` file is commonly used in Python applications to define application dependencies in a standardized and reproducible manner. This allows developers, CI/CD pipelines, and container images to install consistent dependency versions across different environments.



---

### Step 3: Creating the GitHub Actions Workflow

We will now create our first workflow that:

* checks out repository code
* builds a Docker image
* starts a container
* executes a smoke test

Create the following workflow file:

**`.github/workflows/01-actions-demo.yaml`**

```yaml id="v7m5qa"
name: 01 - CWVJ Flask CI Pipeline

on:
  push:

jobs:
  flask-ci-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Build Docker Image
        run: docker build -t cwvj-flask-app:v1.0.0 .

      - name: Run Container
        run: docker run -d -p 5000:5000 --name cwvj-flask-container cwvj-flask-app:v1.0.0

      - name: Smoke Test
        run: |
          sleep 5
          curl http://localhost:5000/health
```

---

#### Explanation

```yaml id="n4p8qx"
on:
  push:
```

This tells GitHub Actions to automatically trigger the workflow whenever new commits are pushed into the repository.

---

```yaml id="j2r7mk"
runs-on: ubuntu-latest
```

This tells GitHub Actions to:

* allocate a **GitHub-hosted Ubuntu runner**
* execute all workflow steps inside this runner environment

---

```yaml id="c8v1tr"
- name: Checkout Repository
  uses: actions/checkout@v6
```

This step:

* uses an **official GitHub Action**
* checks out repository source code into the runner workspace
* internally uses Git operations to retrieve repository contents
* allows subsequent workflow steps to access repository files

Without this step, the runner initially does not contain repository contents.

> **Operational Note:** By default, `actions/checkout` performs a **shallow repository fetch** using `fetch-depth: 1`. This means the workflow retrieves only the **latest commit** associated with the workflow execution instead of downloading the complete Git history. This significantly improves workflow speed, reduces network transfer, and optimizes runner execution time. Setting `fetch-depth: 0` instructs GitHub Actions to retrieve the **complete repository history** including all commits, branches, and tags.


---

```yaml id="k5x9zb"
- name: Build Docker Image
  run: docker build -t cwvj-flask-app:v1.0.0 .
```

This step executes the following Docker command inside the runner:

```bash id="x8q2pw"
docker build -t cwvj-flask-app:v1.0.0 .
```

Explanation:

* `docker build` → builds a Docker/container image using the Dockerfile present in the build context.

* `-t` → assigns a tag to the generated image.

* `cwvj-flask-app:v1.0.0` → full image reference/name.

  * `cwvj-flask-app` = repository name
  * `v1.0.0` = image tag/version

* `.` → current directory used as the Docker build context. Docker can access files present inside this directory during image creation.

The build context commonly contains:

* Dockerfile
* application source code
* dependency files
* configuration files

> **Operational Note:** During image build, Docker sends the build context to the Docker daemon. Large or unnecessary files inside the build context can increase image build time and network transfer overhead. This is one reason why production projects commonly use a `.dockerignore` file.


---

Similarly:

```yaml id="q3w6pl"
- name: Run Container
  run: docker run -d -p 5000:5000 --name cwvj-flask-container cwvj-flask-app:v1.0.0
```

This step executes the following Docker command:

```bash id="f4m8ks"
docker run -d -p 5000:5000 --name cwvj-flask-container cwvj-flask-app:v1.0.0
```

Explanation:

* `docker run` → creates and starts a container from an image
* `-d` → runs the container in detached/background mode
* `-p 5000:5000` →

  * first `5000` = runner host port
  * second `5000` = container application port
* `--name cwvj-flask-container` → assigns a custom container name
* `cwvj-flask-app:v1.0.0` → image used to start the container

This allows the Flask application running inside the container to become accessible from the runner environment using:

```bash id="h9m4ks"
curl http://localhost:5000/health
```


---

```yaml id="r8n4dj"
- name: Smoke Test
  run: |
    sleep 5
    curl http://localhost:5000/health
```

This step:

* waits briefly for container startup
* sends an HTTP request to the `/health` endpoint
* validates successful application startup

> **YAML Note:** The `|` symbol is called a **literal block scalar** in YAML. It allows writing multi-line commands while preserving line breaks, making it useful for executing multiple shell commands inside a single `run:` step.


> **Operational Note:** Production CI/CD pipelines commonly perform **smoke testing** immediately after deployment or container startup to validate that applications are operational before proceeding further in the pipeline.

> **Operational Note:** For simplicity, this demo primarily uses `run:` for Docker-related operations. However, production workflows commonly leverage reusable Docker actions such as **`docker/login-action`** and **`docker/build-push-action`** instead of manually writing every Docker command.
**We will see them in the next demo.**

> **Workflow Design Note:** In this demo, all workflow steps are intentionally placed inside a **single job** because each step depends on artifacts or runtime state created by previous steps. For example, the smoke test depends on the container started earlier in the workflow.
>
> In GitHub-hosted runners, each job receives a **fresh ephemeral runner environment**. This means if the smoke test were placed in a separate job, GitHub Actions would allocate a completely new runner that would not contain:
>
> * the previously built Docker image
> * the running container
> * temporary runtime state from the earlier job
>
> As a result, the smoke test would fail unless artifacts, images, or runtime state were explicitly transferred or recreated between jobs.


---

### Step 4: Pushing the Code into GitHub

Initialize and push the repository:

```bash id="p7x3lm"
# Initialize a new local Git repository
git init

# Stage all files for commit
git add .

# Create a new commit
git commit -m "feat: add GitHub Actions demo"

# Rename branch to main
git branch -M main

# Connect local repository to GitHub
git remote add origin git@github.com:CloudWithVarJosh/cwvj-gha-practice.git

# Push code to GitHub
git push -u origin main
```

> **Note:** If the repository already contains files from previous demos or lectures, the push operation may fail because of unrelated Git history. In such scenarios, either clean the repository beforehand or carefully use a force push *(**`--force`**)* if appropriate for the demo environment.

---

### Step 5: Workflow Verification and Observation

After pushing the code:

* GitHub automatically detects the workflow YAML
* the `push` event triggers workflow execution
* GitHub provisions a **GitHub-hosted Ubuntu runner**
* the workflow begins executing step-by-step inside the runner

#### Observing Workflow Execution

Inside the GitHub repository UI:

1. Open the repository
2. Navigate to the **Actions** tab
3. Open the running workflow
4. Observe:

   * workflow and job execution status
   * step-by-step execution logs
   * Docker image build logs
   * container startup logs
   * smoke test execution results

#### Key Observations

Observe how:

* **`uses:`** executes reusable actions
* **`run:`** executes shell commands directly inside the runner
* Docker commands execute successfully inside the GitHub-hosted runner
* workflow execution stops automatically if a step fails

> **Operational Insight:** GitHub-hosted runners are **ephemeral environments**. After workflow execution completes, the runner environment is automatically destroyed along with all temporary containers, files, and runtime state created during the workflow.

---

## Demo 2: Building and Pushing Docker Images using GitHub Actions

In the previous demo, we built and executed a containerized Flask application directly inside a **GitHub-hosted runner** using mostly **`run:` commands**.

In this demo, we will evolve that workflow further by introducing additional **reusable GitHub Actions** that simplify authentication, container image building, and image publishing workflows.

The overall workflow architecture for this demo is shown in the attached workflow diagram.

![Alt text](/images/3d.png)

In this demo pipeline:

1. GitHub Actions acts as the **workflow orchestrator**
2. the repository code is checked out into the runner
3. the workflow securely authenticates with DockerHub
4. a Docker image is built and pushed into a private DockerHub repository
5. a container is started inside the runner
6. a smoke test validates successful application startup

Unlike the previous demo, this workflow now uses:

* **official reusable actions**
* **vendor-maintained Docker actions**
* **GitHub Secrets for secure authentication**
* reusable automation instead of manually writing every Docker command

This is much closer to how modern **production CI/CD pipelines** operate.

By the end of this demo, we will:

* authenticate with DockerHub securely
* store credentials using **GitHub Secrets**
* use reusable **Docker actions** instead of manual Docker commands
* build and publish a **Docker image** into a private container registry
* run a container directly inside the runner
* execute a **smoke test** against the running application
* observe image publishing directly inside DockerHub

> **Operational Insight:** Production GitHub Actions workflows commonly combine **reusable actions with custom scripting**. Standardized operations such as authentication, image building, and registry publishing are often handled using reusable vendor-maintained actions, while organization-specific operational logic is commonly implemented using `run:` commands.
>
> GitHub Actions also allows organizations and developers to create their own **custom reusable actions** based on specific operational or business requirements. Large organizations commonly develop internal actions to standardize CI/CD behavior, security controls, deployment workflows, compliance validation, and platform automation across repositories. We will explore the creation of custom actions later in this course.


---

### Step 1: Creating a Private DockerHub Repository

Navigate to DockerHub:

[DockerHub](https://hub.docker.com)

Create a new **private repository**.

Use:

* **Repository Name:** `cwvj-flask-app`
* **Visibility:** Private

> **Operational Insight:** Container registries are a critical component of modern CI/CD pipelines because they act as centralized repositories for storing and distributing container images across environments such as development, staging, testing, and production.

---

#### Step 1.1: Creating a DockerHub Access Token

We already know from previous lectures that:

* each GitHub Actions job receives its own runner
* workflows execute inside these runners
* the runner must authenticate with external systems whenever protected resources are accessed

Since we want the runner to:

* authenticate with DockerHub
* push container images into a private repository

the workflow requires secure authentication credentials.

The recommended approach is to use:

* **DockerHub Access Tokens**
  instead of DockerHub passwords.

> **Important:** Never use your actual DockerHub account password inside CI/CD workflows. Always prefer access tokens.

#### Creating the Token

Inside DockerHub:

1. Click the top-right profile icon
2. Open **Account Settings**
3. Navigate to:

   * **Personal Access Tokens**
4. Click:

   * **Generate New Token**

Recommended values:

* **Access Token Description:** `gha-demo`
* **Expiration:** Custom → 1 Day
* **Access Permission:** Read & Write

After creation:

* copy the generated token immediately
* DockerHub only displays the token once

We will use this token later inside GitHub Secrets.

> **Operational Note:** DockerHub access tokens are created at the **account level**. Any user, system, runner, or automation workflow using the token inherits the **permissions assigned to that token** across repositories accessible to the DockerHub account, based on the configured token access scope.


> **Security Insight:** In production environments, organizations typically prefer short-lived credentials, credential rotation policies, least-privilege access controls, and centralized secret management instead of long-lived static credentials.

---

### Step 2: Adding DockerHub Credentials into GitHub Secrets

We will now securely store DockerHub credentials inside GitHub Secrets.

Inside the GitHub repository:

1. Open **Settings**
2. Navigate to:

   * **Secrets and variables** → **Actions**
3. Click:

   * **New repository secret**

Create the following secret:

| Secret Name          | Secret Value       |
| -------------------- | ------------------ |
| `DOCKERHUB_USERNAME` | `cloudwithvarjosh` |

> **Note:** You must use your own DockerHub username here.

Now create another secret:

| Secret Name       | Secret Value                     |
| ----------------- | -------------------------------- |
| `DOCKERHUB_TOKEN` | Paste the DockerHub access token |

---

#### Why GitHub Secrets are Important

GitHub Secrets provide a secure mechanism for injecting sensitive values into workflow runtimes.

GitHub automatically:

* injects secrets securely into workflow execution
* masks secrets inside workflow logs
* prevents accidental plaintext exposure in logs

> **Important Recommendation:** Do NOT use your actual DockerHub password. Always prefer DockerHub access tokens stored securely inside GitHub Secrets.

> **Security Insight:** Secrets should never be hardcoded directly inside workflow YAML files, source code repositories, or shell scripts.

---

### Step 3: Creating the Workflow

We will now create a new workflow that:

* authenticates with DockerHub
* builds a container image
* pushes the image into DockerHub
* starts a container
* performs smoke testing

Create the following workflow file:

**`.github/workflows/02-actions-demo.yaml`**

```yaml id="m7q2pk"
name: 02 - CWVJ Flask CI Pipeline

on:
  push:

jobs:
  flask-ci-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and Push Docker Image
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: cloudwithvarjosh/cwvj-flask-app:v1.0.1

      - name: Run Container
        run: docker run -d -p 5000:5000 --name cwvj-flask-container cloudwithvarjosh/cwvj-flask-app:v1.0.1

      - name: Smoke Test
        run: |
          sleep 5
          curl http://localhost:5000
```

---

#### Explanation



```yaml id="x8q2pw"
- name: Login to DockerHub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

This step:

* uses a **Docker-maintained reusable GitHub Action** for container registry authentication
* authenticates the runner with **DockerHub** before image push operations
* eliminates the need for manually writing `docker login` commands inside workflow steps
* securely injects credentials during workflow execution using **GitHub Secrets**

The credentials are retrieved dynamically from:

* `secrets.DOCKERHUB_USERNAME`
* `secrets.DOCKERHUB_TOKEN`

These secrets are configured inside:

* Repository Settings
* Secrets and variables
* Actions

The `with:` block is used to pass **input parameters** to reusable GitHub Actions.
In this example:

* `username` → passes the DockerHub username
* `password` → passes the DockerHub access token

Most reusable actions expose configurable inputs through the `with:` block such as:

* authentication credentials
* repository names
* image tags
* file paths
* runtime versions
* execution behavior

These supported inputs are documented in the action documentation.

> **Security Recommendation:** Sensitive credentials such as access tokens, passwords, API keys, and cloud credentials should always be stored using **GitHub Secrets**.
>
> Although usernames are commonly less sensitive and can also be stored using normal GitHub Variables, many organizations still prefer storing usernames inside secrets for operational consistency and centralized credential handling.

> **Operational Note:** Although this demo uses DockerHub authentication, `docker/login-action` is not limited to DockerHub alone. The same action can also authenticate GitHub Actions runners with multiple popular container registries such as:
>
> * Amazon ECR
> * Azure Container Registry (ACR)
> * GitHub Container Registry (GHCR)
> * Google Artifact Registry (GAR)
> * Harbor
> * Quay
>
> and other OCI-compatible container registries.


---

```yaml id="f4m8ks"
- name: Build and Push Docker Image
  uses: docker/build-push-action@v7
  with:
    context: .
    push: true
    tags: cloudwithvarjosh/cwvj-flask-app:v1.0.1
```

This step uses the **Docker-maintained `build-push-action`** to:

* build a Docker/container image
* optionally push the image into a container registry
* simplify image build workflows using reusable automation instead of manually writing Docker CLI commands

The `with:` block passes configuration inputs to the action.

---

```yaml id="h9m4ks"
context: .
```

Explanation:

* defines the Docker build context
* `.` means the current repository directory
* allows Docker to access files such as:

  * Dockerfile
  * application source code
  * dependency files

This is similar to:

```bash id="x8q2pw"
docker build .
```

---

```yaml id="t6m2qp"
push: true
```

Explanation:

* instructs the action to automatically push the generated image after a successful build
* without this, the image would only exist locally inside the runner

This behaves similarly to manually executing:

```bash id="v7m5qa"
docker push <image>
```

after image creation.

---

```yaml id="n4p8qx"
tags: cloudwithvarjosh/cwvj-flask-app:v1.0.1
```

Explanation:

* defines the full image reference/name for the generated image
* used both during image build and image push operations

Breakdown:

* `cloudwithvarjosh` → DockerHub account/namespace
* `cwvj-flask-app` → repository name
* `v1.0.1` → image tag/version

This is equivalent to manually tagging an image using:

```bash id="j2r7mk"
docker tag <image> cloudwithvarjosh/cwvj-flask-app:v1.0.1
```

> **Important:** You must replace `cloudwithvarjosh` with your own DockerHub username or organization namespace while pushing images into your repository.

> **Operational Insight:** The `docker/build-push-action` internally leverages Docker Buildx/BuildKit capabilities, which provide modern container image build features such as optimized caching, multi-platform builds, parallelized build execution, and improved build efficiency.


---

#### Understanding the Improvement over Demo 1

In Demo 1, we primarily used:

* `run:` commands
* direct Docker CLI execution

In this demo, we introduced:

* **`docker/login-action`**
* **`docker/build-push-action`**

This demonstrates one of the biggest advantages of GitHub Actions:

* reusable packaged automation
* reduced scripting complexity
* cleaner workflows
* standardized CI/CD automation patterns

> **Operational Insight:** Production GitHub Actions workflows commonly combine:
>
> * reusable actions for standardized automation
> * `run:` commands for organization-specific operational logic

---

### Step 4: Pushing the Code into GitHub

Push the updated workflow into GitHub:

```bash id="v7m5qa"
# Initialize a new local Git repository
git init

# Stage all files for commit
git add .

# Create a new commit
git commit -m "feat: add DockerHub integration workflow"

# Rename branch to main
git branch -M main

# Connect local repository to GitHub
git remote add origin git@github.com:CloudWithVarJosh/cwvj-gha-practice.git

# Push code to GitHub
git push -u origin main
```

> **Note:** If the repository already contains files from previous demos or lectures, the push operation may fail because of unrelated Git history. In such scenarios, either clean the repository beforehand or carefully use a force push (`--force`) if appropriate for the demo environment.

---

### Step 5: Workflow Verification and Observation

After pushing the code:

* GitHub automatically detects the new workflow
* the `push` trigger starts workflow execution
* GitHub provisions a GitHub-hosted Ubuntu runner
* the workflow begins executing step-by-step

#### Observing Workflow Execution

Inside the GitHub repository UI:

1. Open the repository
2. Navigate to the **Actions** tab
3. Open the running workflow
4. Observe:

   * workflow execution status
   * DockerHub authentication logs
   * Docker image build logs
   * image push execution
   * container startup logs
   * smoke test execution results

---

#### Verifying the Image in DockerHub

After successful workflow completion:

1. Open DockerHub
2. Navigate to:

   * `cloudwithvarjosh/cwvj-flask-app`
3. Observe:

   * newly pushed image tag `v1.0.1`
   * image metadata
   * push timestamps

This confirms:

* GitHub Actions successfully authenticated with DockerHub
* the container image was successfully built
* the image was successfully pushed into the private registry

> **Operational Insight:** Modern CI/CD pipelines commonly push generated container images into centralized container registries before deployment into Kubernetes clusters, Docker hosts, or cloud-native runtime environments.

---

## Conclusion

In this lecture, we developed a strong understanding of **actions in GitHub Actions** and explored how reusable automation simplifies modern CI/CD workflows.

We learned:

* how workflows use reusable actions
* the difference between `uses:` and `run:`
* how workflows execute inside GitHub-hosted runners
* how GitHub Marketplace helps discover reusable automation
* how reusable Docker actions simplify authentication and image publishing workflows
* how GitHub Secrets securely inject credentials during workflow execution

Through the demos, we also explored several production concepts including:

* containerized application workflows
* smoke testing
* container image builds
* reusable CI/CD automation patterns
* ephemeral runner behavior
* container image publishing pipelines

Most importantly, this lecture demonstrated one of the biggest strengths of GitHub Actions:

* combining **reusable automation** with **custom operational scripting**

This combination allows organizations to standardize repetitive automation workflows while still maintaining flexibility for organization-specific operational requirements.

In upcoming lectures, we will build on these concepts and gradually move toward more advanced GitHub Actions capabilities including custom actions, reusable workflows, environments, and production-grade CI/CD architectures.


---

## References

**Official GitHub Documentation**

* GitHub Actions Documentation
  https://docs.github.com/actions

* GitHub Marketplace
  https://github.com/marketplace

* GitHub Actions Workflow Syntax
  https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions

* actions/checkout
  https://github.com/actions/checkout


**Docker Documentation**

* Docker Documentation
  https://docs.docker.com

* docker/login-action
  https://github.com/docker/login-action

* docker/build-push-action
  https://github.com/docker/build-push-action

* DockerHub
  https://hub.docker.com


**OCI Specifications**

* Open Container Initiative (OCI)
  https://opencontainers.org

* OCI Image Specification
  https://github.com/opencontainers/image-spec


**Flask Documentation**

* Flask Official Documentation
  https://flask.palletsprojects.com
