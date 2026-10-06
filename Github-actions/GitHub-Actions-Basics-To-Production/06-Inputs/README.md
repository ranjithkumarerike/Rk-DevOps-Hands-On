# GitHub Actions Inputs Explained | Workflow Inputs, Reusable Workflows & Production Use Cases

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/fLZRgNhQq3w/maxresdefault.jpg)](https://youtu.be/fLZRgNhQq3w)

---

## ⭐ Support the Project  

If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

* [Introduction](#introduction)  
* [What are Inputs?](#what-are-inputs)  
* [Types of Inputs](#types-of-inputs)  
  * [Type 1: Workflow Inputs](#type-1-workflow-inputs)  
  * [Type 2: Reusable Workflow Inputs](#type-2-reusable-workflow-inputs)  
  * [Type 3: Action Inputs](#type-3-action-inputs)  
* [**Demo 1:** Building an Environment-Aware CI Pipeline Using Workflow Inputs](#demo-1-building-an-environment-aware-ci-pipeline-using-workflow-inputs)  
  * [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication)  
  - [Step 2: Preparing the Application and Supporting Components](#step-2-preparing-the-application-and-supporting-components)  
    - [Step 2.1: Create a Private DockerHub Repository](#step-21-create-a-private-dockerhub-repository)  
    - [Step 2.2: Create a DockerHub Access Token](#step-22-create-a-dockerhub-access-token)  
    - [Step 2.3: Store DockerHub Credentials in GitHub Secrets](#step-23-store-dockerhub-credentials-in-github-secrets)  
    - [Step 2.4: Create the Flask Application](#step-24-create-the-flask-application)  
    - [Step 2.5: Create the Dockerfile](#step-25-create-the-dockerfile)  
    - [Step 2.6: Create the Requirements File](#step-26-create-the-requirements-file)    
  * [Step 3: Creating the Workflow](#step-3-creating-the-workflow)  
  * [Step 4: Commit and Push the Changes](#step-4-commit-and-push-the-changes)  
  * [Step 5: Running the Workflow](#step-5-running-the-workflow)  
  * [Step 6: Observing Workflow Execution](#step-6-observing-workflow-execution)  
* [**Demo 2:** Centralizing Deployment Logic Using Reusable Workflow Inputs](#demo-2-centralizing-deployment-logic-using-reusable-workflow-inputs)  
  * [Step 1: Creating the Reusable Workflow](#step-1-creating-the-reusable-workflow)  
  * [Step 2: Creating the Calling Workflow](#step-2-creating-the-calling-workflow)  
  * [Step 3: Commit and Push the Changes](#step-3-commit-and-push-the-changes)  
  * [Step 4: Observe and Verify Workflow Execution](#step-4-observe-and-verify-workflow-execution)  
* [Conclusion](#conclusion)  
* [References](#references)  

---

## Introduction

In real-world CI/CD pipelines, workflows rarely operate with fixed values. Organizations often need the same workflow to support multiple **environments**, **applications**, **deployment strategies**, and **operational scenarios**.

Rather than creating separate workflows for every variation, GitHub Actions provides **Inputs**, which allow values to be supplied at runtime. This makes workflows more **dynamic**, **reusable**, and **environment-aware**.

In this lecture, we will learn what Inputs are, the different types of Inputs supported by GitHub Actions, how they are used in production environments, and how they enable workflows, reusable workflows, and actions to adapt their behavior without requiring code changes.

---

### What are Inputs?

**Inputs are parameters used to pass user-defined values into workflows, reusable workflows, or actions at runtime.**

Instead of hardcoding values, inputs allow workflows and actions to become **dynamic**, **reusable**, and **environment-aware**.

For example, instead of always deploying to a fixed environment such as **dev**, we can accept an input like:

* **environment=dev**
* **environment=qa**
* **environment=prod**

and make the workflow behave accordingly.

#### Why are Inputs Useful?

In real-world organizations, different environments often require different validation and deployment processes.

For example:

* **Dev** may perform only basic build and deployment validation.
* **QA** may execute additional security scans, integration tests, and application-level testing before deployment.
* **Prod** may require deployment approvals, change management checks, and production-specific deployment controls.

Rather than creating separate workflows for each environment, a single workflow can use inputs to determine which jobs and steps should execute.

For example:

* **Dev:** Build → Deploy
* **QA:** Build → Security Scan → Integration Tests → Deploy
* **Prod:** Build → Approval → Deploy

Inputs therefore allow workflows to become **environment-aware**, **reusable**, and **more efficient**.

An additional benefit is **resource optimization**. By executing only the jobs and steps required for a particular environment, organizations can reduce unnecessary runner utilization, lower CI/CD execution time, and avoid wasting compute resources on validations that are not needed for every deployment scenario.

> **Important Clarification:** Since we just learned about **Functions** in the previous lecture, it is important to understand how **Inputs** are different from them and how both concepts complement each other.
>
> An **input** provides information to the workflow, while a **function** helps process that information or make decisions based on it.
>
> For example, a user may provide:
>
> **environment=qa**
>
> The workflow can then use **expressions** and **functions** to evaluate that value and determine how the workflow should behave.
>
> Think of it this way:
>
> * **Inputs provide the data.**
> * **Experessions & Functions process the data and help make decisions.**
>
> A simple workflow execution flow would look like:
>
> **User provides input** → **environment=qa** → **Workflow receives the value** → **Expressions and Functions evaluate the value** → **Workflow behavior changes accordingly**
>
> In real-world CI/CD pipelines, **Inputs**, **Expressions**, and **Functions** are frequently used together to build dynamic, environment-aware automation workflows.
>
> For now, we will focus on understanding **Inputs** in isolation. Throughout this lecture, we will combine Inputs with **Expressions** to control workflow behavior and execution paths. Later in the course, we will build larger end-to-end workflows that bring together **Inputs**, **Outputs**, **Artifacts**, **Functions**, **Variables**, **Contexts**, and other GitHub Actions concepts to create production-style automation pipelines.

Now that we understand **what Inputs are** and how they fit into the broader GitHub Actions ecosystem, let's explore the different types of inputs supported by GitHub Actions.


---

## Types of Inputs

![Alt text](/images/6a.png)

GitHub Actions supports three primary types of inputs:

**1. Workflow Inputs**

* Used to provide values when triggering workflows through **GitHub UI**, **GitHub API**, or **GitHub CLI** using `workflow_dispatch`.

* **Example:** Providing deployment parameters such as environment, application version, or deployment strategy at runtime.

**2. Reusable Workflow Inputs**

* Used to pass values from a **calling workflow** to a **reusable workflow** using `workflow_call`.
* **Example:** Passing deployment parameters such as **application name, replica count, or security scan settings** to a centralized deployment workflow.

**3. Action Inputs**

* Used to pass values from a workflow to a **custom action** during **action execution**.
* **Example:** Providing parameters such as **image name, Slack channel, or Terraform workspace** to control the action's behavior.

We will now discuss each of these in detail.

---

### Type 1: Workflow Inputs

Workflow Inputs are used when workflows are triggered using:

```yaml
on:
  workflow_dispatch:
```

They allow users to provide values at runtime rather than modifying workflow code.

**Production Example**

Consider a deployment workflow used across multiple environments.

Rather than maintaining separate workflows for **Dev**, **QA**, and **Prod**, the workflow can ask the user to select the target environment during execution.

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: Deployment Environment
        required: true
        type: choice
        default: dev
        options:
          - dev
          - qa
          - prod
```

GitHub automatically presents a dropdown menu when the workflow is executed, allowing the user to select **dev**, **qa**, or **prod** based on the deployment requirement.

**Understanding the Input Definition**

* **`environment`** is the **input name**. This is how the workflow later references the value using **`${{ inputs.environment }}`**.

  > A workflow can define **multiple inputs**, each with a unique name. For example, a deployment workflow may collect inputs such as the target **environment**, **application version**, **deployment strategy**, and whether **smoke tests** should be executed. The workflow can then use these values to determine **where** and **how** the application should be deployed, while still using the same workflow definition across multiple deployment scenarios.
  >
  > ```text
  > Environment         → dev / qa / prod
  > Application Version → v1.2.0
  > Deployment Strategy → rolling / blue-green
  > Run Smoke Tests     → true / false
  > ```
  >
  > This allows a **single workflow** to support multiple deployment scenarios without requiring **workflow duplication** or **code changes**.

* **`description`** provides a user-friendly explanation displayed in the GitHub UI. This field is optional but highly recommended.
* **`required: true`** makes the input mandatory. The workflow cannot be started until a value is provided.
* **`type: choice`** displays a dropdown list and restricts users to predefined values.
  GitHub currently supports the following input types for **`workflow_dispatch`**:

  | Type              | Purpose                       | Common Use Cases                                                                  |
  | ----------------- | ----------------------------- | --------------------------------------------------------------------------------- |
  | **`string`**      | Free-form text input          | Application version (`v1.2.0`), Docker image tag, release identifier, branch name |
  | **`choice`**      | Select from predefined values | Environment selection (`dev`, `qa`, `prod`), deployment strategy, cloud region    |
  | **`boolean`**     | True/false selection          | Enable security scans, run database migrations, trigger smoke tests               |
  | **`number`**      | Numeric value                 | Replica count, timeout value, retry count, scaling parameter                      |
  | **`environment`** | Select a GitHub Environment   | Choose environments with associated secrets, approvals, and protection rules      |

  For example, if we changed **`type: choice`** to **`type: boolean`**, GitHub would present a **true/false selection** instead of a dropdown. This is useful when enabling or disabling **optional workflow behavior** such as **security scanning**, **database migrations**, or **smoke testing**.

  Similarly, using **`type: environment`** allows users to select from the **GitHub Environments** already configured in the repository. Selecting an environment can automatically provide access to **environment-specific secrets**, **deployment approvals**, and **protection rules** associated with that environment.

  > **Best Practice:** Whenever the allowed values are known in advance, prefer **`type: choice`** over **`type: string`**. This prevents **invalid user input**, improves **consistency**, and provides a better user experience through **dropdown-based selection**. For example, allowing users to choose from **`dev`**, **`qa`**, and **`prod`** is generally safer than asking them to type the environment name manually.

* **`default: dev`** **pre-selects** a value when the workflow execution screen is opened. Users can still choose a different option, but if no change is made, the default value is used. This improves usability and helps standardize common execution paths.
* **`options`** defines the values available in the dropdown. This field is required when using `type: choice`.




Accessing the input:

```yaml
run: echo "Deploying to ${{ inputs.environment }}"
```

If the user selects **prod**, the workflow outputs:

~~~
Deploying to prod
~~~

> **Production Insight:** Workflow Inputs are commonly used for environment selection, release version selection, deployment approvals, rollback targets, maintenance operations, scaling activities, and other operational workflows triggered on demand.

> **Important:** Although Workflow Inputs are commonly demonstrated using the **GitHub UI**, they are not limited to manual execution. Workflows triggered through **`workflow_dispatch`** can also be invoked programmatically using the **GitHub API** or **GitHub CLI**, with input values supplied as part of the request.
>
> Think of it like creating an **EC2 instance** in AWS. You can create it manually through the **AWS Management Console**, or you can create the same EC2 instance programmatically using the **AWS CLI**, **SDKs**, or **Terraform**. The end result is the same; only the mechanism used to provide the input values differs.
>
> Similarly, a GitHub Actions workflow can be triggered through multiple interfaces:
>
> * **GitHub UI** → Users provide inputs through a web interface.
> * **GitHub CLI (`gh`)** → Users provide inputs through command-line arguments.
> * **GitHub REST API** → Applications provide inputs through an HTTP request payload.
>
> Regardless of the interface used, the workflow ultimately receives the same input values and executes the same workflow logic. This flexibility allows organizations to integrate GitHub Actions with **deployment portals**, **ITSM tools**, **approval systems**, **ChatOps platforms**, and other automation solutions while continuing to use a single workflow definition.


---

## Type 2: Reusable Workflow Inputs

**Reusable Workflow Inputs** are used to pass values from a **calling workflow** to a **reusable workflow**.

They are defined using:

```yaml
on:
  workflow_call:
```

Unlike **Workflow Inputs**, which typically receive values from **users** during workflow execution, **Reusable Workflow Inputs** receive values from another workflow through the **`with:`** block.

This enables organizations to **standardize common automation logic** and reuse it across multiple **repositories**, **applications**, and **teams** while still allowing application-specific values to be supplied at runtime.

> **Jenkins Comparison:** If you have worked with **Jenkins Shared Libraries**, the concept of **Reusable Workflows** should feel familiar. In both cases, common automation logic is centralized and reused across multiple pipelines rather than being duplicated in every project. A Jenkins pipeline can invoke functions from a Shared Library, while a GitHub Actions workflow can invoke a Reusable Workflow using **`workflow_call`**. Although the implementation details differ, both approaches aim to improve **standardization**, **reusability**, **governance**, and **maintainability**.

**Production Example**

Many organizations maintain centralized deployment workflows managed by platform engineering teams.

For example, an organization may define standards such as:

* All applications must be deployed through a **common workflow**.
* All deployments must execute **security validation**.
* All deployments must follow a **standard approval process**.
* All deployments must generate deployment **metadata and audit logs**.

Rather than every application team implementing these requirements independently, platform teams create a reusable deployment workflow that can be consumed by all application teams.

A **reusable workflow** might look like:

```yaml
on:
  workflow_call:
    inputs:
      application_name:
        required: true
        type: string

      run_security_scan:
        required: true
        type: boolean

      replicas:
        required: true
        type: number
```

**Understanding the Input Definition**

* **`application_name`** (`string`) identifies the application being deployed (e.g., `payment-service`).
* **`run_security_scan`** (`boolean`) determines whether security validation should be executed before deployment.
* **`replicas`** (`number`) specifies how many application instances should be deployed.

GitHub currently supports the following input types for **Reusable Workflow Inputs**:

* **`string`** → Application names, image tags, environment names, release identifiers
* **`boolean`** → Enable or disable optional workflow behavior (e.g., `run_security_scan: true`)
* **`number`** → Numeric values such as replica counts, timeout values, and scaling parameters

Selecting the appropriate input type improves **validation**, **readability**, and overall **workflow design**.

The inputs required by a reusable workflow are entirely **organization-specific**. For example, one company may require **`application_name`**, **`run_security_scan`**, and **`replicas`**, while another may additionally enforce inputs such as **`change_ticket`**, **`cost_center`**, or **`region`** to satisfy governance, compliance, or operational requirements.

A **calling workflow** can then invoke the reusable workflow:

```yaml
jobs:
  deploy:
    uses: ./.github/workflows/deploy.yaml
    with:
      application_name: payment-service
      run_security_scan: true
      replicas: 5
```

In this example:

* **`deploy.yaml`** is the reusable workflow.
* The calling workflow passes **deployment-specific information**.
* The reusable workflow receives the values through the **`inputs` context**.

Inside the **reusable workflow:**

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Display Deployment Information
        run: |
          echo "Application: ${{ inputs.application_name }}"
          echo "Run Security Scan: ${{ inputs.run_security_scan }}"
          echo "Replicas: ${{ inputs.replicas }}"

      - name: Deploy Application
        run: |
          echo "Deploying application..."
```

Output:

```text
Application: payment-service
Run Security Scan: true
Replicas: 5
```

**Why is this Useful?**

Consider a GitHub Organization with **50 microservices** and **20 engineering teams** following a common deployment process.

```text id="sx5cw6"
GitHub Organization

├── payment-service
├── inventory-service
├── notification-service
├── order-service
├── ...
└── shared-platform-workflows
      └── deploy.yaml (Reusable Workflow)
```

Rather than every repository maintaining its own deployment implementation, application repositories can invoke the centrally managed **deploy.yaml** reusable workflow from the **shared-platform-workflows** repository and supply application-specific values through inputs.

| Without Reusable Workflows                           | With Reusable Workflows                                                           |
| ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| 50 repositories, 50 deployment workflows             | 50 repositories, 50 lightweight calling workflows, 1 reusable deployment workflow |
| Deployment logic duplicated across repositories      | Deployment logic centralized in a reusable workflow                               |
| Higher maintenance overhead                          | Easier maintenance and governance                                                 |
| Changes require updates across multiple repositories | Changes implemented once and inherited by all consumers                           |

This improves **standardization**, **reusability**, **security**, and **operational consistency**.

> **Production Insight:** In large **GitHub Organizations**, **Platform Engineering Teams** often maintain reusable workflows in **centralized repositories** and make them available to **application teams** across multiple repositories. Application repositories typically retain small **calling workflows** containing application-specific configuration, while the shared repository contains the actual deployment, security, compliance, and governance logic. This significantly reduces **duplication** and **maintenance overhead** while enforcing consistent **CI/CD standards** across the organization.

---

## Type 3: Action Inputs

**Action Inputs** are used to pass values into **custom actions**.

Unlike **Workflow Inputs** and **Reusable Workflow Inputs**, which are defined within workflows, **Action Inputs** are defined **inside the action itself** and allow the action to receive configuration values from the workflow using it.

This enables organizations to create **reusable**, **configurable**, and **standardized actions** that can be used across multiple repositories and teams.

> **Note:** At this stage, the goal is simply to understand that **Action Inputs** allow workflows to pass configuration values into **custom actions**. Since we have not yet covered custom actions, we will not explore this topic in depth right now.
>
> We will revisit **Action Inputs** in a dedicated **Custom Actions** lecture, where we will build our own custom action and practically demonstrate how inputs are defined, consumed, and used to create reusable automation components. For now, focus on understanding the concept and how Action Inputs differ from **Workflow Inputs** and **Reusable Workflow Inputs**.

**Production Example**

Suppose an organization creates a custom security scanning action. Rather than hardcoding the image to scan, the action can accept the image name as an input.

Action definition:

```yaml
inputs:
  image-name:
    required: true
```

**Understanding the Input Definition**

* **`image-name`** is the input name. The action references it using `${{ inputs.image-name }}`.
* **`required: true`** ensures that workflows using the action must provide a value.

> **Note:** Action Inputs support **`string`**, **`boolean`**, and **`number`** data types.
>
> * **`string`** → Container image names, application names, email addresses, deployment environments
> * **`boolean`** → Enable or disable optional action behavior (e.g., `fail_on_high_severity: true`)
> * **`number`** → Numeric configuration values (e.g., `retry_count: 3`, `timeout_minutes: 30`)

A workflow can use the action as follows:

```yaml
- uses: company/docker-scan-action@v1
  with:
    image-name: payment-service:v1
```

In this example:

* `company/docker-scan-action@v1` is the custom action.
* `image-name` is the input being passed to the action.
* `payment-service:v1` is the value supplied by the workflow.

Accessing the input inside the action:

```yaml
${{ inputs.image-name }}
```

The action can now scan the specified container image.

For example:

* Input: `payment-service:v1`
* Action Behavior: Scan the image for vulnerabilities
* Output: Security scan results

**Why is this Useful?**

Consider an organization with dozens of applications that must undergo security scanning before deployment.

Rather than creating separate actions for every application, teams can create a single reusable scanning action and pass application-specific values through inputs. This promotes **reusability**, **standardization**, **maintainability**, and **operational consistency** while reducing duplicated automation logic.

> **Production Insight:** Action Inputs are commonly used for deployment actions, security scanning actions, notification actions, compliance actions, infrastructure provisioning actions, testing actions, and internal platform tooling.


---

## Demo 1: Building an Environment-Aware CI Pipeline Using Workflow Inputs

In this demo, we will build a simple **environment-aware CI pipeline** using **Workflow Inputs**.

The primary goal of this demo is to help you understand how **Workflow Inputs** allow users to provide values at runtime and how those values can influence workflow behavior without requiring any changes to the workflow code itself.

We will use a simple Flask application similar to the one used in previous demos and extend the workflow to support different execution paths for **Dev**, **QA**, and **Prod** environments.

The overall workflow architecture for this demo is shown below:

```text
User Triggers Workflow
            │
            ▼
      Workflow Inputs
      ├── Environment
      └── Perform Smoke Test
            │
            ▼
      GitHub Actions Runner
            │
            ▼
      Build Docker Image
            │
            ▼
    Environment-Specific Logic
      ├── Dev
      ├── QA
      └── Prod
```

In this demo pipeline:

1. A user manually triggers the workflow.
2. The user selects an environment.
3. The user decides whether smoke testing should be executed.
4. GitHub Actions receives the input values.
5. The workflow adjusts its behavior based on those inputs.
6. The execution results are observed from the GitHub Actions UI.

By the end of this demo, we will:

* manually trigger a workflow using **workflow_dispatch**
* provide input values through the GitHub UI
* build a Docker image
* execute environment-specific workflow behavior
* optionally execute smoke testing
* observe how the same workflow behaves differently based on supplied inputs

> **Operational Insight:** This demo intentionally focuses on **Workflow Inputs**. The objective is not to build a production deployment platform, but rather to understand how a single workflow can support multiple deployment scenarios through runtime input values.

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

### Step 2: Preparing the Application and Supporting Components

Before creating the workflow, we first need an **application** and the supporting components required by the **CI/CD pipeline**.

In this step, we will:

* create a simple **Flask application**
* containerize the application using **Docker**
* create a private **DockerHub repository** for image storage
* generate a **DockerHub Access Token** for authentication
* securely store credentials using **GitHub Secrets**

By the end of this step, we will have everything required to **build**, **test**, **publish**, and **deploy** container images through **GitHub Actions**.

We will now create a small **containerized Python application** using the **Flask framework**.

For simplicity, we will place all application files under a directory called:

```text
project-files
```

Recommended directory structure:

```text
project-files/
├── app.py
├── Dockerfile
├── requirements.txt
└── .github/
    └── workflows/
        └── 01-actions-demo.yaml
```

> **Why are we creating all of these components?** A typical **CI/CD pipeline** requires more than just application source code. It also needs a **container image definition (Dockerfile)**, a **container registry (DockerHub)** for storing images, and **secure credentials (GitHub Secrets)** for authentication. Together, these components form the foundation of the workflow we will build in the next step.


---

#### Step 2.1: Create a Private DockerHub Repository

Navigate to DockerHub and create a new repository.

Use the following values:

| Property        | Value            |
| --------------- | ---------------- |
| Repository Name | `cwvj-flask-app` |
| Visibility      | Private          |

> **Operational Insight:** Container registries act as centralized repositories for storing and distributing container images. Modern CI/CD pipelines commonly publish validated images into registries before deployment to development, staging, or production environments.

---

#### Step 2.2: Create a DockerHub Access Token

Our workflow will eventually push container images into DockerHub.

Since GitHub Actions workflows execute inside runners, those runners must authenticate with DockerHub before they can publish images.

Instead of using a DockerHub account password, DockerHub recommends using **Personal Access Tokens (PATs)**.

###### Creating the Token

Navigate to:

**Profile Icon → Account Settings → Personal Access Tokens → Generate New Token**

Use the following values:

| Property | Value |
|----------|----------|
| Description | `gha-demo` |
| Expiration | 1 Day |
| Access | Read & Write |

> **Important:** Copy the token immediately and store it securely because DockerHub displays the token only once.

> **Important:** Never use your actual DockerHub account password inside CI/CD workflows. Always use access tokens.

> **Security Insight:** Production environments typically implement credential rotation, least-privilege access controls, and short-lived credentials instead of long-lived static secrets.

---

#### Step 2.3: Store DockerHub Credentials in GitHub Secrets

We will now securely store the DockerHub access token inside GitHub Secrets.

Navigate to:

```text
Repository Settings
  → Secrets and variables
      → Actions
```

Create the following repository secret:

| Secret Name       | Value                  |
| ----------------- | ---------------------- |
| `DOCKERHUB_TOKEN` | DockerHub Access Token |

> **Why GitHub Secrets?** GitHub automatically injects secrets into workflow runtimes while masking secret values in workflow logs to prevent accidental exposure.

> **Scope Consideration:** GitHub Secrets can be defined at multiple levels. **Repository-level** secrets are accessible only within a specific repository, whereas **organization-level** secrets can be shared across multiple repositories within a GitHub organization. The appropriate scope depends on security requirements, ownership boundaries, and reuse needs.

> **Security Recommendation:** Secrets should never be hardcoded inside source code, workflow files, Dockerfiles, or shell scripts.

---

#### Step 2.4: Create the Flask Application

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

#### Step 2.5: Create the Dockerfile

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

#### Step 2.6: Create the Requirements File

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

### Step 3: Creating the Workflow

Create the following workflow file:

**`.github/workflows/01-workflow-inputs-demo.yaml`**

```yaml
name: 01 - Type 1 Workflow Inputs Demo

on:
  workflow_dispatch:
    inputs:
      environment:
        description: Deployment Environment
        required: true
        type: choice
        default: dev
        options:
          - dev
          - qa
          - prod

      perform_smoke_test:
        description: Execute Smoke Test
        required: true
        type: boolean
        default: true

env:
  APPLICATION_NAME: cwvj-flask-app
  DOCKER_USERNAME: cloudwithvarjosh
  IMAGE_TAG: v1.0.1

jobs:
  flask-ci-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Display Input Values
        run: |
          echo "Environment: ${{ inputs.environment }}"
          echo "Perform Smoke Test: ${{ inputs.perform_smoke_test }}"

      - name: Build Docker Image
        uses: docker/build-push-action@v7
        with:
          context: .
          push: false
          tags: ${{ env.DOCKER_USERNAME }}/${{ env.APPLICATION_NAME }}:${{ env.IMAGE_TAG }}

      - name: QA Validation
        if: ${{ inputs.environment == 'qa' }}
        run: |
          echo "Running QA validation checks..."
          echo "Running security validation..."
          echo "Running integration validation..."
          echo "QA validation completed successfully."

      - name: Login to DockerHub
        if: ${{ inputs.environment != 'dev' }}
        uses: docker/login-action@v3
        with:
          username: ${{ env.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Push Docker Image
        if: ${{ inputs.environment != 'dev' }}
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: ${{ env.DOCKER_USERNAME }}/${{ env.APPLICATION_NAME }}:${{ env.IMAGE_TAG }}

      - name: Run Container
        run: |
          docker run -d \
            -p 5000:5000 \
            --name flask-container \
            ${{ env.DOCKER_USERNAME }}/${{ env.APPLICATION_NAME }}:${{ env.IMAGE_TAG }}

      - name: Smoke Test
        if: ${{ inputs.perform_smoke_test }}
        run: |
            sleep 5
            curl http://localhost:5000/health
            echo "Smoke test completed successfully."

      - name: Deploy to Kubernetes
        if: ${{ inputs.environment == 'prod' }}
        run: |
          echo "Deploying application to Production Kubernetes Cluster..."
          echo "Deployment completed successfully."
```

---

#### Explanation

```yaml
name: 01 - Type 1 Workflow Inputs Demo
```

* This block defines the **workflow name** displayed inside the **GitHub Actions UI**.
* The name does not affect workflow behavior, execution logic, or workflow outcomes.
* It helps engineers quickly identify workflow runs while reviewing **execution history**, troubleshooting failures, monitoring **CI/CD pipelines**, or analyzing deployment activity.
* Choosing clear and descriptive workflow names becomes increasingly important as repositories grow and contain multiple automation workflows.

> **Operational Tip:** Production repositories often contain **dozens or even hundreds of workflows** supporting **CI**, **CD**, **security scanning**, **compliance validation**, **dependency management**, **infrastructure automation**, and various **operational activities**. Meaningful workflow names make it significantly easier for engineers to locate the correct workflow during **troubleshooting**, **audits**, **incident investigations**, and day-to-day operations.



---

```yaml
on:
  workflow_dispatch:
```

* This block defines the workflow trigger.
* Unlike previous demos that used the **`push`**, **`pull_request`** events, this workflow executes only when a user manually starts it from the GitHub Actions UI.
* This trigger is required because **Workflow Inputs** are supplied during workflow execution and are currently supported through **`workflow_dispatch`**.
* When a user clicks **Run Workflow**, GitHub displays the configured input fields and allows values to be supplied before execution begins.

> **Important:** If a workflow supports both **`workflow_dispatch`** and **`push`**, do not assume that `workflow_dispatch` input values or defaults will automatically apply to `push` executions. When supporting multiple trigger types, define explicit fallback values or event-specific logic to ensure predictable workflow behavior.

> **Production Insight:** Manual workflows are commonly used for **production deployments**, **rollback operations**, **database migrations**, **maintenance activities**, **disaster recovery procedures**, and other operational tasks that require human decision-making. Rather than automatically executing on every code change, these workflows allow engineers to provide runtime parameters and maintain greater control over critical operations.


---

```yaml
inputs:
  environment:
    description: Deployment Environment
    required: true
    type: choice
    default: dev
    options:
      - dev
      - qa
      - prod

  perform_smoke_test:
    description: Execute Smoke Test
    required: true
    type: boolean
    default: true
```

* This block defines the **Workflow Inputs** that users can provide during workflow execution.
* The **`environment`** input allows users to select the target deployment environment. Because the type is **`choice`**, GitHub automatically displays a dropdown menu containing **dev**, **qa**, and **prod**.
* The **`perform_smoke_test`** input allows users to decide whether smoke testing should execute. Because the type is **`boolean`**, GitHub automatically displays a true/false selector.
* The **`default`** keyword specifies the value that GitHub preselects when the workflow is displayed. In this example, **`dev`** is selected by default for the environment, and **`true`** is selected by default for smoke testing.
* Users can either accept the **default values** or override them before starting the workflow.

Examples:

```text
Environment        → qa
Perform Smoke Test → true
```

```text
Environment        → prod
Perform Smoke Test → false
```

> **Key Observation:** This demo intentionally uses both **`choice`** and **`boolean`** input types so you can see how different input types appear in the GitHub UI and influence workflow behavior. It also demonstrates the **`default`** keyword, which allows commonly used values to be preselected while still giving users the flexibility to override them when needed.
>
> **Operational Insight:** Default values are not only useful for the **GitHub UI**. When a workflow is triggered programmatically through the **GitHub API** or **GitHub CLI**, callers can omit inputs that already have default values defined. In this example, the workflow can be executed without explicitly supplying **`environment`** or **`perform_smoke_test`**, and GitHub will automatically use **`dev`** and **`true`** respectively.
>
> For example, the following API request can successfully trigger the workflow without supplying either input because both have default values configured:
>
> ```bash
> curl -X POST \
>   -H "Accept: application/vnd.github+json" \
>   -H "Authorization: Bearer <GITHUB_TOKEN>" \
>   https://api.github.com/repos/CloudWithVarJosh/cwvj-gha-practice/actions/workflows/01-workflow-inputs-demo.yaml/dispatches \
>   -d '{
>     "ref": "main"
>   }'
> ```
>
> GitHub will automatically execute the workflow using:
>
> ```text
> Environment        → dev
> Perform Smoke Test → true
> ```
>
> The same behavior applies when using the GitHub CLI:
>
> ```bash
> gh workflow run 01-workflow-inputs-demo.yaml
> ```
>
> Since both inputs have default values, no additional parameters are required.

---

```yaml
env:
  APPLICATION_NAME: cwvj-flask-app
  DOCKER_USERNAME: cloudwithvarjosh
  IMAGE_TAG: v1.0.1
```

* This block defines **workflow-level variables**.
* These variables become available to all jobs and steps within the workflow.
* Using variables eliminates **hardcoded values** and improves maintainability because commonly used values are defined in a single location.
* If any of these values change in the future, only this block requires modification rather than updating **multiple workflow steps**.

> **Important:** In this example, the variables are defined at the **workflow level**, making them accessible throughout the workflow. GitHub Actions also allows variables to be defined using `env:` at the **job level** and **step level**.
>
> * **Workflow-level variables** are available to all jobs and steps.
> * **Job-level variables** are available only within that job.
> * **Step-level variables** are available only within that step.
>
> As a general guideline, define variables at the **lowest scope necessary** while still meeting your reuse requirements.

---

```yaml
jobs:
  flask-ci-job:
```

* This block creates a workflow job named **`flask-ci-job`**.
* A **job** acts as a logical unit of work and contains all the steps required to achieve a specific objective.
* In this demo, the job is responsible for **building the Docker image**, performing **environment-specific validation**, optionally executing **smoke tests**, publishing images when required, and simulating **deployment activities**.
* All steps within this job execute sequentially because they belong to the same job and depend on the successful completion of previous steps.

> **Production Insight:** As CI/CD pipelines grow, organizations often split workflows into multiple jobs such as **Build**, **Test**, **Security Scan**, **Package**, and **Deploy**. This improves separation of responsibilities, enables parallel execution where appropriate, and makes large pipelines easier to maintain, troubleshoot, and scale.


---

```yaml
runs-on: ubuntu-latest
```

* This block instructs GitHub Actions to allocate a **GitHub-hosted Ubuntu runner**.
* All workflow steps within the job execute inside this runner environment.
* Each workflow execution receives a fresh and isolated runner, ensuring consistent behavior across runs.
* The runner contains commonly used development tools and provides the execution environment required for CI/CD automation.

> **Operational Note:** GitHub-hosted runners are **ephemeral**. After workflow execution completes, the runner and all temporary files, containers, and runtime state are automatically destroyed.


---

```yaml
- name: Checkout Repository
  uses: actions/checkout@v6
```

* This step downloads the **repository contents** from GitHub onto the runner.
* Without this step, the workflow would not have access to the application's **source code**, **Dockerfile**, **workflow files**, or other repository assets.
* Most CI/CD pipelines execute this step near the beginning because subsequent steps typically require access to repository files.
* Think of this as preparing the **runner workspace** before any build, test, validation, or deployment activities begin.

> **Production Insight:** Large organizations often split CI/CD platforms across multiple repositories. In such cases, workflows may check out not only the **application repository**, but also shared **deployment repositories**, **Helm chart repositories**, **platform automation repositories**, **GitOps repositories**, or **Infrastructure-as-Code repositories**. It is common for a single workflow to work with resources originating from multiple repositories rather than just the application source code.


---

```yaml id="8q2s08"
- name: Display Input Values
  run: |
    echo "Environment: ${{ inputs.environment }}"
    echo "Perform Smoke Test: ${{ inputs.perform_smoke_test }}"
```

* This step displays the values supplied through the **Workflow Inputs**.
* It helps verify that GitHub correctly received the selected **input values** before the workflow proceeds further.
* During troubleshooting, this information can quickly confirm whether the workflow was executed using the expected **environment** and **execution parameters**.
* For example, we can immediately determine whether the workflow was triggered for **dev**, **qa**, or **prod**, and whether **smoke testing** was enabled.

> **Operational Tip:** Logging important **execution parameters** early in the workflow can significantly simplify **troubleshooting**, **audit investigations**, and **incident analysis**. Many production teams intentionally log key runtime values at the start of a workflow to make debugging and operational reviews easier.


---

```yaml
- name: Build Docker Image
  uses: docker/build-push-action@v7
  with:
    context: .
    push: false
    tags: ${{ env.DOCKER_USERNAME }}/${{ env.APPLICATION_NAME }}:${{ env.IMAGE_TAG }}
```

* This step builds the **Docker image** for the Flask application.
* The image is created locally on the GitHub Actions runner and is not pushed to DockerHub because **`push: false`** has been configured.
* Every environment requires a container image, so this step executes regardless of the selected environment.
* Building the image first allows subsequent steps to validate, publish, or deploy the same artifact.

> **Production Insight:** Mature CI/CD platforms follow the principle of **Build Once, Deploy Many**. The same validated image is promoted across Dev, QA, Stage, and Production rather than rebuilding the application for each environment.

---
```yaml
- name: QA Validation
  if: ${{ inputs.environment == 'qa' }}
  run: |
    echo "Running QA validation checks..."
    echo "Running security validation..."
    echo "Running integration validation..."
    echo "QA validation completed successfully."
```

* This step simulates **validation activities** typically performed in a **QA environment**.
* The step executes only when the selected environment is **`qa`**.
* In a real-world pipeline, this stage could perform **security scanning**, **integration testing**, **compliance validation**, or **application verification**.
* The primary goal in this demo is to demonstrate how **Workflow Inputs** can influence **workflow behavior** and determine which steps execute.

> **Production Insight:** **QA environments** often act as the **final validation gate before production**. Many organizations require **security scans**, **integration tests**, **compliance checks**, and **approval workflows** to pass before deployments can proceed to higher environments or production systems.


---

```yaml
- name: Login to DockerHub
  if: ${{ inputs.environment != 'dev' }}
  uses: docker/login-action@v3
  with:
    username: ${{ env.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

* This step authenticates the workflow with DockerHub.
* Authentication is required before images can be pushed to a container registry.
* The step executes only for **qa** and **prod** because those environments publish images.
* Development environments often build and test images without publishing them to a shared registry.

> **Production Insight:** While many organizations use cloud-native registries such as **Amazon ECR**, **Azure Container Registry (ACR)**, and **Google Artifact Registry**, enterprises also commonly use platforms such as **JFrog Artifactory**, **Harbor**, **GitHub Container Registry (GHCR)**, and **Docker Hub Team/Business** editions. The choice typically depends on factors such as **cloud strategy**, **security requirements**, **artifact management needs**, and **multi-cloud or hybrid infrastructure considerations**.

---

```yaml
- name: Push Docker Image
  if: ${{ inputs.environment != 'dev' }}
  uses: docker/build-push-action@v7
  with:
    context: .
    push: true
    tags: ${{ env.DOCKER_USERNAME }}/${{ env.APPLICATION_NAME }}:${{ env.IMAGE_TAG }}
```

* This step publishes the generated Docker image to DockerHub.
* The step executes only for **qa** and **prod** environments.
* Publishing images allows downstream environments, deployment systems, or platform teams to consume a validated artifact.
* This reflects a common CI/CD pattern where only approved or validated builds are published to a central registry.

> **Production Insight:** Published images often undergo additional scanning, signing, vulnerability assessment, and policy validation before being approved for production deployment.

> **Design Consideration:** In this demo, we intentionally do **not publish Docker images for the Dev environment**. Instead, we build the image, run a container from it, and perform validation locally on the GitHub Actions runner. This helps demonstrate that the image can be successfully built and executed without storing every development build in a container registry.
>
> However, workflow design varies across organizations. Some teams choose to publish images for **all environments**, including Dev, and perform validation using the published image. Others may publish images only after smoke tests, security scans, integration tests, or approval gates have successfully passed. In some organizations, Dev builds may never be published because they are used solely for rapid feedback and validation.
>
> **The key takeaway is that CI/CD workflows should reflect the requirements of the application and organization.** Every application, microservice, and engineering team has different needs related to **quality**, **security**, **compliance**, **cost**, **artifact retention**, and **release management**, so workflow design decisions should be made accordingly.

> **Production Consideration:** In this demo, we use a fixed image tag (**`cloudwithvarjosh/cwvj-flask-app:v1.0.1`**) to keep the workflow simple and focus on Workflow Inputs. In production environments, teams typically use **unique and immutable tags** such as **Git commit SHAs**, **build numbers**, **release versions**, or a combination of these values. Like we've seen in the previous lecture.
>
> Examples:
>
> ```text
> cloudwithvarjosh/cwvj-flask-app:v1.0.1
> cloudwithvarjosh/cwvj-flask-app:v1.0.1-build-245
> cloudwithvarjosh/cwvj-flask-app:9f2c8a7
> cloudwithvarjosh/cwvj-flask-app:2026.06.12.245
> ```
>
> Using immutable tags improves **traceability**, **auditability**, **rollback capability**, and **deployment reliability**.
>
> **Production Insight:** Many organizations follow a **Build Once, Deploy Many** strategy. The application image is built a single time, assigned a unique immutable tag, and then promoted across environments such as **Dev**, **QA**, **UAT**, and **Prod**. This ensures that the exact same artifact that passed testing is ultimately deployed to production, eliminating inconsistencies caused by rebuilding the application multiple times.
>
> **Design Consideration:** There is no single tagging or promotion strategy that works for every organization. Some teams rebuild artifacts per environment, while others strictly promote previously validated artifacts. The workflow design should align with the application's **release process**, **compliance requirements**, **rollback strategy**, and **operational practices**.


---

```yaml
- name: Run Container
  run: |
    docker run -d \
      -p 5000:5000 \
      --name flask-container \
      ${{ env.DOCKER_USERNAME }}/${{ env.APPLICATION_NAME }}:${{ env.IMAGE_TAG }}
```

* This step starts the application inside a Docker container on the GitHub Actions runner.
* The step executes for **all environments** because every deployment path should first validate that the generated image can start successfully.
* Running the container helps verify that the application, dependencies, configuration, and startup process are functioning as expected.
* By validating the image before deployment, we increase confidence that the same artifact can safely progress through the remainder of the pipeline.

> **Production Insight:** Many organizations follow a **Build → Start Container → Validate → Deploy** approach. This helps detect startup failures, dependency issues, missing configurations, and runtime problems early in the delivery process before an artifact is promoted to higher environments or deployed to production.

---

```yaml
- name: Smoke Test
  if: ${{ inputs.perform_smoke_test }}
  run: |
    sleep 5
    curl --fail http://localhost:5000/health
    echo "Application is healthy."
```

* This step performs a simple **smoke test** against the running application.
* Execution is controlled entirely by the **`perform_smoke_test` Workflow Input**.
* If the user selects **true**, the smoke test executes; otherwise, it is skipped.
* The step validates that the application has started successfully, is reachable, and is responding as expected before the workflow proceeds further.

> **Production Insight:** Smoke tests are typically the **first validation** performed after an application starts or after a deployment completes. Their goal is not **exhaustive testing**, but rather quickly verifying that the application is **healthy**, **reachable**, and capable of **serving requests**. Production pipelines often **fail immediately** if smoke tests do not pass, preventing **unhealthy releases** from progressing to subsequent environments or deployment stages.

---

```yaml
- name: Deploy to Kubernetes
  if: ${{ inputs.environment == 'prod' }}
  run: |
    echo "Deploying application to Production Kubernetes Cluster..."
    echo "Deployment completed successfully."
```

* This step simulates a production deployment.
* The step executes only when the selected environment is **prod**.
* For simplicity, the demo uses placeholder commands instead of performing an actual Kubernetes deployment.
* The goal is to demonstrate how the same workflow can support different execution paths based on user-supplied inputs while remaining reusable and easy to maintain.

> **Production Insight:** Modern Kubernetes environments frequently use **GitOps platforms such as Argo CD or Flux** for deployments. In such architectures, GitHub Actions often updates manifests, Helm values, or image tags in a Git repository, while Argo CD continuously synchronizes those changes into the cluster.

---

#### Expected Workflow Behavior

Depending on the selected input values, different workflow steps may execute or be skipped.

| Step                 | Dev      | QA       | Prod     |
| -------------------- | -------- | -------- | -------- |
| Checkout Repository  | ✓        | ✓        | ✓        |
| Display Input Values | ✓        | ✓        | ✓        |
| Build Docker Image   | ✓        | ✓        | ✓        |
| QA Validation        | ✗        | ✓        | ✗        |
| Login to DockerHub   | ✗        | ✓        | ✓        |
| Push Docker Image    | ✗        | ✓        | ✓        |
| Run Container        | ✓        | ✓        | ✓        |
| Smoke Test*          | Optional | Optional | Optional |
| Deploy to Kubernetes | ✗        | ✗        | ✓        |

* **Smoke Test** execution depends on the value supplied for the **`perform_smoke_test`** Workflow Input.

Notice how different input values result in different workflow behavior:

| Environment | Typical Execution Path                                                     |
| ----------- | -------------------------------------------------------------------------- |
| **dev**     | Build → Run Container → Smoke Test (Optional)                              |
| **qa**      | Build → QA Validation → Push Image → Run Container → Smoke Test (Optional) |
| **prod**    | Build → Push Image → Run Container → Smoke Test (Optional) → Deploy        |

> **Key Observation:** The **workflow definition remains exactly the same** in all scenarios. Only the supplied **input values** change. GitHub Actions evaluates those inputs and determines which steps should execute based on the configured conditions.

> **Important Learning:** This is one of the primary benefits of **Workflow Inputs**. Rather than maintaining separate workflows for **Dev**, **QA**, and **Production**, a single workflow can support multiple execution paths by combining **inputs**, **conditions**, and **environment-specific logic**.

> **Production Insight:** Large organizations commonly use this approach to standardize deployments across multiple environments. Engineers provide runtime values such as **environment**, **application version**, **deployment strategy**, **rollback target**, or **approval options**, while the same workflow dynamically adjusts its behavior based on those inputs.

---

### Step 4: Commit and Push the Changes

Commit the workflow and push it to GitHub.

```bash
# Add all workflow, application, and configuration changes to the Git staging area
git add .

# Create a commit containing the Workflow Inputs demo implementation
git commit -m "feat: add workflow inputs demo"

# Associate the local repository with the remote GitHub repository (one-time setup)
git remote add origin git@github.com:CloudWithVarJosh/cwvj-gha-practice.git

# Push the code to GitHub and configure the local branch to track origin/main
git push -u origin main
```

Because the workflow is configured with:

```yaml
on:
  workflow_dispatch:
```

pushing the code to GitHub will **not automatically execute the workflow**.

Navigate to:

```text
GitHub Repository
        ↓
Actions
        ↓
01 - Type 1 Workflow Inputs Demo
        ↓
Run Workflow
```

GitHub will display the configured input fields:

```text
Environment
  • dev
  • qa
  • prod

Perform Smoke Test
  • true
  • false
```

Select the desired values and click **Run Workflow** to start the workflow.

> **Production Insight:** Workflows triggered using **`workflow_dispatch`** are commonly used for **deployments**, **rollback operations**, **maintenance activities**, **database migrations**, and other operational tasks where engineers must provide runtime parameters before execution.

> **Key Observation:** Unlike traditional workflows that execute automatically in response to GitHub events such as **`push`** or **`pull_request`**, **Workflow Inputs** allow users to influence workflow behavior at runtime without modifying workflow code.

---

### Step 5: Running the Workflow

Inside the repository:

1. Navigate to the **Actions** tab.
2. Select **01 - Type 1 Workflow Inputs Demo**.
3. Click **Run Workflow**.

GitHub displays the configured input fields.

Example:

```text
Environment        → qa
Perform Smoke Test → true
```

Click:

```text
Run Workflow
```

GitHub now starts workflow execution using the selected values.

---

### Step 6: Observing Workflow Execution

#### Example 1: Dev Execution

Input values:

```text
Environment        → dev
Perform Smoke Test → true
```

Expected execution:

```text
Checkout Repository
Display Input Values
Build Docker Image
Run Container
Smoke Test
```

Skipped:

```text
QA Security Validation
Login to DockerHub
Push Docker Image
Deploy to Kubernetes
```

---

#### Example 2: QA Execution

Input values:

```text
Environment        → qa
Perform Smoke Test → true
```

Expected execution:

```text
Checkout Repository
Display Input Values
Build Docker Image
QA Security Validation
Login to DockerHub
Push Docker Image
Run Container
Smoke Test
```

Skipped:

```text
Deploy to Kubernetes
```

---

#### Example 3: Production Execution

Input values:

```text
Environment        → prod
Perform Smoke Test → false
```

Expected execution:

```text
Checkout Repository
Display Input Values
Build Docker Image
Login to DockerHub
Push Docker Image
Deploy to Kubernetes
```

Skipped:

```text
QA Security Validation
Run Container
Smoke Test
```

---

## Demo 2: Centralizing Deployment Logic Using Reusable Workflow Inputs

In the previous demo, we learned how **Workflow Inputs** allow users to provide values directly to a workflow during execution.

In this demo, we will explore **Reusable Workflow Inputs**, which allow one workflow to pass values to another workflow.

The primary objective is to understand how organizations centralize common automation logic and reuse it across multiple applications, repositories, and teams.

Rather than every application team implementing its own deployment process, platform teams often create reusable workflows containing common deployment standards, security checks, compliance controls, and operational practices.

Application teams then invoke those reusable workflows and provide application-specific values as inputs.

The overall architecture for this demo is shown below:

```text
Payment Service Repository

run-unit-tests-job
          ↓
build-payment-artifacts-job
          ↓
deploy-payment-service-job
          ↓
Reusable Deployment Workflow
          ↓
deploy-application-job
```

Notice how:

* The **calling workflow** contains application-specific logic.
* The **reusable workflow** contains shared deployment logic.
* Inputs are passed from the calling workflow into the reusable workflow.
* The reusable workflow behaves dynamically based on the supplied values.

By the end of this demo, we will understand:

* how reusable workflows are created
* how reusable workflows are invoked
* how inputs are passed between workflows
* how `needs` creates job dependencies
* how platform engineering teams standardize deployment processes
* how organizations reduce duplication across repositories

---

### Step 1: Creating the Reusable Workflow

Create the following file:

**`.github/workflows/deploy.yaml`**

```yaml
name: Reusable Deployment Workflow

on:
  workflow_call:
    inputs:
      application_name:
        required: true
        type: string

      run_security_scan:
        required: true
        type: boolean

      replicas:
        required: true
        type: number

jobs:
  deploy-application-job:
    runs-on: ubuntu-latest

    steps:
      - name: Display Deployment Parameters
        run: |
          echo "Application: ${{ inputs.application_name }}"
          echo "Run Security Scan: ${{ inputs.run_security_scan }}"
          echo "Replicas: ${{ inputs.replicas }}"

      - name: Security Validation
        if: ${{ inputs.run_security_scan }}
        run: |
          echo "Running security scan..."
          echo "No critical vulnerabilities found."

      - name: Deploy Application
        run: |
          echo "Deploying ${{ inputs.application_name }}"
          echo "Desired Replicas: ${{ inputs.replicas }}"

      - name: Deployment Complete
        run: |
          echo "Deployment completed successfully."
```

#### Explanation

```yaml
name: Reusable Deployment Workflow
```

* This block defines the **workflow name** displayed inside the GitHub Actions UI.
* The name helps engineers identify reusable workflow executions when reviewing workflow history.
* Clear workflow names become increasingly important as organizations create reusable workflows for deployment, security, testing, compliance, and platform automation.
* A reusable workflow is still a workflow and appears in GitHub Actions execution history like any other workflow.

> **Production Insight:** Platform engineering teams often maintain dozens of reusable workflows for common organizational processes. Consistent naming conventions make them easier to discover, maintain, and govern.

---

```yaml
on:
  workflow_call:
```

* This block defines the reusable workflow trigger.
* Unlike **`workflow_dispatch`**, this workflow cannot be started directly by a user.
* The workflow executes only when another workflow invokes it.
* GitHub automatically makes the inputs supplied by the calling workflow available through the **`inputs`** context.

> **Important:** Think of **`workflow_dispatch`** as "user-to-workflow communication" and **`workflow_call`** as "workflow-to-workflow communication."

> **Production Insight:** Reusable workflows are a foundational building block for **Platform Engineering** because they allow organizations to enforce common standards across hundreds of repositories from a single centrally managed workflow.

---

```yaml
inputs:
  application_name:
    required: true
    type: string

  run_security_scan:
    required: true
    type: boolean

  replicas:
    required: true
    type: number
```

* This block defines the **Reusable Workflow Inputs**.
* These inputs act as the contract between the calling workflow and the reusable workflow.
* The calling workflow must provide values for all required inputs before the reusable workflow can execute.
* GitHub validates the supplied values before workflow execution begins.

Input summary:

| Input               | Type    | Purpose                               |
| ------------------- | ------- | ------------------------------------- |
| `application_name`  | string  | Application being deployed            |
| `run_security_scan` | boolean | Enable or disable security validation |
| `replicas`          | number  | Desired deployment replica count      |

> **Production Insight:** Reusable workflows often define organization-specific contracts that include inputs such as **application name**, **environment**, **change ticket**, **region**, **cost center**, **deployment strategy**, and **approval identifiers**.

---

```yaml
jobs:
  deploy-application-job:
```

* This block creates the reusable workflow job.
* All deployment activities execute inside this job.
* The job receives values from the calling workflow through the **`inputs`** context.
* Because the logic is centralized, multiple repositories can reuse the same deployment process.

> **Production Insight:** Centralizing deployment logic significantly reduces maintenance effort because deployment improvements are implemented once and automatically become available to all consuming repositories.

---

```yaml
- name: Display Deployment Parameters
  run: |
    echo "Application: ${{ inputs.application_name }}"
    echo "Run Security Scan: ${{ inputs.run_security_scan }}"
    echo "Replicas: ${{ inputs.replicas }}"
```

* This step displays the values received from the **calling workflow** through the **Reusable Workflow Inputs**.
* It confirms that GitHub successfully passed the input values from the calling workflow to the reusable workflow.
* During troubleshooting, this information helps verify exactly which deployment parameters were supplied for a particular execution.
* In this example, the step displays the **application name**, whether a **security scan** should execute, and the desired **replica count**.

> **Operational Tip:** Logging important **runtime parameters** at the beginning of a reusable workflow can significantly simplify **troubleshooting**, **change reviews**, and **audit investigations**. Many organizations intentionally record deployment metadata such as **application names**, **environments**, **versions**, **regions**, and **deployment strategies** for operational visibility.

---

```yaml
- name: Security Validation
  if: ${{ inputs.run_security_scan }}
  run: |
    echo "Running security scan..."
    echo "No critical vulnerabilities found."
```

* This step simulates a **security validation** stage within the deployment process.
* Execution is controlled by the **`run_security_scan`** input received from the calling workflow.
* If the calling workflow passes **`true`**, the security validation executes; otherwise, the step is skipped.
* This demonstrates how reusable workflows can dynamically alter their behavior based on values supplied by consuming workflows.

> **Production Insight:** Security validation is commonly centralized inside reusable workflows so that all applications follow a consistent security process. This helps platform teams enforce organizational standards without relying on individual application teams to implement security checks independently.

---

```yaml
- name: Deploy Application
  run: |
    echo "Deploying ${{ inputs.application_name }}"
    echo "Desired Replicas: ${{ inputs.replicas }}"
```

* This step simulates deployment of the application.
* The deployment behavior is influenced by values received through the **Reusable Workflow Inputs**.
* The **`application_name`** input identifies which application is being deployed, while **`replicas`** determines the desired scale of the deployment.
* This demonstrates how a single reusable workflow can support multiple applications while still allowing application-specific deployment parameters.

> **Production Insight:** In real-world environments, this step could perform **Helm deployments**, **Kubernetes manifest updates**, **Argo CD synchronizations**, **Terraform executions**, or deployments to cloud-native services. The deployment mechanism remains centralized while deployment parameters vary between applications.

---

```yaml
- name: Deployment Complete
  run: |
    echo "Deployment completed successfully."
```

* This step represents successful completion of the deployment process.
* It provides a clear end point for the reusable workflow execution.
* Completion steps are commonly used to record deployment status, publish deployment metadata, or trigger downstream automation.
* In this demo, the step simply confirms that all deployment activities completed successfully.

> **Production Insight:** Production deployment workflows often perform additional activities after deployment such as **deployment notifications**, **audit logging**, **change management updates**, **release tracking**, **monitoring integration**, or **post-deployment validation** before marking a deployment as complete.


---

### Step 2: Creating the Calling Workflow

Create the following file:

**`.github/workflows/payment-service-deployment.yaml`**

```yaml
name: Payment Service Deployment

on:
  workflow_dispatch:
  push:

jobs:
  run-unit-tests-job:
    runs-on: ubuntu-latest

    steps:
      - name: Execute Unit Tests
        run: |
          echo "Running payment service unit tests..."
          echo "All tests passed."

  build-payment-artifacts-job:
    runs-on: ubuntu-latest

    needs:
      - run-unit-tests-job

    steps:
      - name: Build Payment Artifacts
        run: |
          echo "Building payment service artifacts..."
          echo "Artifacts generated successfully."

  deploy-payment-service-job:
    needs:
      - build-payment-artifacts-job

    uses: ./.github/workflows/deploy.yaml

    with:
      application_name: payment-service
      run_security_scan: true
      replicas: 5
```

> **Understanding Job and Step Execution:** As discussed in previous lectures, **jobs run in parallel by default**, with each job executing on its own independent runner. When you introduce the **`needs`** keyword, you create dependencies between jobs and define the order in which they should execute.
>
> Within a job, **steps execute sequentially by default** in the exact order they are defined.
>
> By default, if a **step fails**, the remaining steps in that job are skipped and the job is marked as **failed**. Similarly, if a **job fails**, any downstream jobs that depend on it through **`needs`** are skipped and do not execute. However, GitHub Actions also provides functions such as **`always()`**, which can be used to execute specific steps or jobs regardless of the success or failure of earlier execution stages.
>
> This behavior helps prevent invalid artifacts, failed validations, or unsuccessful deployments from progressing further through the CI/CD pipeline.
>
> For example:
>
> ```text
> Run Unit Tests
>        ↓
> Build Artifacts
>        ↓
> Deploy Application
> ```
>
> If **Run Unit Tests** fails, then **Build Artifacts** and **Deploy Application** will not execute. Likewise, if a step inside **Build Artifacts** fails, the remaining steps in that job are skipped and the deployment job will never start. An exception would be a step or job configured with **`always()`**, which would still execute.
>
> > **Production Insight:** This fail-fast behavior is one of the key reasons CI/CD pipelines are reliable. Problems are detected early and prevented from propagating to later stages such as packaging, publishing, or production deployment, while **`always()`** is commonly used for cleanup, notifications, log collection, and reporting activities.


---

#### Explanation

```yaml
name: Payment Service Deployment
```

* This block defines the **workflow name** displayed inside the **GitHub Actions UI**.
* The name helps engineers identify the purpose of the workflow when reviewing workflow history or monitoring workflow executions.
* In this example, the workflow is responsible for deploying the **payment-service** application.
* Clear workflow names become increasingly important as repositories grow and contain multiple automation workflows.

> **Operational Tip:** Production repositories often contain separate workflows for **CI**, **CD**, **security scanning**, **dependency management**, **release automation**, and **operational tasks**. Meaningful workflow names help engineers quickly identify the correct workflow during troubleshooting and operational activities.

---

```yaml
on:
  workflow_dispatch:
  push:
```

* This block defines the workflow triggers.
* The workflow can execute either when a user manually starts it from the **GitHub Actions UI** using **`workflow_dispatch`** or when code is pushed to the repository using the **`push`** event.
* Supporting multiple triggers allows the same workflow to be reused across different operational scenarios without requiring separate workflow definitions.
* Regardless of how the workflow is triggered, GitHub executes the jobs defined within the workflow and eventually invokes the reusable deployment workflow.

> **Production Insight:** It is common for organizations to support both **automated** and **manual** execution paths. For example, a **deployment workflow** may execute automatically after a successful code push while also allowing engineers to manually trigger deployments, rollbacks, maintenance activities, or emergency operational procedures when required.

> **Important:** Reusable workflows are **independent of the trigger mechanism** used by the calling workflow. A calling workflow may be triggered by **`workflow_dispatch`**, **`push`**, **`pull_request`**, **`release`**, **`schedule`**, or any other supported GitHub Actions event. Once triggered, it can invoke the reusable workflow and pass the required inputs.


---

```yaml
jobs:
  run-unit-tests-job:
```

* This block creates the first workflow job named **`run-unit-tests-job`**.
* The purpose of this job is to validate the application before any build or deployment activities occur.
* Unit testing helps identify defects early in the software delivery process.
* This job represents **application-specific logic** owned and maintained by the application team.

> **Production Insight:** Unit tests are typically one of the earliest quality gates in a CI/CD pipeline because they provide fast feedback and help prevent defective code from progressing further through the delivery process.

---

```yaml
runs-on: ubuntu-latest
```

* This block instructs GitHub Actions to allocate a **GitHub-hosted Ubuntu runner** for the job.
* All steps within the job execute inside this runner environment.
* Each job receives a fresh and isolated runner environment.
* The runner provides the execution environment required to perform CI/CD activities.

> **Operational Note:** Because each job receives its own runner, files and artifacts created in one job are not automatically available in another job unless they are explicitly shared using artifacts, caches, outputs, or external storage mechanisms.

---

```yaml
- name: Execute Unit Tests
  run: |
    echo "Running payment service unit tests..."
    echo "All tests passed."
```

* This step simulates execution of unit tests for the payment service.
* The goal is to verify that the application's internal logic behaves as expected before proceeding further.
* In a real-world application, this step would execute framework-specific test commands rather than simple echo statements.
* Successful completion indicates that the application is ready for the next stage of the delivery process.

> **Production Insight:** Mature engineering teams often enforce minimum **test coverage**, **quality gates**, and **pull request validation requirements** before deployments are allowed to proceed.

---

```yaml
jobs:
  build-payment-artifacts-job:
```

* This block creates the second workflow job responsible for generating deployment artifacts.
* The job executes after successful completion of the unit testing phase.
* Building artifacts separately helps create a clear separation between testing and packaging responsibilities.
* This job also represents **application-specific logic** owned by the application team.

> **Production Insight:** Common deployment artifacts include **Docker images**, **JAR files**, **WAR files**, **ZIP packages**, **Helm charts**, and other deployable application bundles.

---

```yaml
needs:
  - run-unit-tests-job
```

* This block creates a dependency between jobs using the **`needs`** keyword.
* GitHub will not start this job until **`run-unit-tests-job`** completes successfully.
* If the unit testing job fails, this job is skipped automatically.
* This helps enforce a logical execution sequence within the workflow.

> **Important:** The **`needs`** keyword creates **job-level dependencies**, not step-level dependencies. Steps within a job already execute sequentially by default.

> **Production Insight:** Organizations commonly use **`needs`** to create delivery pipelines such as **Build → Test → Security Scan → Package → Deploy**, ensuring each stage succeeds before the next stage begins.

---

```yaml
- name: Build Payment Artifacts
  run: |
    echo "Building payment service artifacts..."
    echo "Artifacts generated successfully."
```

* This step simulates generation of deployment artifacts.
* Artifacts represent the output of the build process and are typically consumed during deployment.
* Separating artifact creation from deployment helps improve traceability and reuse.
* In this demo, the step uses placeholder commands for simplicity.

> **Production Insight:** Organizations commonly follow the **Build Once, Deploy Many** principle, where a single validated artifact is promoted through Dev, QA, Stage, and Production environments without rebuilding the application.

---

```yaml
jobs:
  deploy-payment-service-job:
```

* This block creates the third workflow job responsible for deployment activities.
* Rather than implementing deployment logic directly, this job delegates deployment responsibilities to a reusable workflow.
* This approach promotes standardization and reduces duplication across repositories.
* The job acts as the bridge between application-specific logic and shared organizational deployment standards.

> **Production Insight:** Platform engineering teams often encourage application teams to consume centrally managed deployment workflows instead of maintaining deployment logic independently in every repository.

---

```yaml
needs:
  - build-payment-artifacts-job
```

* This block ensures that deployment cannot begin until artifact generation completes successfully.
* GitHub evaluates the dependency before scheduling the deployment job.
* If artifact generation fails, deployment never starts.
* This helps prevent incomplete or invalid artifacts from reaching downstream environments.

> **Operational Note:** Chaining jobs using **`needs`** allows organizations to create predictable and auditable delivery pipelines with clearly defined execution stages.

---

```yaml
uses: ./.github/workflows/deploy.yaml
```

* This block invokes the reusable workflow defined in **`deploy.yaml`**.
* Instead of executing steps directly, GitHub transfers control to the reusable workflow.
* The reusable workflow contains centralized deployment logic shared across multiple applications and repositories.
* This is the core mechanism that enables workflow reuse in GitHub Actions.

> **Production Insight:** Large organizations often maintain reusable workflows for **deployments**, **security scanning**, **compliance validation**, **testing**, **release management**, and other common automation activities.

---

```yaml
with:
  application_name: payment-service
  run_security_scan: true
  replicas: 5
```

* This block passes values from the calling workflow into the reusable workflow.
* These values become available through the **`inputs`** context inside the reusable workflow.
* Each input influences how the reusable workflow behaves during execution.
* This allows the same reusable workflow to support multiple applications and deployment scenarios.

Input summary:

| Input                 | Purpose                                         |
| --------------------- | ----------------------------------------------- |
| **application_name**  | Identifies the application being deployed       |
| **run_security_scan** | Determines whether security validation executes |
| **replicas**          | Specifies the desired deployment replica count  |

> **Production Insight:** This pattern is one of the primary reasons reusable workflows are so powerful. Organizations can centralize deployment logic while still allowing application teams to provide application-specific values such as **environment**, **version**, **region**, **replica count**, **deployment strategy**, or **approval identifiers**.

---

### Step 3: Commit and Push the Changes

Commit both workflow files and push them to GitHub.

```bash
# Add all workflow files and related changes to the Git staging area
git add .

# Create a commit containing the Reusable Workflow Inputs demo implementation
git commit -m "feat: add reusable workflow inputs demo"

# Associate the local repository with the remote GitHub repository (one-time setup)
git remote add origin git@github.com:CloudWithVarJosh/cwvj-gha-practice.git

# Push the code to GitHub and configure the local branch to track origin/main
git push -u origin main
```

Because the calling workflow is configured with:

```yaml
on:
  workflow_dispatch:
  push:
```

the workflow automatically executes when code is pushed to the repository.

The workflow can also be executed manually from the **GitHub Actions UI** using the **Run Workflow** button.

> **Git Best Practice:** Many organizations follow the **Conventional Commits** specification, where prefixes such as **`feat:`**, **`fix:`**, **`docs:`**, **`refactor:`**, and **`chore:`** help standardize commit history and enable automated release workflows. We will revisit this topic later when discussing **release automation**, **semantic versioning**, and **automated changelog generation**.

> **Key Observation:** The reusable workflow is not triggered directly. GitHub first executes the **calling workflow**, which then invokes the reusable workflow using the **`uses:`** keyword.


---

### Step 4: Observe and Verify Workflow Execution

Navigate to:

```text
GitHub Repository
        ↓
Actions
        ↓
Payment Service Deployment
```

**Verify Job Execution Order**

Confirm that jobs execute in the following sequence:

```text
run-unit-tests-job
          ↓
build-payment-artifacts-job
          ↓
deploy-payment-service-job
          ↓
Reusable Deployment Workflow
          ↓
deploy-application-job
```

This demonstrates how the **`needs`** keyword controls job execution order.

---

**Verify Unit Testing Stage**

Expected output:

```text
Running payment service unit tests...
All tests passed.
```

---

**Verify Artifact Generation Stage**

Expected output:

```text
Building payment service artifacts...
Artifacts generated successfully.
```

---

**Verify Reusable Workflow Invocation**

Confirm that the deployment job invokes:

```yaml
uses: ./.github/workflows/deploy.yaml
```

rather than executing deployment steps directly.

---

**Verify Input Propagation**

Expected output:

```text
Application: payment-service
Run Security Scan: true
Replicas: 5
```

This confirms that **Reusable Workflow Inputs** were successfully passed from the calling workflow to the reusable workflow.

---

**Verify Conditional Security Validation**

Expected output:

```text
Running security scan...
No critical vulnerabilities found.
```

This step executes because:

```yaml
run_security_scan: true
```

was supplied by the calling workflow.

---

**Verify Deployment Stage**

Expected output:

```text
Deploying payment-service
Desired Replicas: 5
```

This demonstrates how the reusable workflow consumes input values supplied by the calling workflow.

---

**Verify Successful Workflow Completion**

Expected output:

```text
Deployment completed successfully.
```

This confirms that both the **calling workflow** and the **reusable workflow** completed successfully.

> **Key Observation:** The calling workflow contains **application-specific logic**, while the reusable workflow contains **shared organizational logic**. **Reusable Workflow Inputs** act as the bridge between the two workflows, allowing platform teams to centralize common automation while application teams provide application-specific values.

---

## Conclusion

Inputs are one of the foundational building blocks of GitHub Actions. They allow workflows, reusable workflows, and actions to receive runtime values and adjust their behavior dynamically.

In this lecture, we explored **Workflow Inputs**, **Reusable Workflow Inputs**, and **Action Inputs**, along with practical demonstrations of how they are used in production-style automation.

The key takeaway is simple:

```text
Inputs provide data
        ↓
Workflows consume data
        ↓
Behavior changes dynamically
```

As we continue through the course, Inputs will be combined with **Variables**, **Contexts**, **Expressions**, **Functions**, and **Custom Actions** to build increasingly sophisticated and reusable automation platforms.

---

## References

**GitHub Actions Documentation:** https://docs.github.com/en/actions
**Workflow Inputs (`workflow_dispatch`):** https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_dispatch
**Reusable Workflows (`workflow_call`):** https://docs.github.com/en/actions/using-workflows/reusing-workflows
**Expressions:** https://docs.github.com/en/actions/learn-github-actions/expressions
**Functions:** https://docs.github.com/en/actions/learn-github-actions/expressions#functions
**Contexts:** https://docs.github.com/en/actions/learn-github-actions/contexts
**Variables:** https://docs.github.com/en/actions/learn-github-actions/variables
**GitHub Actions Marketplace:** https://github.com/marketplace?type=actions

---
