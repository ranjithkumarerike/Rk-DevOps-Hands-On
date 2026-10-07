# GitHub Actions Environments Explained | Variables, Secrets, Approvals & Protection Rules

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/p_qnXBlJg20/maxresdefault.jpg)](https://www.youtube.com/watch?v=p_qnXBlJg20)

---

## ⭐ Support the Project  

If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

- [Introduction](#introduction)  
- [Why GitHub Actions Environments?](#why-github-actions-environments)  
  - [Deployment Challenges Solved by GitHub Actions Environments](#deployment-challenges-solved-by-github-actions-environments)  
    - [Challenge 1: Environment-specific Configuration](#challenge-1-environment-specific-configuration)  
    - [Challenge 2: Environment-specific Secrets](#challenge-2-environment-specific-secrets)  
    - [Challenge 3: Controlled Deployments](#challenge-3-controlled-deployments)  
- [What are GitHub Actions Environments?](#what-are-github-actions-environments)  
- [GitHub Actions Environments vs Deployment Tools](#github-actions-environments-vs-deployment-tools)
- [GitHub Actions Environments vs Workflow Triggers and Conditions](#github-actions-environments-vs-workflow-triggers-and-conditions)
- [**Demo 1:** Deploying an Application Using GitHub Actions Environments](#demo-1-deploying-an-application-using-github-actions-environments)  
  - [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication)  
  - [Step 2: Preparing the Application](#step-2-preparing-the-application)  
  - [Step 3: Preparing Docker Hub](#step-3-preparing-docker-hub)  
  - [Step 4: Configuring Variables, Secrets, and GitHub Actions Environments](#step-4-configuring-variables-secrets-and-github-actions-environments)  
  - [Step 5: Creating the Workflow](#step-5-creating-the-workflow)  
  - [Step 6: Commit and Push the Changes](#step-6-commit-and-push-the-changes)  
  - [Step 7: Running the Workflow](#step-7-running-the-workflow)  
  - [Step 8: Observing Workflow Execution](#step-8-observing-workflow-execution)  
- [**Demo 2:** Enhancing Our Deployment Pipeline](#demo-2-enhancing-our-deployment-pipeline)  
  - [Enhancement 1: Deployment Branch Restrictions](#enhancement-1-deployment-branch-restrictions)  
  - [Enhancement 2: Exploring Additional Deployment Protection Rules](#enhancement-2-exploring-additional-deployment-protection-rules)  
  - [Enhancement 3: Required Reviewers and Wait Timer](#enhancement-3-required-reviewers-and-wait-timer)  
  - [Validating the Enhanced Deployment](#validating-the-enhanced-deployment)  
- [Conclusion](#conclusion)  
- [References](#references)  

---

## Introduction

In the previous lectures, we learned how to build complete CI/CD workflows using GitHub Actions by creating workflows, jobs, steps, reusable workflows, matrices, expressions, outputs, artifacts, and many other powerful features.

Until now, however, every deployment in our workflows behaved the same way. Once the deployment job started, GitHub simply executed the deployment without considering **where** the application was being deployed or **what governance policies** should be enforced.

In this lecture, we introduce **GitHub Actions Environments**, one of the most important features for building **production-ready deployment pipelines**.

By the end of this lecture, you will understand how GitHub Actions Environments help organizations implement **deployment governance** by supporting:

- **Environment-specific Variables**
- **Environment-specific Secrets**
- **Deployment Branch Restrictions**
- **Required Reviewers**
- **Wait Timers**
- **Deployment History**
- **Deployment Protection Rules**

You will also learn an important architectural principle followed by mature CI/CD pipelines: **Build Once, Deploy Many**, where the same immutable application artifact is promoted across multiple deployment environments instead of being rebuilt for each deployment.

Finally, through two end-to-end demonstrations, we will progressively transform a simple deployment pipeline into a **secure**, **controlled**, and **production-ready deployment workflow** while keeping the workflow YAML largely unchanged.

---

## Why GitHub Actions Environments?

![Alt text](/images/10a.png)

So far in this course, every workflow that we have created has executed directly against the repository. Once the workflow reached the deployment step, it immediately deployed the application.

For example:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      ...
```

For small projects and personal repositories, this approach may be perfectly acceptable.

However, **enterprise software is rarely deployed directly into Production**. Instead, applications typically progress through multiple deployment environments before reaching end users.

Another important concept followed by modern CI/CD pipelines is **Build Once, Deploy Many**. Rather than rebuilding the application for every environment, organizations typically **build the application once**, produce a deployable artifact, and **promote the same artifact** across multiple environments.

For example:

* **Containerized applications** are built once as a **container image**. The application package (for example, a **JAR**, **WAR**, or compiled application binaries) is bundled **inside the container image**. As the same container image is promoted across **Development**, **Staging (Pre-Production)**, and **Production**, the same application package is promoted along with it.
* **Traditional applications** are typically packaged as **JAR**, **WAR**, **ZIP**, **EXE**, **MSI**, **RPM**, **DEB**, or other package formats and then promoted across **Development**, **Staging (Pre-Production)**, and **Production**, where the deployment target is often a **Virtual Machine (VM)** or a physical server.

Conceptually:

```text
Build Once → Deploy to Development → Promote Same Artifact → Deploy to Staging → Promote Same Artifact → Deploy to Production
```

A typical deployment pipeline therefore looks like:

```text
Developer → Development → Staging → Production
```

> **Note:** There is no standard set of deployment environments. Different applications and organizations define different environment strategies based on their business, compliance, and release requirements. Some may use only **Development** and **Production**, while others may include additional environments such as **QA**, **UAT**, **Performance**, or **Disaster Recovery (DR)**. The deployment strategy is typically defined by the **Application Architect** in collaboration with the **DevOps/Platform Engineering team**.

Each environment exists for a different purpose.

| Environment                  | Purpose                                                              |
| ---------------------------- | -------------------------------------------------------------------- |
| **Development**              | Developer validation and early integration                           |
| **Staging (Pre-Production)** | Production-like environment used for final validation before release |
| **Production**               | Live customer traffic                                                |

---

### Deployment Challenges Solved by GitHub Actions Environments

![Alt text](/images/10a.png)

At first glance, deploying across multiple environments appears straightforward.

```text
Deploy Development → Deploy Staging → Deploy Production
```

However, **real-world deployments introduce several operational challenges** that cannot be solved by simply executing deployment scripts. Organizations require mechanisms to control **how**, **when**, and **under what conditions** deployments are allowed to proceed.

The most common challenges include:

1. **Environment-specific Configuration**, each deployment environment uses different URLs, databases, API endpoints, feature flags, and application settings.

2. **Environment-specific Secrets**, every deployment environment requires its own credentials, API tokens, certificates, and other sensitive information.

3. **Controlled Deployments**, organizations need a mechanism to control **who can deploy**, **which branches can deploy**, and **under what conditions** deployments are allowed to proceed by enforcing **deployment approvals**, **required reviewers**, **wait timers**, **branch restrictions**, and other deployment policies.

Let's understand each challenge.

---


### Challenge 1: Environment-specific Configuration

Every deployment environment typically uses **different configuration values** because the underlying infrastructure is different. Although the **application artifact** remains the same, the configuration it uses changes from one environment to another.

Without environment-specific configuration management, teams often resort to naming conventions such as:

| Development        | Production          |
| ------------------ | ------------------- |
| `DEV_APP_URL`      | `PROD_APP_URL`      |
| `DEV_API_ENDPOINT` | `PROD_API_ENDPOINT` |
| `DEV_DEBUG_MODE`   | `PROD_DEBUG_MODE`   |

As the number of deployment environments grows, this approach quickly becomes difficult to maintain. Every workflow must also contain additional logic to determine which configuration values should be used for a particular deployment.

Ideally, the workflow should simply reference:

```text
APP_URL
API_ENDPOINT
DEBUG_MODE
```

while the deployment platform automatically provides the correct values for the target deployment environment.

Organizations therefore require a mechanism that automatically injects the correct configuration into each deployment environment while allowing workflows to use **consistent variable names** across all environments.

> **Production Insight:** Modern CI/CD pipelines typically **externalize configuration** from the application artifact. Configuration is injected during deployment using mechanisms such as **Environment Variables**, **Kubernetes ConfigMaps**, **AWS Systems Manager Parameter Store**, **AWS AppConfig**, **Azure App Configuration**, or similar services.

---

### Challenge 2: Environment-specific Secrets

Just like configuration, every deployment environment typically requires its own **secrets**. Although the **application artifact** remains the same, the credentials it uses change from one environment to another.

Without environment-specific secret management, teams often resort to naming conventions such as:

| Development          | Production            |
| -------------------- | --------------------- |
| `DEV_DB_PASSWORD`    | `PROD_DB_PASSWORD`    |
| `DEV_API_TOKEN`      | `PROD_API_TOKEN`      |
| `DEV_AWS_ACCESS_KEY` | `PROD_AWS_ACCESS_KEY` |

As the number of deployment environments grows, this approach quickly becomes difficult to maintain. Every workflow must also contain additional logic to determine which secret should be used for a particular deployment.

Ideally, the workflow should simply reference:

```text
DB_PASSWORD
API_TOKEN
AWS_ACCESS_KEY
```

while the deployment platform automatically provides the correct values for the target deployment environment.

Organizations therefore require a mechanism that automatically injects the correct secrets into each deployment environment while allowing workflows to use **consistent secret names** across all environments.

> **Production Insight:** Secrets are typically managed outside the application using services such as **AWS Secrets Manager**, **Azure Key Vault**, **Google Secret Manager**, **HashiCorp Vault**, or **Kubernetes Secrets**. Organizations generally prefer **consistent secret names** while allowing the platform to inject the appropriate environment-specific values during deployment.

---

### Challenge 3: Controlled Deployments

Not every job associated with an Environment should be allowed to execute automatically. As applications move closer to **Production**, organizations typically enforce stricter controls over **which branches can use an Environment**, **who can approve access to that Environment**, and **what conditions must be satisfied** before a job is allowed to proceed.

Although these controls are most commonly used for **deployment jobs**, they can be applied to **any job** associated with a GitHub Actions Environment whenever additional governance is required.

For example, organizations often restrict Environment usage as follows:

```text
develop → Development ✓
main → Production ✓
feature/* → Production ✗
```

Organizations may also require jobs targeting the **Production Environment** to be approved by authorized users before execution begins.

```text
Developer → Build → Production Job
                          ↓
                 Waiting for Approval
                          ↓
              Release Engineer Approves
                          ↓
                   Continue Execution
```

Some organizations also configure a **Wait Timer** after approval to provide a brief window for **final operational checks**, **deployment coordination**, or a **last-minute cancellation** before the job continues.

Without these controls, an unauthorized or unintended job could execute against a sensitive Environment, potentially resulting in **service outages**, **failed releases**, **security issues**, or **compliance violations**.

Organizations therefore require a mechanism that can enforce **Deployment Branch Restrictions**, **Required Reviewers**, **Wait Timers**, and other Environment-specific policies without embedding complex governance logic directly into every workflow.

---

#### At this point, a natural question arises:

> **Can GitHub provide a built-in mechanism to represent deployment environments while automatically handling environment-specific configuration, environment-specific secrets, and controlled deployments?**

We will answer this question next when we discuss **GitHub Actions Environments**.

---

### What are GitHub Actions Environments?

![Alt text](/images/10a.png)

GitHub Actions **Environments** provide a mechanism to represent different **deployment environments**, such as **Development**, **Staging**, and **Production**, within a GitHub repository.

Although GitHub Actions Environments are primarily designed to represent **deployment environments**, they can be associated with **any GitHub Actions job** that requires **environment-specific configuration** or **protection rules**. In practice, they are most commonly used by jobs that deploy applications to different environments.

By associating a job with an Environment, organizations can apply **environment-specific configuration**, **deployment protection rules**, and other **environment-specific controls** without increasing the complexity of their workflow YAML.

For example:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production

    steps:
      ...
```

Although this appears to be a simple configuration:

```yaml
environment: production
```

it is one of the most powerful features in GitHub Actions. From a workflow author's perspective, only a **single line** has been added. However, from GitHub's perspective, the **job execution lifecycle** changes.

Instead of immediately executing the job, GitHub first associates it with the configured **Production Environment**, evaluates the configured **deployment protection rules**, loads the appropriate **Environment Variables** and **Environment Secrets**, and only then allows the job to begin executing.

Conceptually:

```text
Job → Associate Environment → Evaluate Protection Rules → Load Environment Configuration → Execute Job
```

Depending on how the Environment is configured, GitHub can automatically provide:

| Capability                         | Purpose                                                                          |
| ---------------------------------- | -------------------------------------------------------------------------------- |
| **Environment Variables**          | Provide environment-specific configuration values to the job.                    |
| **Environment Secrets**            | Provide environment-specific credentials to the job.                             |
| **Deployment Branch Restrictions** | Restrict which branches are allowed to use the Environment.                      |
| **Required Reviewers**             | Require manual approval before jobs associated with the Environment can proceed. |
| **Wait Timer**                     | Delay job execution after approval for a configurable duration.                  |
| **Deployment History**             | Record deployment activity for auditing and traceability.                        |

---

### GitHub Actions Environments vs Deployment Tools

GitHub Actions **Environments** are often confused with deployment tools. They are **not responsible for deploying applications**. Instead, they determine **whether a job is permitted to use an Environment**, **which Environment Variables and Secrets are made available**, and **which protection rules must be satisfied** before the job begins executing.

Once these checks have been completed, the workflow remains responsible for performing the actual deployment using the appropriate deployment tool.

For example:

```text
kubectl • Helm • Terraform • AWS CLI • Azure CLI • Docker • SSH • Ansible
```

Conceptually:

```text
Workflow → Job → GitHub Actions Environment → Protection Rules → Variables & Secrets → Execute Job
                                                           ↓
                                              Deployment Tool (if required)
                                                           ↓
                                                Target Environment
```

For example, suppose a workflow contains a job associated with the **Production** Environment.

```text
Job → Associate Production Environment → Evaluate Protection Rules → Load Production Variables & Secrets → Execute Job
```

If the same workflow associates a job with the **Development** Environment, GitHub evaluates the rules configured for that Environment instead.

```text
Job → Associate Development Environment → Load Development Variables & Secrets → Execute Job
```

The important point is that **the workflow logic remains almost identical**, while the job behavior changes based on the **associated Environment**.

> **Key Observation:** GitHub Actions **Environments are environment governance mechanisms**, not deployment tools. They associate a job with an Environment before execution, allowing GitHub to apply **environment-specific configuration**, evaluate **deployment protection rules**, and record **deployment history** without increasing workflow complexity. If the job performs a deployment, it remains the responsibility of the workflow to invoke the appropriate deployment tool.

---

> **Note:** Throughout this lecture, I'll be using a **GitHub Free** personal account with a **private repository**. GitHub frequently updates both its **feature set** and **licensing model**, so if you're evaluating GitHub for your organization or considering an upgrade, always verify the latest information using the official GitHub resources.
>
> While this lecture focuses specifically on **GitHub Actions Environments**, remember that they represent just one capability within the broader GitHub platform. If you're evaluating GitHub for your organization or considering an upgrade, assess the **overall platform capabilities** offered by each GitHub plan rather than making a decision based on a single feature.
>
> Consider evaluating capabilities across areas such as:
>
> * **CI/CD & Automation** → GitHub Actions, Environments, Hosted Runners, Codespaces.
> * **Security** → GitHub Advanced Security, Secret Protection, Dependabot, Code Scanning.
> * **Collaboration** → Pull Request Reviews, CODEOWNERS, Repository Rules, Branch Protection.
> * **Enterprise** → SAML/SSO, SCIM User Provisioning, Audit Logs, Enterprise Managed Users (EMU), Compliance & Governance.
>
> For the latest feature availability and licensing details, refer to:
>
> * [GitHub Pricing](https://github.com/pricing)
> * [GitHub Plans Documentation](https://docs.github.com/en/enterprise-cloud/latest/get-started/learning-about-github/githubs-plans)
> * [Deployments and Environments Documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)

---

### GitHub Actions Environments vs Workflow Triggers and Conditions

GitHub Actions **Environments** should not be confused with **Workflow Triggers**, **Event Filters**, **Activity Types**, or **Job Conditions**. Although these features may appear related, they solve **different problems** and are evaluated at **different stages** of workflow execution.

Conceptually:

```text
Workflow Trigger (on:)
        ↓
Event Filters & Activity Types
        ↓
Job Conditions (if:)
        ↓
Job Dependencies (needs)
        ↓
Environment Association (environment:)
        ↓
Job Executes
```

Each feature has a distinct responsibility.

| Feature                                          | Purpose                                                                                                                                                                                                                                               |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Workflow Trigger (`on:`)**                     | Determines **when** a workflow starts.                                                                                                                                                                                                                |
| **Event Filters & Activity Types**               | Determine **which events** are allowed to trigger the workflow.                                                                                                                                                                                       |
| **Job Conditions (`if:`)**                       | Determine **whether a particular job executes**.                                                                                                                                                                                                      |
| **Job Dependencies (`needs`)**                   | Control the execution order between jobs.                                                                                                                                                                                                             |
| **GitHub Actions Environments (`environment:`)** | Associate a job with an Environment, allowing GitHub to provide **Environment Variables**, **Environment Secrets**, **Deployment Protection Rules**, **Deployment History**, and other **environment-specific capabilities** before the job executes. |

Notice that **GitHub Actions Environments do not determine whether a workflow or job should execute**. They become relevant **only after GitHub has already decided to execute the job**.

For example, consider the following workflow:

```yaml
on:
  push:
    branches:
      - main

jobs:
  deploy:
    if: github.ref_name == 'main'
    environment: prod
```

GitHub evaluates the workflow in the following order:

```text
Push to main
        ↓
Workflow Trigger (on:)
        ↓
Evaluate Event Filters
        ↓
Evaluate Job Condition (if:)
        ↓
Associate Job with prod Environment
        ↓
Load Environment Configuration
        ↓
Evaluate Protection Rules
        ↓
Execute Job
```

> **Key Observation:** Think of these features as **complementary**, not competing. **`on:`** determines **when a workflow starts**, **Event Filters** determine **which events can trigger it**, **`if:`** determines **whether a job executes**, **`needs:`** determines **when a job executes relative to other jobs**, while **`environment:`** determines **which environment-specific configuration and controls are applied** before the job begins executing.

---


## Demo 1: Deploying an Application Using GitHub Actions Environments

In this demo, we will learn how **GitHub Actions Environments** help manage deployments across different environments by providing **environment-specific variables**, **environment-specific secrets**, and **deployment governance**.

To keep the demo simple, we will create two deployment environments:

* **dev**
* **prod**

Using the same workflow, we will deploy our application to either environment and observe how GitHub automatically provides the appropriate configuration and secrets based on the selected environment.

By the end of this demo, you will understand how GitHub Actions Environments help build deployment pipelines that are **more secure**, **easier to manage**, and **better aligned with production CI/CD practices**.

---

### Step 1: Repository Setup and Authentication

Before starting this demo, ensure that you already:

* have a GitHub repository created
* are authenticated with GitHub
* can push code successfully using Git

These concepts were covered extensively in **Lecture 01**.

* [Lecture 01 Video](https://youtu.be/w4c_NIjO3XI)
* [Lecture 01 GitHub Notes](https://github.com/CloudWithVarJosh/GitHub-Actions-Basics-To-Production/tree/main/01-GitHub-Actions)

For this lecture, we will use the following repository:

* **Repository Name:** `cwvj-gha-practice`
* **Visibility:** Private

> **Operational Note:** GitHub Actions workflows execute directly inside repositories. Whenever workflow YAML files are pushed into the repository, GitHub automatically discovers them and evaluates whether they should execute based on their configured workflow triggers.

---

### Step 2: Preparing the Application

Throughout this course, we have been using the same **containerized Flask application** to demonstrate various GitHub Actions concepts. We will continue using the same application in this lecture so that we can focus entirely on understanding **GitHub Actions Environments** rather than introducing a new application.

If you have already completed the previous lectures, you can simply reuse the existing project.

Otherwise, create the following directory structure:

```text
project-files/
├── app.py
├── Dockerfile
├── requirements.txt
└── .github/
    └── workflows/
        └── 01-environments-demo.yaml
```

---

#### Step 2.1: Create the Flask Application

Create the following Flask application:

**`app.py`**

```python
from flask import Flask, jsonify
import os

app = Flask(__name__)

print("Cloud With VarJosh Flask Application Started")


@app.get("/")
def home():
    print("Home endpoint invoked")

    return jsonify(
        message="Welcome to Cloud With VarJosh",
        platform="GitHub Actions",
        runtime="Docker + Flask"
    )


@app.get("/health")
def health():
    print("Health endpoint invoked")

    return jsonify(status="healthy"), 200


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", 5000))
    )
```

> **Note:** This is the same application that we have been using throughout this course. If you have been following the course sequentially, simply reuse the existing `app.py` file.

---

#### Step 2.2: Create the Dockerfile

Create the following Dockerfile:

**`Dockerfile`**

```dockerfile
FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

> **Note:** The Dockerfile remains unchanged from the previous lectures. If you have already created it, simply reuse the existing file.

---

#### Step 2.3: Create the Requirements File

Create the following dependency file:

**`requirements.txt`**

```text
flask==3.1.1
```

> **Note:** This is the same dependency file used throughout the course. Simply reuse the existing `requirements.txt` if you have already created it.


---

### Step 3: Preparing Docker Hub

Our workflow will build a Docker image and publish it to **Docker Hub**. Before that can happen, we need two things:

* a **Docker Hub Repository** to store the container images
* a **Docker Hub Personal Access Token (PAT)** to allow GitHub Actions to securely authenticate with Docker Hub

#### Step 3.1: Creating a Private Docker Hub Repository

Before the workflow can publish Docker images, we need a repository to store them.

Navigate to:

```text
Docker Hub
→ Repositories
→ Create Repository
```

Configure the repository using the following settings.

| Setting             | Value            |
| ------------------- | ---------------- |
| **Repository Name** | `cwvj-flask-app` |
| **Visibility**      | **Private**      |

Once created, the repository URL should resemble:

```text
docker.io/<your-dockerhub-username>/cwvj-flask-app
```

Later in this lecture, our workflow will publish Docker images to this repository using tags similar to:

```text
<your-dockerhub-username>/cwvj-flask-app:<git-commit-sha>
<your-dockerhub-username>/cwvj-flask-app:latest
```

> **Operational Note:** We are using a **private repository** because it more closely reflects how organizations manage container images in production. Private repositories help prevent unauthorized access and allow organizations to control who can **pull**, **push**, or **manage** container images.

---

#### Step 3.2: Creating a Docker Hub Personal Access Token (PAT)

We already know from previous lectures that:

* every GitHub Actions job executes on its own runner
* runners must authenticate with external systems whenever protected resources are accessed

In this demo, our workflow authenticates with **Docker Hub** before pushing the Docker image. Instead of using a Docker Hub account password, we will create a **Docker Hub Personal Access Token (PAT)**.

> **Important:** Never use your Docker Hub account password inside CI/CD workflows. Always authenticate using a **Personal Access Token (PAT)**.

Navigate to:

```text
Docker Hub → Profile Icon → Account Settings → Personal Access Tokens → Generate New Token
```

Configure the token as follows.

| Setting         | Value          |
| --------------- | -------------- |
| **Description** | `gha-demo`     |
| **Expiration**  | `1 Day`        |
| **Permissions** | `Read & Write` |

After creating the token:

* copy it immediately
* Docker Hub displays the token only once

We will configure this token as a **Repository Secret** in the next step.

> **Operational Note:** Docker Hub Personal Access Tokens are created at the **account level**. Any workflow, runner, or automation using the token inherits the permissions assigned to that token.

> **Production Insight:** Most organizations use **private container registries** such as **Amazon ECR**, **GitHub Container Registry (GHCR)**, **Azure Container Registry (ACR)**, **Google Artifact Registry (GAR)**, **JFrog Artifactory**, or **Harbor** instead of public repositories. Similarly, production environments typically avoid long-lived credentials by adopting **short-lived credentials**, **credential rotation**, **least-privilege access**, and **centralized secret management** to improve security and reduce operational risk.

---


### Step 4: Configuring Variables, Secrets, and GitHub Actions Environments

Before creating the workflow, we first need to configure the **Variables**, **Secrets**, and **GitHub Actions Environments** that the workflow will consume.

Throughout this demo, we will use two different configuration scopes:

* **Repository Variables & Secrets** for values common to the entire repository.
* **Environment Variables** for values that differ between deployment environments.

Later in this lecture, we will also see how **GitHub Actions Environments** provide much more than Variables and Secrets by enabling **Deployment Branch Restrictions**, **Required Reviewers**, **Wait Timers**, **Deployment History**, and other deployment governance capabilities.

Conceptually:

```text
Repository Variables & Secrets → Build Job (CI)
GitHub Actions Environments → Environment Variables → Deployment Jobs (CD)
```

---

#### Step 4.1: Creating Repository Variables and Secrets

The **Build Job** builds the Docker image and publishes it to Docker Hub. Since this activity is common to the entire repository and is independent of the deployment environment, we will configure these values at the **Repository** level.

Navigate to:

```text
Repository → Settings → Secrets and variables → Actions
```

Create the following **Repository Variable**.

| Variable             | Why                                                   |
| -------------------- | ----------------------------------------------------- |
| `DOCKERHUB_USERNAME` | Used by the Build Job while publishing Docker images. |

Next, create the following **Repository Secret**.

| Secret            | Why                                                             |
| ----------------- | --------------------------------------------------------------- |
| `DOCKERHUB_TOKEN` | Used by the Build Job to securely authenticate with Docker Hub. |

> **Why Repository Scope?** The Build Job is part of the **Continuous Integration (CI)** pipeline and executes before any deployment begins. Since the Docker image is built using the same Docker Hub account regardless of the target deployment environment, these values belong at the **Repository** scope rather than being duplicated across multiple Environments.

---

#### Step 4.2: Creating GitHub Actions Environments

Next, create the following **GitHub Actions Environments**:

```text
dev
prod
```

Although many organizations use additional environments such as **QA**, **UAT**, **Pre-Production**, or **Performance Testing**, the underlying concepts remain exactly the same. To keep this demo simple, we will use only **dev** and **prod**.

For each Environment, create the following **Variables**.

| Variable     | Dev               | Prod          | Why                                                                |
| ------------ | ----------------- | ------------- | ------------------------------------------------------------------ |
| `APP_URL`    | `app.dev.cwvj.io` | `app.cwvj.io` | Demonstrates environment-specific application configuration.       |
| `DEBUG_MODE` | `true`            | `false`       | Demonstrates how application behavior changes across environments. |

Notice that we are intentionally **not creating any Secrets** in this step.

At this stage of the lecture, we are using **GitHub Actions Environments** primarily to demonstrate **Variables** and how GitHub automatically injects different configuration values based on the associated Environment.

As we progressively enhance this workflow throughout the lecture, we will configure additional Environment capabilities, including:

* **Deployment Branch Restrictions**
* **Required Reviewers**
* **Wait Timers**
* **Deployment History**
* **Deployment Protection Rules**

This incremental approach allows us to understand one capability at a time while observing how each enhancement changes the deployment behavior without requiring major changes to the workflow YAML.

---

> **Production Insight:** GitHub Actions provides multiple scopes for storing configuration and sensitive information. Choosing the appropriate scope helps keep CI/CD pipelines secure, reusable, and easier to manage.

| Scope                                | Typical Use Cases                                                                                                  |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| **Workflow (`env`)**                 | Temporary values used only within a workflow or job.                                                               |
| **Repository Variables & Secrets**   | Values common to the repository, such as container registry credentials, cloud regions, or reusable configuration. |
| **Organization Variables & Secrets** | Values shared across multiple repositories within an organization.                                                 |
| **Environment Variables & Secrets**  | Configuration and credentials specific to deployment environments such as Development, Staging, and Production.    |

If the same **Variable** or **Secret** exists at multiple scopes, GitHub automatically resolves the value from the **most specific scope**. For deployment jobs associated with a **GitHub Actions Environment**, **Environment Variables** and **Environment Secrets** take precedence over their **Repository** and **Organization** counterparts. This allows organizations to define common defaults at broader scopes while overriding only the values that differ for specific deployment environments.

> **Key Observation:** It is tempting to think of **GitHub Actions Environments** as simply another place to store Variables and Secrets. In reality, **Variables and Secrets are only one capability they provide**. Their primary purpose is **deployment governance**, enabling organizations to enforce **environment-specific configuration**, **Deployment Branch Restrictions**, **Required Reviewers**, **Wait Timers**, **Deployment Protection Rules**, **Deployment History**, and other controls that make deployments **secure**, **controlled**, and **auditable**. Throughout the remainder of this lecture, we will progressively configure these capabilities and observe how GitHub changes the deployment behavior while the workflow itself remains largely unchanged.

---

### Step 5: Creating the Workflow

Create the following workflow file.

**`.github/workflows/01-environments-demo.yaml`**

```yaml
name: 01 - GitHub Actions Environments Demo

on:
  push:
    branches:
      - "feature/**"
      - develop
      - main

jobs:
  build-job:
    name: Build & Publish Image
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Login to Docker Hub
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build & Push Docker Image
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: |
            ${{ vars.DOCKERHUB_USERNAME }}/cwvj-flask-app:${{ github.sha }}
            ${{ vars.DOCKERHUB_USERNAME }}/cwvj-flask-app:latest

  deploy-dev-job:
    name: Deploy to Development
    if: github.ref_name == 'develop'
    needs: build-job
    runs-on: ubuntu-latest
    environment: dev

    steps:
      - name: Display Branch Information
        run: |
          echo "Branch : ${{ github.ref_name }}"

      - name: Display Environment Configuration
        run: |
          echo "Application URL : ${{ vars.APP_URL }}"
          echo "Debug Mode      : ${{ vars.DEBUG_MODE }}"

      - name: Login to Docker Hub
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Run Container
        run: |
          docker run -d \
            -p 5000:5000 \
            --name cwvj-flask-container \
            ${{ vars.DOCKERHUB_USERNAME }}/cwvj-flask-app:${{ github.sha }}

      - name: Smoke Test Application
        run: |
          sleep 5
          curl --fail http://127.0.0.1:5000/
          curl --fail http://127.0.0.1:5000/health

      - name: Display Container Logs
        run: docker logs cwvj-flask-container

  deploy-prod-job:
    name: Deploy to Production
    if: github.ref_name == 'main'
    needs: build-job
    runs-on: ubuntu-latest
    environment: prod

    steps:
      - name: Display Branch Information
        run: |
          echo "Branch : ${{ github.ref_name }}"

      - name: Display Environment Configuration
        run: |
          echo "Application URL : ${{ vars.APP_URL }}"
          echo "Debug Mode      : ${{ vars.DEBUG_MODE }}"

      - name: Login to Docker Hub
        uses: docker/login-action@v4
        with:
          username: ${{ vars.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Run Container
        run: |
          docker run -d \
            -p 5000:5000 \
            --name cwvj-flask-container \
            ${{ vars.DOCKERHUB_USERNAME }}/cwvj-flask-app:${{ github.sha }}

      - name: Smoke Test Application
        run: |
          sleep 5
          curl --fail http://127.0.0.1:5000/
          curl --fail http://127.0.0.1:5000/health

      - name: Display Container Logs
        run: docker logs cwvj-flask-container
```

---

#### Explanation

---

```yaml
name: 01 - GitHub Actions Environments Demo
```

* This block defines the **workflow name** displayed in the **GitHub Actions UI**. We have discussed this in previous lectures, and it simply helps identify workflow runs.

---

```yaml
on:
  push:
    branches:
      - "feature/**"
      - develop
      - main
```

This block configures the workflow to execute automatically whenever code is pushed to one of the configured branches.

In this demo, we intentionally use three different branch patterns because they represent a simplified version of a typical software delivery lifecycle.

```text
feature/** → Continuous Integration (CI)
develop    → Continuous Delivery (Development)
main       → Continuous Delivery (Production)
```

Feature branches execute only the **Build & Publish** stage, allowing developers to continuously validate their changes without deploying the application.

Pushes to **develop** and **main** execute the same build process followed by deployment to their respective environments.

Conceptually:

```text
feature/* ─────────► Build & Publish Image
develop ───────────► Build & Publish Image ─────► Deploy to Development
main ──────────────► Build & Publish Image ─────► Deploy to Production
```

Although this demo rebuilds the application whenever code is pushed to the **develop** or **main** branches, this is done intentionally to keep the workflow simple and focused on **GitHub Actions Environments**.

In many enterprise CI/CD pipelines, organizations instead follow the **Build Once, Deploy Many** principle. The application is built only once, producing an **immutable artifact** (for example, a **container image**, **JAR**, **WAR**, or **ZIP package**). Rather than rebuilding the application for every deployment environment, the **same artifact** is progressively promoted across **Development**, **Staging**, and **Production**.

Conceptually:

```text
Commit Code → Build Once → Publish Artifact → Deploy to Development → Promote Same Artifact → Deploy to Staging → Promote Same Artifact → Deploy to Production
```

The promotion itself can be implemented in several ways depending on the organization's CI/CD platform and release process. Common approaches include:

* **Triggering downstream deployment workflows** that consume the previously built artifact.
* **Retrieving the same artifact** (container image or application package) from an artifact repository such as **Amazon ECR**, **GitHub Container Registry (GHCR)**, **JFrog Artifactory**, **Sonatype Nexus Repository**, or similar repositories.
* **Promoting container images** by referencing the **same immutable image digest (`sha256:...`)** across successive deployment environments. Some organizations also apply environment-specific tags (for example, **`dev`**, **`staging`**, and **`prod`**) for convenience, but the deployment itself is typically performed using the **image digest** to guarantee that the exact same image is deployed everywhere.
* **Promoting application packages** (such as **JAR**, **WAR**, or **ZIP** files) through successive deployment environments without rebuilding them.

The underlying principle remains the same: **the application is built only once**, and the **same immutable artifact** is promoted through successive deployment environments. Whether that artifact is referenced by an **image digest** (for containerized applications) or by the **same application package** (for traditional deployments), the artifact itself is never rebuilt. This ensures that the exact artifact validated in lower environments is ultimately deployed to **Production**, reducing deployment risk, improving traceability, and ensuring release consistency.

> **Production Insight:** Different organizations follow different branching strategies, such as **GitHub Flow**, **Git Flow**, or **Trunk-Based Development**. Regardless of the branching model, the overall principle remains the same: **CI typically executes for every code change, while deployments are usually limited to selected branches that represent promotable application versions.** Mature CI/CD pipelines also strive to **build once and promote the same immutable artifact** across environments, reducing deployment risk and ensuring that the exact artifact tested in lower environments is ultimately deployed to Production.

---

```yaml
jobs:
  build-job:
```

This job represents the **Continuous Integration (CI)** portion of the pipeline. Its responsibility is to **build the application**, **containerize it**, and **publish the Docker image**.

Notice that this job is **not associated with any GitHub Actions Environment**. This is intentional because the purpose of the Build Job is to generate a reusable deployment artifact, not to deploy the application.

Conceptually:

```text
Source Code → Build Application → Build Docker Image → Publish Docker Image
```

Earlier in this lecture, we saw that this workflow **builds the application whenever code is pushed** to the **feature**, **develop**, or **main** branches. This design keeps the demo simple and allows us to focus on **GitHub Actions Environments**.

However, in many enterprise CI/CD pipelines, the build stage is often separated from the deployment stage. Instead of rebuilding the application for every deployment branch, organizations typically **build the application only once**, publish the generated artifact, and then **promote the same immutable artifact** across successive deployment environments.

> **Key Observation:** In this demo, **"Build Once" refers to the architectural principle followed by mature CI/CD pipelines, not the implementation of this workflow.** Our workflow intentionally rebuilds the application on each push for simplicity, whereas production pipelines commonly separate **artifact creation** from **artifact promotion**, ensuring that the exact artifact validated in lower environments is ultimately deployed to **Production**.

---

```yaml
username: ${{ vars.DOCKERHUB_USERNAME }}
password: ${{ secrets.DOCKERHUB_TOKEN }}
```

Notice that the DockerHub credentials are retrieved using:

```text
vars
secrets
```

However, these values are **not coming from a GitHub Actions Environment**.

Instead, they are stored as:

* **Repository Variable**
* **Repository Secret**

under:

```text
Repository → Settings → Secrets and variables → Actions
```

This design is intentional.

The **Build Job** performs a repository-wide CI activity that is independent of any deployment environment. Regardless of whether the application is later deployed to **Development**, **Staging**, or **Production**, the Docker image is built and published only once.

Since the same DockerHub credentials are required irrespective of the deployment target, storing them at the **Repository** level is more appropriate than duplicating them across multiple Environments.

> **Production Insight:** Repository Variables and Repository Secrets are commonly used for values shared across the entire repository, such as **container registry credentials**, **cloud regions**, **artifact repository URLs**, or other configuration that does not vary between deployment environments.

---

```yaml
tags:
  - ${{ vars.DOCKERHUB_USERNAME }}/cwvj-flask-app:${{ github.sha }}
  - ${{ vars.DOCKERHUB_USERNAME }}/cwvj-flask-app:latest
```

* This step builds the Docker image and pushes it to DockerHub.
* We have already discussed image building extensively in previous lectures, so the important point here is the image tagging strategy.

Two image tags are created:

* **`${{ github.sha }}`**, an immutable tag uniquely identifying the Git commit.
* **`latest`**, a convenience tag referencing the most recent image.

Using the Git Commit SHA allows every image to be traced back to the exact source code revision from which it was built.

---

```yaml
deploy-dev-job:
```

and

```yaml
deploy-prod-job:
```

These jobs represent the **Continuous Delivery (CD)** portion of the pipeline.

Unlike the Build Job, these jobs are responsible for deploying the previously generated artifact into specific deployment environments.

Notice that each deployment job executes only for its corresponding branch.

```yaml
if: github.ref_name == 'develop'
```

```yaml
if: github.ref_name == 'main'
```

The **`if`** keyword defines a **conditional expression** that determines whether GitHub should execute the job.

Conceptually:

```text
Push to feature/* → Build Only
Push to develop → Build + Deploy Development
Push to main → Build + Deploy Production
```

> **Key Observation:** GitHub evaluates the **`if`** condition **before** provisioning a runner. If the condition evaluates to **false**, the entire job is skipped.

---

```yaml
needs: build-job
```

We discussed **Job Dependencies** in previous lectures. This configuration instructs GitHub that both deployment jobs must wait until the **Build Job** completes successfully before they begin execution.

Conceptually:

```text
Build Job → Deploy to Development
Build Job → Deploy to Production
```

This guarantees that deployments occur only after the application has been successfully **built** and the Docker image has been successfully **published**, ensuring that deployment jobs always consume a valid deployment artifact.

---

```yaml
environment: dev
```

and

```yaml
environment: prod
```

This is the **most important configuration** in this entire lecture.

Unlike the **Build Job**, which is environment-agnostic, these deployment jobs are explicitly associated with a **GitHub Actions Environment**. As soon as GitHub encounters the `environment` keyword, it performs additional processing before executing the deployment.

Conceptually:

```text
Deploy Job → Locate Environment → Load Environment Configuration → Evaluate Protection Rules → Start Deployment
```

By associating a job with an Environment, GitHub can automatically:

* load **Environment Variables**
* load **Environment Secrets**
* evaluate **Deployment Protection Rules**
* record **Deployment History**
* enforce **deployment governance** before allowing the deployment to proceed

Notice that **the workflow logic itself remains unchanged**. Both deployment jobs execute the same sequence of steps, while the behavior changes based on the associated **GitHub Actions Environment**.

For example:

```text
Deploy to Development → Load dev Variables & Secrets → Apply dev Rules → Execute Deployment
Deploy to Production → Load prod Variables & Secrets → Apply prod Rules → Execute Deployment
```

> **Key Observation:** Simply changing **`environment: dev`** to **`environment: prod`** does far more than switch configuration values. It instructs GitHub to associate the job with a different **GitHub Actions Environment**, automatically applying that environment's **Variables**, **Secrets**, **Protection Rules**, **Deployment History**, and other governance controls. This is what makes **GitHub Actions Environments** a **deployment governance** feature rather than simply another place to store Variables and Secrets.

> **Key Observation 2:** The **`if` condition** and **Deployment Branch Restrictions** solve different problems. The **`if` condition** controls **whether a job executes**, while **Deployment Branch Restrictions** control **whether that job is allowed to use a particular GitHub Actions Environment**, including its **Environment Variables**, **Environment Secrets**, **Protection Rules**, and other environment-specific capabilities. Environment protection therefore acts as an additional layer of governance, independent of the workflow logic.

---

```yaml
- name: Display Environment Configuration
  run: |
    echo "Application URL : ${{ vars.APP_URL }}"
    echo "Debug Mode      : ${{ vars.DEBUG_MODE }}"
```

Unlike the DockerHub credentials used during the **Build Job**, these values are retrieved from the associated **GitHub Actions Environment**.

Earlier in this demo, we configured the following Environment Variables:

| Environment | APP_URL           | DEBUG_MODE |
| ----------- | ----------------- | ---------- |
| **dev**     | `app.dev.cwvj.io` | `true`     |
| **prod**    | `app.cwvj.io`     | `false`    |

GitHub automatically injects the appropriate values based on the Environment associated with the deployment job.

Conceptually:

```text
Deploy to Development → APP_URL = app.dev.cwvj.io, DEBUG_MODE = true
Deploy to Production → APP_URL = app.cwvj.io, DEBUG_MODE = false
```

Notice that the workflow contains **no environment-specific conditional logic** to determine which values should be used. The deployment steps remain identical for both environments, while GitHub automatically injects the appropriate **Variables** before the job begins execution.

> **Key Observation:** The workflow remains exactly the same regardless of the deployment target. Only the **Environment Variables** injected by GitHub change based on the associated **GitHub Actions Environment**. This separation of **deployment logic** from **environment-specific configuration** is one of the key benefits of using GitHub Actions Environments.

---

```yaml
- name: Login to Docker Hub
  uses: docker/login-action@v4
```

Although we already authenticated with Docker Hub in the **Build Job**, we must authenticate again before the deployment job can pull the Docker image.

This is because **every GitHub-hosted job executes on its own fresh, ephemeral runner**. Once the Build Job completes, its runner is destroyed along with any local Docker images, authentication sessions, and temporary files.

Conceptually:

```text
Build Job → Runner A → Login → Build & Push Image → Runner Destroyed
Deploy Job → Runner B → Login → Pull Image → Run Container
```

Since the deployment job executes on a **different runner**, it must establish a new authenticated session with Docker Hub before it can pull the **private Docker image**.

Notice that the deployment job is associated with a **GitHub Actions Environment**, yet the following values:

```yaml
username: ${{ vars.DOCKERHUB_USERNAME }}
password: ${{ secrets.DOCKERHUB_TOKEN }}
```

are retrieved from the **Repository Variable** and **Repository Secret** that we configured earlier. This demonstrates that associating a job with a **GitHub Actions Environment** does **not** restrict the job to using only **Environment Variables** and **Environment Secrets**. Instead, the job can access **Repository**, **Environment**, and, where applicable, **Organization** Variables and Secrets.

When the same Variable or Secret exists at multiple scopes, GitHub automatically resolves the value from the **most specific scope**, giving **Environment** precedence over **Repository**, and **Repository** precedence over **Organization**.

> **Key Observation:** Authentication performed in one GitHub Actions job is **not shared** with subsequent jobs because each job executes on its own fresh runner. Likewise, defining **`environment: dev`** or **`environment: prod`** does **not** replace Repository or Organization Variables and Secrets, it simply adds another, higher-precedence configuration scope for the deployment job.

> **Important:** GitHub allows a Variable or Secret with the same name to exist at multiple scopes. When this happens, GitHub automatically resolves the value from the **most specific scope**. For **Configuration Variables (`vars`)** and **Secrets**, the precedence is:
>
> ```text
> Environment
>       ↓
> Repository
>       ↓
> Organization
> ```
>
> For example, if **`APP_URL`** is defined in both the **Repository** and the **dev Environment**, a deployment job associated with **`environment: dev`** automatically uses the **Environment Variable**, while the Repository Variable acts as the default. This allows organizations to define common configuration at the Repository or Organization level and override only the values that differ for specific deployment environments. 

---

```yaml
- name: Run Container
  run: |
    docker run -d \
      -p 5000:5000 \
      --name cwvj-flask-container \
      ${{ vars.DOCKERHUB_USERNAME }}/cwvj-flask-app:${{ github.sha }}
```

This step starts the Flask application inside a Docker container using the **Docker image published by the Build Job**. Since the image is hosted in a **private Docker Hub repository**, Docker automatically pulls it from Docker Hub before starting the container if it is not already present on the runner.

We have already covered Docker image execution in previous lectures, so we simply reuse the same approach here.

> **Key Observation:** The deployment job does **not** rebuild the application. Instead, it retrieves the previously published Docker image and runs it. This separation of **building** and **deploying** reflects how modern CI/CD pipelines decouple artifact creation from artifact consumption.

---



```yaml
curl --fail ...
```

These commands perform a simple **Smoke Test** by validating both the application endpoint and the health endpoint.

We previously discussed the significance of the **`--fail`** flag. If either endpoint returns an HTTP error response (4xx or 5xx), **`curl`** exits with a non-zero exit code, causing the workflow step to fail immediately.

---

```yaml
docker logs cwvj-flask-container
```

Finally, we display the application logs generated by the running container.

This confirms that:

* the container started successfully
* the application processed incoming requests
* the smoke tests executed successfully

Reviewing application logs after deployment is a common production practice because they often provide the first indication of startup failures, configuration issues, or runtime errors.

---

### Step 6: Commit and Push the Changes

Commit the workflow and push it to GitHub.

```bash
# Initialize a new Git repository (one-time setup)
git init

# Rename the default branch to main (required only if your local Git still uses 'master')
git branch -M main

# Add all application, workflow, and configuration changes to the Git staging area
git add .

# Create a commit containing the GitHub Actions Environments demo implementation
git commit -m "feat: add github actions environments demo"

# Associate the local repository with the remote GitHub repository (one-time setup)
git remote add origin git@github.com:CloudWithVarJosh/cwvj-gha-practice.git

# Push the main branch and configure it to track the remote branch
git push -u origin main

# Create and switch to the develop branch
git checkout -b develop

# Push the develop branch and configure it to track the remote branch
git push -u origin develop
```

Unlike our previous demos, this workflow is configured with the **`push`** event.

```yaml
on:
  push:
    branches:
      - "feature/**"
      - develop
      - main
```

As soon as the code is pushed, GitHub automatically discovers the workflow and begins executing it.

Navigate to:

```text
GitHub Repository → Actions → 01 - GitHub Actions Environments Demo
```

You should now see a new workflow run in progress.


> **Production Insight:** While this demo uses direct **pushes** to the **develop** and **main** branches for simplicity, enterprise CI/CD pipelines typically follow a more controlled release process. Long-lived branches such as **develop**, **staging**, **release**, or **main** are often **protected branches**, preventing direct pushes. Developers usually commit their changes to **feature branches**, raise **Pull Requests**, and, after code reviews and automated validation, the changes are merged into the appropriate long-lived branch. The merge event then triggers the corresponding CI/CD pipeline. The exact branching strategy and branch names (for example, **develop**, **staging**, **release**, or **main**) vary across organizations and are typically defined by the **Application Architect**, **DevOps Architect**, or the organization's software delivery standards.

---

### Step 7: Running the Workflow

After executing the Git commands from the previous step, GitHub automatically triggers **two workflow runs**.

The first workflow run is triggered when the code is pushed to the **main** branch, while the second workflow run is triggered after creating and pushing the **develop** branch.

Recall the workflow trigger:

```yaml
on:
  push:
    branches:
      - "feature/**"
      - develop
      - main
```

Navigate to:

```text
GitHub Repository → Actions → 01 - GitHub Actions Environments Demo
```

You should now see **two completed workflow runs**, one corresponding to the **main** branch and the other to the **develop** branch.

Before opening either workflow run, let's predict what should happen.
The Build Job executes for every configured branch because every code change must first be built and published as a Docker image.

The deployment jobs, however, are controlled using the **`if`** keyword.

```yaml
if: github.ref_name == 'develop'
```

```yaml
if: github.ref_name == 'main'
```

Therefore, GitHub evaluates the jobs as follows:

```text
Push to main → Build Job ✓ → Deploy to Development ✗ → Deploy to Production ✓

Push to develop → Build Job ✓ → Deploy to Development ✓ → Deploy to Production ✗
```

Open both workflow runs and compare their execution graphs.

Although both runs execute the **Build Job**, only one deployment job executes in each workflow because GitHub evaluates the **`if`** condition before scheduling a job for execution.

> **Key Observation:** The workflow definition remains exactly the same. The only difference between the two executions is the branch that triggered the workflow, causing GitHub to execute a different deployment job.

---

### Step 8: Observing Workflow Execution

Begin by opening the workflow run triggered from the **main** branch.

You should observe the following execution order:

```text
Build Job → Deploy to Production
```

Next, open the workflow run triggered from the **develop** branch.

This time, the execution order changes to:

```text
Build Job → Deploy to Development
```

Notice that **both workflow runs execute the same Build Job**.

This job:

* checks out the repository
* authenticates with Docker Hub
* builds the Docker image
* publishes the Docker image

More importantly, notice that the Build Job is **not associated with any GitHub Actions Environment**.

Instead, it retrieves the DockerHub credentials from the **Repository Variable** and **Repository Secret** that we configured earlier.

This is intentional because the Build Job performs a **Continuous Integration (CI)** activity that is common to the entire repository.

Once the Build Job completes successfully, GitHub executes the appropriate deployment job based on the branch that triggered the workflow.

This dependency is defined using:

```yaml
needs: build-job
```

When the deployment job begins, GitHub encounters either:

```yaml
environment: dev
```

or

```yaml
environment: prod
```

Before executing any deployment steps, GitHub associates the job with the corresponding **GitHub Actions Environment**.

Conceptually:

```text
Deploy Job → Locate GitHub Actions Environment → Load Environment Variables → Evaluate Protection Rules → Start Deployment
```

Now inspect the **Display Environment Configuration** step in both workflow runs.

For the **develop** branch, the output should resemble:

```text
Branch          : develop
Application URL : app.dev.cwvj.io
Debug Mode      : true
```

For the **main** branch, the output changes to:

```text
Branch          : main
Application URL : app.cwvj.io
Debug Mode      : false
```

Notice that **APP_URL** and **DEBUG_MODE** are **not hardcoded** anywhere inside the workflow. The workflow logic remains identical in both executions, while GitHub automatically injects the appropriate **Environment Variables** based on the associated **GitHub Actions Environment**.

Continue inspecting the remaining deployment steps.

```text
Display Environment Configuration → Run Container → Smoke Test Application → Display Container Logs
```

Finally, inspect the **Container Logs** step.

You should observe output similar to:

```text
Cloud With VarJosh Flask Application Started
Home endpoint invoked
Health endpoint invoked
```

This confirms that:

* the container started successfully
* the smoke tests completed successfully
* the deployment completed successfully

Compare the two workflow runs one final time.

Conceptually:

```text
Same Workflow YAML
        │
        ├── Push to develop → Build Job → Deploy to Development → dev Environment
        │
        └── Push to main → Build Job → Deploy to Production → prod Environment
```

Notice that **not a single line of workflow YAML changed**. The only difference between the two executions was the branch that triggered the workflow. GitHub automatically selected the appropriate deployment job, associated it with the corresponding **GitHub Actions Environment**, injected the correct **Environment Variables**, and applied the configured deployment governance.

> **Key Observation:** This is one of the biggest advantages of **GitHub Actions Environments**. Organizations typically maintain a **single deployment workflow** while allowing GitHub to automatically supply the appropriate configuration and governance based on the target deployment environment.

> **Try This:** Modify the **`APP_URL`** variable inside the **dev** Environment and push another commit to the **develop** branch. Observe that the workflow immediately begins using the updated value without requiring any changes to the workflow YAML. This demonstrates how **deployment configuration remains completely decoupled from deployment logic**, making CI/CD pipelines easier to maintain and significantly reducing configuration-related deployment errors.

---

## Demo 2: Enhancing Our Deployment Pipeline

So far, we have explored the core concepts of **GitHub Actions Environments** by using **Environment Variables** and **Environment Secrets**. However, as discussed in the theory section, Environments provide much more than just configuration management. They also enable organizations to implement **deployment governance**, ensuring that deployments occur only under the appropriate conditions.

In this section, we will enhance our deployment pipeline by implementing the following capabilities:

1. **Deployment Branch Restrictions**
2. **Required Reviewers**
3. **Wait Timer**
4. **Deployment History**

Notice that throughout these enhancements, the workflow YAML remains almost unchanged. Instead, we enhance the deployment process by configuring the associated **GitHub Actions Environments**.

---

### Enhancement 1: Deployment Branch Restrictions

The first enhancement we will implement is **Deployment Branch Restrictions**.

Earlier in this lecture, our deployment jobs referenced the following environments:

```yaml
environment: dev
```

and

```yaml
environment: prod
```

At this point, any branch capable of reaching these deployment jobs could deploy to the associated environment.

To introduce deployment governance, configure the following branch restrictions.

```text
dev → Selected Branches → develop
prod → Selected Branches → main
```

This tells GitHub that:

* only the **develop** branch is allowed to deploy to the **dev** Environment.
* only the **main** branch is allowed to deploy to the **prod** Environment.

Conceptually:

```text
develop ─────────────► dev Environment ✓

main ────────────────► prod Environment ✓

feature/* ───────────► prod Environment ✗
feature/* ───────────► dev Environment ✗
```

Whenever a deployment job references an Environment, GitHub first evaluates the configured deployment rules before allowing the deployment to continue.

Conceptually:

```text
Deployment Job
        ↓
Locate Environment
        ↓
Evaluate Deployment Rules
        ↓
Allowed?
      ↙      ↘
    Yes      No
     ↓        ↓
Load Environment   Block Deployment
Configuration
```

Notice that the deployment restriction is applied to the **Environment**, not to individual Variables or Secrets.

If GitHub determines that the deployment is not permitted, the deployment job never associates with the Environment, meaning its **Environment Variables**, **Environment Secrets**, and other Environment-specific capabilities are never made available.

> **Key Observation:** Deployment Branch Restrictions protect the **Environment** itself. They ensure that only approved branches are permitted to deploy to that Environment, regardless of how the workflow is written.

---

### Enhancement 2: Exploring Additional Deployment Protection Rules

After configuring Deployment Branch Restrictions, you may notice that no additional deployment protection options are available.

This is because, throughout this course, we have intentionally been using:

* a **GitHub Free** personal account
* a **private repository**

GitHub currently exposes only a subset of Environment capabilities under this configuration.

However, GitHub Actions Environments support several additional deployment governance features, including:

* Required Reviewers
* Wait Timers
* Custom Deployment Protection Rules
* Administrator Bypass

To demonstrate these capabilities, we will temporarily change the repository visibility from **Private** to **Public**.

Since this repository contains only demonstration code, making it public for the purpose of this lecture is perfectly acceptable.

In production environments, repositories typically remain **private**, and organizations choose an appropriate GitHub plan based on their governance, security, and compliance requirements.

After changing the repository visibility to **Public**, refresh the Environment configuration page.

You should now see additional deployment protection options similar to the following:

```text
Required Reviewers
Wait Timer
Custom Deployment Rules
Administrator Bypass
```

> **Production Insight:** **Repository visibility and GitHub plan directly determine which GitHub Actions Environment features are available.** Before deciding to upgrade from **GitHub Free** to **GitHub Team** or **GitHub Enterprise**, or before changing a repository from **Private** to **Public**, always evaluate the **complete feature set** offered by each GitHub plan rather than focusing on a single capability such as **GitHub Actions Environments**. Features related to **security**, **repository rules**, **code owners**, **audit logs**, **advanced compliance**, **identity management**, **GitHub Advanced Security**, and **CI/CD governance** often provide significantly more value to organizations than any individual feature in isolation.

---

### Enhancement 3: Required Reviewers and Wait Timer

Now let's configure two additional deployment governance capabilities for the **prod** Environment.

Configure the following settings:

```text
prod → Required Reviewers → CloudWithVarJosh
prod → Wait Timer → 1 Minute
```

The **Required Reviewers** feature introduces a **manual approval gate** before a deployment is allowed to proceed. Rather than immediately deploying to Production, GitHub pauses the workflow and waits for an authorized reviewer to either approve or reject the deployment.

Conceptually:

```text
Build Job → Deploy to Production → Waiting for Approval → Reviewer Approves → Continue Deployment
```

This ensures that sensitive environments such as **Production** cannot be deployed automatically without human oversight. In many organizations, Production deployments require approval from **Technical Leads**, **Release Managers**, **Platform Teams**, or members of the **Change Advisory Board (CAB)** before deployment is permitted.

Next, configure a **Wait Timer** of **1 minute**. Once the deployment receives approval, GitHub waits for the configured duration before allowing the deployment to proceed.

Conceptually:

```text
Approval Received → Wait 1 Minute → Start Deployment
```

Although our demo uses a **1-minute** wait timer, production environments often configure significantly longer delays for several operational reasons:

* **Change Management & Maintenance Windows:** Many organizations permit Production deployments only during **approved maintenance windows** or after receiving final **change management approvals**. Wait timers help ensure that deployments begin within the approved release window without requiring engineers to manually start the deployment.

* **Operational Coordination:** Large production deployments often involve multiple teams, including **operations**, **platform**, **database**, **network**, and **application support** teams. The delay provides time to complete deployment prerequisites, coordinate release activities, and confirm that all participating teams are ready before the deployment proceeds.

* **Cancellation Window:** A wait timer also provides a short window to **pause or cancel** a scheduled deployment if new issues are discovered after the pipeline completes, such as a critical production incident, a failed dependency deployment, or a last-minute business decision to postpone the release.


> **Key Observation:** Both **Required Reviewers** and **Wait Timers** are configured entirely within the associated **GitHub Actions Environment**. The workflow YAML remains unchanged, demonstrating how GitHub Actions Environments add **deployment governance** without increasing workflow complexity.

---

### Validating the Enhanced Deployment

Now that we have enhanced the **prod** Environment, let's execute the workflow and observe how GitHub automatically enforces the configured deployment governance.

To trigger a new workflow execution, make a small change to the workflow, for example, update the workflow name:

```yaml
name: 01 - GitHub Actions Environments Demo (Enhanced)
```

Commit the change and push it to the **main** branch.

```bash
git add .
git commit -m "feat: demonstrate deployment governance"
git push origin main
```

Since the workflow is configured to execute on pushes to the **main** branch, GitHub automatically starts a new workflow run.

This time, however, the deployment behaves differently because of the additional protection rules configured for the **prod** Environment.

Conceptually:

```text
Push to main → Build & Publish Image → Deploy to Production → Required Reviewer Approval → Wait Timer → Load Environment Configuration → Execute Deployment → Record Deployment History
```

When the deployment reaches the **Deploy to Production** job, GitHub pauses the workflow and displays a pending deployment request.

Open the pending deployment, optionally provide a review comment, and click:

```text
Approve and Deploy
```

After the deployment is approved, GitHub automatically waits for the configured **Wait Timer** before resuming the deployment.

Once the deployment completes successfully, navigate to the **Deployments** section of the repository (or the **prod** Environment) to view the recorded deployment.

The deployment history includes information such as:

* **Deployment Status**, indicating whether the deployment succeeded or failed.
* **Target Environment**, showing where the application was deployed.
* **Commit**, identifying the application version that was deployed.
* **Actor**, showing who initiated and approved the deployment.
* **Deployment Time**, providing an audit trail of when the deployment occurred.

This centralized deployment history makes it easy to answer operational questions such as:

* Who deployed this version?
* Which commit was deployed?
* When was the deployment performed?
* Was the deployment successful?

> **Final Observation:** Throughout this section, we transformed a simple deployment pipeline into a governed deployment process without significantly changing the workflow YAML. Instead, we configured the associated **GitHub Actions Environments** to enforce deployment governance through **Branch Restrictions**, **Required Reviewers**, **Wait Timers**, and **Deployment History**. This separation of **deployment logic** from **deployment governance** is one of the most powerful capabilities provided by GitHub Actions Environments.

---

## Conclusion

In this lecture, we explored **GitHub Actions Environments** and learned that they are far more than simply another location for storing Variables and Secrets.

We first understood the operational challenges encountered in enterprise deployment pipelines, including **environment-specific configuration**, **environment-specific secrets**, **deployment approvals**, **deployment protection**, **deployment tracking**, and **deployment governance**.

We then built a complete deployment pipeline that demonstrated how GitHub Actions Environments automatically inject **Environment Variables** and apply **environment-specific configuration** while keeping the deployment workflow simple and reusable.

Finally, we enhanced the same deployment pipeline by configuring **Deployment Branch Restrictions**, **Required Reviewers**, **Wait Timers**, and **Deployment History**, illustrating how organizations progressively introduce deployment governance without significantly increasing workflow complexity.

The key takeaway from this lecture is that **GitHub Actions Environments separate deployment logic from deployment governance**. Your workflow continues to describe *how* an application is deployed, while GitHub Actions Environments determine **when**, **where**, and **under what conditions** that deployment is allowed to proceed.

This separation enables organizations to build deployment pipelines that are **more secure**, **more maintainable**, and **better aligned with enterprise software delivery practices**.

---

## References

The following resources provide additional information about GitHub Actions Environments, deployment governance, GitHub licensing, and related concepts.

- GitHub Actions Environments  
  https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment

- Deployments and Environments  
  https://docs.github.com/actions/reference/workflows-and-actions/deployments-and-environments

- Configuration Variables  
  https://docs.github.com/actions/learn-github-actions/variables

- GitHub Secrets  
  https://docs.github.com/actions/security-guides/encrypted-secrets

- GitHub Contexts  
  https://docs.github.com/actions/learn-github-actions/contexts

- GitHub Expressions  
  https://docs.github.com/actions/learn-github-actions/expressions

- Workflow Syntax for GitHub Actions  
  https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions

- GitHub Pricing  
  https://github.com/pricing

- GitHub Plans  
  https://docs.github.com/get-started/learning-about-github/githubs-plans

**Docker Documentation**

- Docker Hub Personal Access Tokens  
  https://docs.docker.com/security/access-tokens/

- Docker Hub Documentation  
  https://docs.docker.com/docker-hub/

- Docker CLI Reference  
  https://docs.docker.com/reference/cli/docker/
