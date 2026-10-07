# GitHub Actions Artifacts & Caching Explained | Share Files & Optimize Builds

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/tw9e61Bct-E/maxresdefault.jpg)](https://www.youtube.com/watch?v=tw9e61Bct-E&ab_channel=CloudWithVarJosh)

---

## ⭐ Support the Project  

If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

- [Introduction](#introduction)  
- [Why & What of Artifacts](#why--what-of-artifacts)  
  - [Why Artifacts?](#why-artifacts)  
  - [What are Artifacts?](#what-are-artifacts)  
  - [**Demo 1:** Sharing Files Across Jobs Using Artifacts](#demo-1-sharing-files-across-jobs-using-artifacts)  
    - [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication)  
    - [Step 2: Preparing the Application and Supporting Components](#step-2-preparing-the-application-and-supporting-components)  
    - [Step 3: Creating the Workflow](#step-3-creating-the-workflow)  
         - [Workflow Explanation](#explanation)  
         - [Common Testing Flow in CI/CD Pipelines](#common-testing-flow-in-cicd-pipelines)  
         - [Artifact Retention](#artifact-retention)  
    - [Step 4: Commit and Push the Changes](#step-4-commit-and-push-the-changes)  
    - [Step 5: Running the Workflow](#step-5-running-the-workflow)  
    - [Step 6: Observing Workflow Execution](#step-6-observing-workflow-execution)  
- [Why & What of Caching](#why--what-of-caching)  
  - [Why Caching?](#why-caching)  
  - [What is Caching?](#what-is-caching)  
  - [**Demo 2:** Reusing Dependencies Across Jobs Using Caching](#demo-2-reusing-dependencies-across-jobs-using-caching)  
    - [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication-1)  
    - [Step 2: Preparing the Application and Supporting Components](#step-2-preparing-the-application-and-supporting-components-1)  
    - [Step 3: Creating the Workflow](#step-3-creating-the-workflow-1)  
      - [Workflow Explanation](#workflow-explanation-1)  
      - [What are Restore Keys?](#what-are-restore-keys)  
      - [Cache Retention](#cache-retention)  
    - [Step 4: Commit and Push the Changes](#step-4-commit-and-push-the-changes-1)  
    - [Step 5: Running the Workflow](#step-5-running-the-workflow-1)  
    - [Step 6: Observing Workflow Execution](#step-6-observing-workflow-execution-1)  
- [Conclusion](#conclusion)  
- [References](#references)  

---

## Introduction

In the previous lectures, we learned how **GitHub Actions Outputs** enable us to share small pieces of runtime metadata such as **deployment URLs**, **versions**, and **resource identifiers** between steps, jobs, and workflows.

In this lecture, we build upon that foundation by exploring two of the most widely used capabilities in modern CI/CD pipelines: **Artifacts** and **Caching**.

Although both involve storing files in **GitHub-managed storage**, they solve very different problems. **Artifacts** preserve and share **workflow-generated files**, while **Caches** store **reusable dependencies and frequently used files** to improve workflow performance.

Throughout this lecture, we will understand **why these features exist**, **how they work internally**, and **when to use each one**. We will then reinforce these concepts through two hands-on demos that demonstrate how Artifacts enable file sharing across jobs and how Caching significantly reduces workflow execution time by reusing previously downloaded dependencies.

By the end of this lecture, you will clearly understand the differences between **Outputs**, **Artifacts**, and **Caching**, and know how each contributes to building efficient, production-ready GitHub Actions workflows.

---

## Why & What of Artifacts?

![Alt text](/images/8a.png)

### Why Artifacts?

In the previous lecture, we learned how **Outputs** allow information to be shared between **steps**, **jobs**, and **workflows**. Outputs are excellent for sharing runtime-generated metadata such as **deployment URLs**, **release versions**, **resource identifiers**, **environment names**, and other small pieces of information.

However, modern CI/CD pipelines generate much more than just metadata.

Consider the following scenarios:

* A build job generates a compiled **application package**.
* A test job produces detailed **test reports** and code **coverage reports**.
* A security scanning job generates vulnerability reports and Software Bill of Materials (**SBOM**) files.
* A deployment job generates deployment logs, audit records, and deployment manifests.
* A data processing job creates large CSV, JSON, PDF, or Excel files.
* A UI testing job generates screenshots and execution recordings for failed test cases.
* An **MLOps** pipeline generates trained **ML models**, model evaluation reports, performance metrics, and validation reports.
* An **LLMOps** pipeline generates prompt evaluation reports, benchmark results, inference logs, and Retrieval-Augmented Generation (**RAG**) evaluation reports.

In these scenarios, the workflow is generating actual files such as:

```text
application.jar
coverage-report.html
test-results.xml
security-scan.json
sbom.json
deployment.log
model.pkl
model.onnx
metrics.json
evaluation-report.json
prompt-evaluation.json
rag-evaluation.json
inference.log
```

The question becomes:

***How can these files be shared with other jobs or downloaded after the workflow completes?***

Consider the following workflow:

```text
Build Job: Creates application.jar
Test Job: Requires application.jar
Deployment Job: Requires application.jar
```

A common challenge immediately appears:

* How can **downstream jobs** access files generated by previous jobs?
* How can **workflow-generated files** be downloaded after the workflow completes?
* How can build outputs be preserved for **troubleshooting**, **auditing**, and **compliance purposes**?
* How can generated reports be shared with **engineers**, **stakeholders**, and **deployment pipelines**?
* How can the same deployment package be reused across multiple jobs without rebuilding it repeatedly?

The challenge becomes even more significant because **GitHub Actions runners are ephemeral**.

Consider the lifecycle of a typical runner:

```text
Job Starts → Runner Created
Job Executes → Files Generated
Job Completes → Runner Destroyed
```

Once the runner is destroyed, **any files that exist only on that runner are lost**.

This creates a significant problem because build outputs, test reports, security reports, deployment logs, generated documentation, screenshots, and other workflow-generated files often need to remain available long after the job that created them has finished executing.

For example:

```text
Build Job: Creates application.jar
Job Completes → Runner Destroyed
Deployment Job: Still Needs application.jar
```

Or:

```text
Test Job: Generates coverage-report.html
Job Completes → Runner Destroyed
Engineer: Needs coverage-report.html for analysis
```

Without a mechanism to preserve these files, every downstream process would lose access to information generated during earlier stages of the pipeline.

> **Key Observation:** Many CI/CD workflows generate files that must survive beyond the job and runner that created them. These files may need to be consumed by downstream jobs, downloaded by engineers, reviewed during troubleshooting activities, retained for compliance purposes, or reused by deployment processes.
>
> GitHub Actions solves these challenges through **Artifacts**, which we will explore next.


---

### What are Artifacts?

Artifacts are **files or directories generated during a workflow run that GitHub Actions stores and makes available after execution**.

Think of an Artifact as a package containing **workflow-generated files** that GitHub Actions preserves outside the runner's temporary filesystem.

When a workflow executes, GitHub Actions provisions one or more **runners** to perform the required tasks. During execution, these runners may generate various files such as **application packages**, **test reports**, **deployment manifests**, **security scan reports**, **screenshots**, **log files**, or **generated documentation**.

By default, these files exist only on the runner that created them. To make them available after the job completes, GitHub Actions allows them to be uploaded as **Artifacts**.

Once uploaded:

* GitHub Actions stores the files and associates them with the **workflow run**.
* The files remain available even after the original **runner has been destroyed**.
* **Downstream jobs** can download and consume the files.
* Engineers can download the files directly from the **GitHub Actions UI**.
* The files can be retained for a configurable period and used for **troubleshooting**, **auditing**, **reporting**, and **compliance activities**.

Conceptually:

```text
Workflow Creates File → Upload Artifact → GitHub Stores File → Other Jobs or Users Access File
```

Artifacts are commonly used to store and transfer:

* **Application packages**, **deployment manifests**, **Helm charts**, **Terraform plans**, and other deployment deliverables.
* **Test reports**, **code coverage reports**, **screenshots**, and **execution recordings** generated during testing.
* **Security scan reports**, **vulnerability assessments**, **SBOMs**, and compliance-related outputs.
* **Log files**, **generated documentation**, **audit records**, and other workflow-generated files that need to be preserved beyond the job that created them.

One of the most common Artifact workflows in production CI/CD pipelines looks like:

```text
Build Job: Creates application.jar → Uploads Artifact
Test Job: Downloads Artifact → Runs Tests
Deployment Job: Downloads Artifact → Deploys Application
```

Notice that each job may execute on a completely different **runner**. Artifacts provide the mechanism that allows all jobs to access the same files without rebuilding or regenerating them.

Artifacts can also be consumed by humans, not just workflows.

For example:

* An engineer may download a **failed test report** to investigate a pipeline failure.
* A security team may download a **vulnerability assessment report** for review.
* An operations team may download **deployment logs** while troubleshooting a production issue.
* An auditor may download **compliance evidence** generated during a release process.

> **Mental Model:** Artifacts can be thought of as **temporary file storage provided by GitHub Actions for workflow-generated files**.
>
> ```text
> Workflow Creates File → Upload Artifact → GitHub Stores File → Other Jobs or Users Access File
> ```
>
> Unlike local runner storage, Artifacts survive beyond the job that created them and can be accessed by both **downstream automation** and **human users**.

> **Best Practice:** GitHub Actions Artifacts should be viewed as temporary storage for workflow-generated files rather than a permanent artifact repository. While they are ideal for sharing files between jobs and retaining outputs for troubleshooting or auditing, production-ready artifacts intended for long-term storage and distribution are typically published to dedicated artifact repositories such as **JFrog Artifactory**, **Sonatype Nexus Repository**, or cloud-native services like **AWS CodeArtifact**.


> **Note:** Artifacts can be accessed at different levels of a GitHub Actions workflow:
>
> * **Steps:** Technically possible, but rarely required since all steps within the same job execute on the **same runner** and share the same workspace and filesystem. In most cases, subsequent steps can access files directly without uploading or downloading an Artifact.
> * **Jobs:** The **primary** use case. Artifacts allow files generated by one job to be shared with downstream jobs, which may execute on different runners.
> * **Workflow runs:** Supported. Artifacts uploaded during one workflow run can be downloaded and consumed by another workflow run, provided the artifact is still available within its configured retention period.

---

## Demo 1: Sharing Files Across Jobs Using Artifacts

In this demo, we will learn how **Artifacts** can be used to preserve and transfer files generated during workflow execution.

More specifically, we will:

* build and run a containerized Flask application
* generate workflow-produced files such as **smoke test reports** and **application logs**
* upload those files as **Artifacts**
* download the Artifacts in a downstream job
* consume and review the downloaded files

By the end of this demo, you will understand how Artifacts enable **file sharing across jobs**, **preservation of workflow-generated files**, and **access to files after workflow execution completes**.

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

### Step 2: Preparing the Application and Supporting Components

Before creating the workflow, we first need an **application** and the supporting components required by the pipeline.

In this step, we will:

* create a simple **Flask application**
* containerize the application using **Docker**
* prepare the files required by the workflow that we will build later

By the end of this step, we will have everything required to generate the files that will eventually be uploaded and downloaded as **Artifacts**.

We will create a small **containerized Python application** using the **Flask framework**.

For simplicity, place all files under a directory called:

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
        └── 01-artifacts-demo.yaml
```

> **Why are we creating all of these components?**
>
> A typical CI/CD pipeline requires more than just application source code. It also requires a **container image definition**, application dependencies, and workflow definitions that automate build, test, and deployment activities.
>
> Together, these components form the foundation of the Artifact workflow we will build in the next step.

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

##### Understanding the Application

This application:

* creates a lightweight **Flask web server**
* exposes an application endpoint at **`/`**
* exposes a health-check endpoint at **`/health`**
* listens on port **`5000`**
* runs inside a **Docker container**

The application also generates simple runtime logs:

```text
Cloud With VarJosh Flask Application Started
Home endpoint invoked
Health endpoint invoked
```

These logs will become useful later in the demo when we generate and upload **Artifact files**.

The **`/health`** endpoint is especially important because production CI/CD pipelines commonly use:

* health endpoints
* smoke tests
* readiness validation
* liveness checks

to validate successful application startup.

---

##### Optional Deep Dive

* `from flask import Flask, jsonify` imports the Flask framework and the `jsonify` helper used for returning JSON responses.

* `import os` imports Python's operating system module. It is used here to read environment variables such as `PORT`.

* `app = Flask(__name__)` creates the Flask application object which acts as the main web application instance.

* `print("Cloud With VarJosh Flask Application Started")` generates a startup log message when the application launches.

* `@app.get("/")` defines an HTTP GET endpoint for the root path `/`.

* `print("Home endpoint invoked")` generates a log entry whenever the root endpoint is accessed.

* `jsonify(...)` converts Python objects into valid JSON HTTP responses.

* `@app.get("/health")` defines a health-check endpoint used to validate successful application startup and runtime health.

* `print("Health endpoint invoked")` generates a log entry whenever the health endpoint is accessed.

* `return jsonify(status="healthy"), 200` returns a JSON response with HTTP status code `200`, indicating successful application health.

* `host="0.0.0.0"` allows the application to listen on all network interfaces inside the container.

* `port=int(os.getenv("PORT", 5000))` reads the port value from the `PORT` environment variable. If the variable is not defined, Flask defaults to port `5000`.

> **Operational Note:** Production CI/CD pipelines commonly use health-check endpoints such as `/health` for smoke testing, readiness validation, liveness checks, monitoring systems, and automated deployment validation workflows.

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

#### Understanding the Dockerfile

* `FROM python:3.13-slim` uses the official lightweight Python 3.13 base image and provides the runtime required to execute the Flask application.

* `WORKDIR /app` sets `/app` as the working directory inside the container. Subsequent instructions execute relative to this directory.

* `COPY requirements.txt .` copies the dependency file into the container image.

* `RUN pip install --no-cache-dir -r requirements.txt` installs the Python dependencies required by the application. The `--no-cache-dir` flag prevents pip from storing package cache files inside image layers, helping reduce image size.

* `COPY app.py .` copies the Flask application source code into the image.

* `EXPOSE 5000` documents that the application listens on port `5000`.

* `CMD ["python", "app.py"]` defines the default startup command executed when the container starts.

> **Operational Note:** GitHub-hosted Ubuntu runners already include Docker. This allows workflows to directly build and run containers during workflow execution.

---

### Step 2.3: Create the Requirements File

Create the following dependency file:

**`requirements.txt`**

```text
flask==3.1.1
```

#### Understanding the Requirements File

This file defines the Python dependencies required by the application.

In this demo, we are using **Flask**, which is a lightweight Python web framework commonly used for:

* REST APIs
* microservices
* backend applications
* lightweight web applications

The line:

```text
flask==3.1.1
```

instructs Python to install:

* the **Flask** package
* specifically version **`3.1.1`**

Pinning dependency versions is considered a good practice because it helps ensure consistent behavior across developer machines, CI/CD pipelines, testing environments, and production deployments.

> **Operational Note:** The `requirements.txt` file provides a standardized way of defining Python dependencies. This allows developers, CI/CD pipelines, and container images to install the same dependency versions across different environments, improving reproducibility and reducing deployment-related issues.

---

### Step 3: Creating the Workflow

Create the following workflow file:

**`.github/workflows/01-artifacts-demo.yaml`**

```yaml
name: 01 - Artifacts Demo

on:
  workflow_dispatch:

jobs:
  flask-ci-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Build Docker Image
        uses: docker/build-push-action@v7
        with:
          context: .
          push: false
          tags: cwvj-flask-app:v1.0.1

      - name: Run Container
        run: |
          docker run -d \
            -p 5000:5000 \
            --name cwvj-flask-container \
            cwvj-flask-app:v1.0.1

      - name: Generate Smoke Test Report
        run: |
          sleep 5
          curl http://localhost:5000 > smoke-test-report.txt
          curl http://localhost:5000/health >> smoke-test-report.txt

      - name: Export Container Logs
        run: |
          docker logs cwvj-flask-container > container-logs.txt

      - name: Upload Artifacts
        uses: actions/upload-artifact@v7
        with:
          name: flask-ci-artifacts
          path: |
            smoke-test-report.txt
            container-logs.txt

  review-job:
    runs-on: ubuntu-latest

    needs:
      - flask-ci-job

    steps:
      - name: Download Artifacts
        uses: actions/download-artifact@v8
        with:
          name: flask-ci-artifacts

      - name: Review Downloaded Artifacts
        run: |
          echo "===== Smoke Test Report ====="
          cat smoke-test-report.txt

          echo ""
          echo "===== Container Logs ====="
          cat container-logs.txt
```

#### Explanation

```yaml
name: 01 - Artifacts Demo
```

* This block defines the **workflow name** displayed in the **GitHub Actions UI**.
* The name does not affect workflow behavior or execution logic.
* It helps engineers quickly identify workflow runs while reviewing execution history, troubleshooting failures, monitoring CI/CD pipelines, and validating workflow outcomes.

> **Operational Tip:** Production repositories often contain numerous workflows supporting CI, CD, security scanning, compliance validation, infrastructure automation, dependency management, and operational activities. Meaningful workflow names make troubleshooting and day-to-day operations significantly easier.

---

```yaml
on:
  workflow_dispatch:
```

* This block defines the workflow trigger.
* The workflow executes only when a **`workflow_dispatch`** event is generated.
* This can occur when a user manually starts the workflow from the **GitHub Actions UI**, invokes the **Workflow Dispatch API**, or triggers the workflow through tools such as the **GitHub CLI (`gh`)**.
* Using **`workflow_dispatch`** allows us to focus entirely on Artifact functionality without requiring repository changes.

> **Production Insight:** Manual workflows are commonly used for production deployments, rollback operations, maintenance activities, disaster recovery procedures, and operational tasks that require human decision-making before execution begins.

---

```yaml
jobs:
  flask-ci-job:
    runs-on: ubuntu-latest

    steps:
      ...
```

* This block defines the **`flask-ci-job`** job.
* The job executes on a **GitHub-hosted Ubuntu runner**.
* Its responsibility is to build and run the application, generate workflow-produced files, and upload those files as Artifacts.
* All steps within the job execute sequentially because they belong to the same job.

> **Operational Note:** GitHub-hosted runners are **ephemeral**. When a job completes, the runner and all files stored on its filesystem are automatically destroyed.

---

```yaml
- name: Checkout Repository
  uses: actions/checkout@v6
```

* This step downloads the repository contents onto the runner.
* Without this step, the workflow would not have access to the application source code, Dockerfile, requirements file, or other repository assets.
* Most CI/CD pipelines execute this step near the beginning because subsequent steps typically require repository files.

> **Production Insight:** Workflows often check out multiple repositories, including application repositories, GitOps repositories, Infrastructure-as-Code repositories, Helm chart repositories, and platform engineering repositories.

---

```yaml
- name: Build Docker Image
  uses: docker/build-push-action@v7
  with:
    context: .
    push: false
    tags: cwvj-flask-app:v1.0.1
```

* This step builds the Docker image for the Flask application.
* The **`docker/build-push-action`** action performs the image build operation.
* The **`context`** parameter specifies the build context, which in this case is the repository root directory.
* The **`push: false`** configuration instructs Docker not to push the image to a container registry.
* The resulting image is tagged as:

```text
cwvj-flask-app:v1.0.1
```

* The image remains available locally on the runner and is used by subsequent workflow steps.

> **Key Observation:** Although this demo focuses on Artifacts, we still need a realistic application workload that can generate files. The Docker image provides the runtime environment required for the Flask application.

---

```yaml
- name: Run Container
  run: |
    docker run -d \
      -p 5000:5000 \
      --name cwvj-flask-container \
      cwvj-flask-app:v1.0.1
```

* This step starts the Flask application inside a Docker container.
* The **`-d`** flag runs the container in detached mode.
* The **`-p 5000:5000`** configuration maps port **5000** on the runner to port **5000** inside the container.
* The container is assigned the name:

```text
cwvj-flask-container
```

* Once started, the application becomes accessible through:

```text
http://localhost:5000
```

> **Production Insight:** Many CI/CD pipelines validate that an application can successfully start before proceeding to deployment, packaging, or release activities.

---

```yaml
- name: Generate Smoke Test Report
  run: |
    sleep 5
    curl http://localhost:5000 > smoke-test-report.txt
    curl http://localhost:5000/health >> smoke-test-report.txt
```

* This step performs simple validation against the running application.
* The **`sleep 5`** command allows the application time to start before requests are sent.
* The first **`curl`** command invokes the application endpoint and stores the response in:

```text
smoke-test-report.txt
```

* The second **`curl`** command invokes the health endpoint and appends the response to the same file.

The operators:

```text
>   Creates a new file or overwrites an existing file
>>  Appends content to an existing file
```

* The end result is a workflow-generated report file containing application responses.

> **Key Observation:** This is the first Artifact candidate generated by the workflow. The file currently exists only on the runner's filesystem.

---

#### Common Testing Flow in CI/CD Pipelines

Although this topic is slightly outside the scope of this lecture, we have mentioned **Smoke Testing** several times throughout the course. Therefore, it is useful to understand where it fits within the overall software testing lifecycle and how different testing stages build confidence before an application is released to production.

```text
Unit → Integration → Smoke → Sanity → System → Regression → Acceptance → Production
```

| Testing Type            | Purpose                                                                                                                                                                                                                       |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Unit Testing**        | Verifies individual functions, classes, or methods in isolation to ensure each component behaves correctly.                                                                                                                   |
| **Integration Testing** | Verifies that multiple components or services work together correctly and exchange data as expected.                                                                                                                          |
| **Smoke Testing**       | Performs a quick, high-level validation to confirm the application starts successfully and its critical functionality works before proceeding with further testing. Often referred to as a **Build Verification Test (BVT)**. |
| **Sanity Testing**      | Verifies that a specific bug fix or newly added feature works as expected without performing exhaustive testing of the entire application.                                                                                    |
| **System Testing**      | Validates the complete application end-to-end against functional and non-functional business requirements.                                                                                                                    |
| **Regression Testing**  | Ensures that newly introduced changes have not unintentionally broken or altered existing functionality.                                                                                                                      |
| **Acceptance Testing**  | Performed by end users or business stakeholders to determine whether the application meets business requirements and is ready for production release.                                                                         |

> **Note:** Not every CI/CD pipeline executes all of these testing stages. Fast-running tests such as **Unit**, **Integration**, and **Smoke** tests are commonly executed on every code change, while **Regression**, **System**, and **Acceptance** testing are often performed later in the release pipeline or before deploying to production.

---

```yaml
- name: Export Container Logs
  run: |
    docker logs cwvj-flask-container > container-logs.txt
```

* This step exports the application logs generated by the running container.
* The **`docker logs`** command retrieves the container's standard output and standard error streams.
* The output is redirected into:

```text
container-logs.txt
```

The file may contain information such as:

```text
Cloud With VarJosh Flask Application Started
Home endpoint invoked
Health endpoint invoked
```

* This creates a second workflow-generated file that can later be uploaded as an Artifact.

> **Production Insight:** Capturing logs as Artifacts is a common troubleshooting technique. When pipelines fail, teams frequently upload logs, screenshots, test reports, and diagnostic information to assist with root-cause analysis.

---

```yaml
- name: Upload Artifacts
  uses: actions/upload-artifact@v7
  with:
    name: flask-ci-artifacts
    path: |
      smoke-test-report.txt
      container-logs.txt
```

**Reference:** https://github.com/marketplace/actions/upload-a-build-artifact

* This step uploads the generated files as a **GitHub Actions Artifact**.

* The **`actions/upload-artifact`** action is responsible for transferring files from the **runner's local filesystem** to **GitHub-managed Artifact Storage**.

* The **`name`** parameter defines the Artifact name displayed in the **GitHub Actions UI**:

```text
flask-ci-artifacts
```

* The **`path`** parameter specifies the files or directories that should be uploaded.

* Multiple files can be uploaded as part of the same Artifact.

In this example, the following files are uploaded:

```text
smoke-test-report.txt
container-logs.txt
```

Under the hood, GitHub Actions performs the following operations:

```text
Runner Filesystem
    ├── smoke-test-report.txt
    └── container-logs.txt
            ↓
actions/upload-artifact
            ↓
GitHub Artifact Storage
```

* The files are transferred from the runner and stored within a **GitHub-managed storage service** that is associated with the current workflow run.

* Once uploaded, the Artifact becomes visible in the **workflow run summary page** under the **Artifacts** section.

* Engineers can download the Artifact directly from the **GitHub Actions UI**, while downstream jobs can retrieve the same files using the **`actions/download-artifact`** action.

> **Important:** GitHub-hosted runners are **ephemeral**. When the job completes, the runner and its filesystem are automatically destroyed. Any files that remain only on the runner are permanently lost. Uploading files as Artifacts ensures they survive beyond the lifetime of the runner.

> **Key Observation:** Once uploaded, the files no longer depend on the original runner. They are stored in **GitHub-managed Artifact Storage**, where GitHub abstracts the underlying storage implementation, making the artifacts available for **downstream jobs**, **workflow runs**, and **manual download** without requiring users to provision or manage object storage.

---

#### Artifact Retention

Artifacts are **not stored indefinitely**.

When an Artifact is uploaded, GitHub stores it for a configurable retention period. Once that retention period expires, the Artifact is automatically deleted and can no longer be downloaded.

By default:

* GitHub retains workflow Artifacts and logs for **90 days** by default.
* Repository, organization, and enterprise administrators can modify this retention period to align with **operational**, **security**, **compliance**, **audit**, and **governance** requirements. For repository-specific retention policies, navigate to **Repository Settings → Actions → General → Artifact and Log Retention** and configure the desired retention period.
* If **`retention-days`** is not specified, GitHub uses the repository's configured retention policy.
* Workflows can optionally define a custom retention period using the **`retention-days`** parameter.

For example:

```yaml
- name: Upload Artifacts
  uses: actions/upload-artifact@v7
  with:
    name: flask-ci-artifacts
    path: smoke-test-report.txt
    retention-days: 7
```

This configuration instructs GitHub to automatically remove the Artifact after **7 days**.

A few important constraints apply:

```text
Minimum Retention (Workflow Level): 1 Day
Maximum Retention (Workflow Level): 90 Days
```

The **`retention-days`** parameter currently supports values between **1 and 90 days**. If a value is not specified, GitHub automatically uses the repository's configured retention policy.

Repository-level retention settings can be configured from ***Repository Settings → Actions → General → Artifact and Log Retention***. This allows repository administrators to centrally control how long workflow-generated data remains available and helps ensure retention policies align with organizational operational, security, compliance, audit, and governance requirements.

> **Note:** At the **workflow level**, the **`retention-days`** parameter supports a maximum value of **90 days** for an individual Artifact. At the **repository level**, administrators can configure the **Artifact and log retention period** for up to **400 days**. The effective retention period for an Artifact is determined by these repository-level retention policies.

> **Retention & Best Practices**
>
> * The **`retention-days`** parameter allows workflow authors to configure the retention period for individual Artifacts, subject to repository, organization, and enterprise policies.
> * Artifacts are designed for **temporary workflow storage**, making them ideal for sharing files between jobs, troubleshooting failures, and preserving workflow outputs for a limited period.
> * Organizations often define retention policies to balance **security**, **compliance**, **auditability**, and **storage costs**.
> * **Industry Best Practice:** Retain Artifacts only for as long as they provide operational value. Long-term deliverables, such as release packages and compliance evidence, should be stored in dedicated artifact repositories or object storage services such as **AWS CodeArtifact**, **JFrog Artifactory**, **Sonatype Nexus Repository**, **GitHub Releases**, or **Amazon S3**.


---

```yaml
review-job:
  runs-on: ubuntu-latest

  needs:
    - flask-ci-job

  steps:
    ...
```

* This block defines the **`review-job`** job.
* The job executes on a separate GitHub-hosted Ubuntu runner.
* The **`needs`** keyword creates a dependency on **`flask-ci-job`**.
* GitHub Actions waits for the first job to complete successfully before starting this job.
* Because the first job uploads Artifacts, the second job can download and consume them.

> **Connection to Previous Lectures:** As discussed earlier, jobs execute in parallel by default. The **`needs`** keyword creates dependencies and controls execution order.

> **Key Observation:** This job executes on a **completely different runner** than the first job. Without Artifacts, the files generated in the previous job would not be available.

---

```yaml
- name: Download Artifacts
  uses: actions/download-artifact@v8
  with:
    name: flask-ci-artifacts
```

* This step downloads the previously uploaded Artifact.
* The **`actions/download-artifact`** action retrieves files from **GitHub Artifact Storage**.
* The **`name`** parameter identifies which Artifact should be downloaded.

GitHub Actions locates:

```text
flask-ci-artifacts
```

and downloads all files contained within it.

In this example:

```text
smoke-test-report.txt
container-logs.txt
```

become available on the new runner.

* Once downloaded, these files can be consumed by downstream jobs, deployment processes, reporting workflows, security scanning workflows, or any other automation running within the workflow.

* Artifacts are not limited to workflow consumption. They are also available to engineers through the **GitHub Actions UI**. After a workflow completes, uploaded Artifacts appear on the workflow run summary page under the **Artifacts** section, from where they can be downloaded and reviewed manually.

A useful way to think about Artifacts is:

```text
Build Job
    ↓
Uploads Artifact
    ↓
GitHub Artifact Storage
    ├── Downstream Jobs
    ├── Engineers
    └── Other Automation
```

> **Important:** Notice that the original runner no longer exists. The files are available only because they were uploaded as Artifacts and stored in GitHub's Artifact Storage service.

> **Key Observation:** Artifacts serve two purposes. They enable **machine-to-machine sharing** between jobs and workflows, while also enabling **human access** through the GitHub Actions UI for troubleshooting, auditing, reporting, and operational reviews.

> **Production Insight:** It is common for engineers to download Artifacts such as **test reports**, **code coverage reports**, **security scan reports**, **deployment logs**, **Terraform plans**, **screenshots**, and **application packages** directly from the workflow summary page when investigating failures, validating deployments, or collecting audit evidence.

---

```yaml
- name: Review Downloaded Artifacts
  run: |
    echo "===== Smoke Test Report ====="
    cat smoke-test-report.txt

    echo ""
    echo "===== Container Logs ====="
    cat container-logs.txt
```

* This step displays the contents of the downloaded files.
* The **`cat`** command prints file contents to the workflow logs.
* The workflow displays both the smoke test report and the application logs generated by the previous job.
* This confirms that the files were successfully preserved, uploaded, transferred, and downloaded.

> **Key Observation:** The files displayed in this step were generated in one job and consumed in another job running on a completely different runner. This demonstrates the primary purpose of Artifacts: preserving and transferring files across workflow execution boundaries.

> **Mental Model:**
>
> ```text
> flask-ci-job:
> Build Image → Run Container → Generate Files → Upload Artifact
>
> review-job:
> Download Artifact → Consume Files
> ```
>
> Artifacts act as the bridge that allows workflow-generated files to survive beyond the lifetime of a runner and become available to downstream jobs.

---

### Step 4: Commit and Push the Changes

Commit the workflow and push it to GitHub.

```bash
# Add all workflow, application, and configuration changes to the Git staging area
git add .

# Create a commit containing the Artifacts demo implementation
git commit -m "feat: add artifacts demo"

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
→ Actions
→ 01 - Artifacts Demo
→ Run Workflow
```

Click **Run Workflow** to start the workflow.

> **Key Observation:** Unlike workflows triggered by events such as **`push`** or **`pull_request`**, this workflow executes only when explicitly started by a user. This allows us to focus entirely on understanding Artifact creation, upload, download, and consumption.

> **Production Insight:** Manual workflows are commonly used for production deployments, rollback operations, disaster recovery procedures, maintenance activities, infrastructure changes, and other operational workflows that require human oversight before execution.

---

### Step 5: Running the Workflow

Inside the repository:

1. Navigate to the **Actions** tab.
2. Select **01 - Artifacts Demo**.
3. Click **Run Workflow**.
4. Click **Run Workflow** again to confirm execution.

GitHub will now start the workflow.

During execution, the workflow performs the following activities:

```text
flask-ci-job:
Checkout Repository
→ Build Docker Image
→ Run Container
→ Generate Smoke Test Report
→ Export Container Logs
→ Upload Artifacts

review-job:
Download Artifacts
→ Review Downloaded Artifacts
```

As the workflow progresses, GitHub Actions provisions runners, executes the configured steps, uploads the generated files as Artifacts, and then downloads those same Artifacts in a separate job.

> **Key Observation:** The primary objective of this demo is not containerization or Flask. The goal is to demonstrate how files generated in one job can survive beyond the lifecycle of the runner and later be consumed by another job.

---

### Step 6: Observing Workflow Execution

Once the workflow completes successfully, open the workflow run and review the execution details.

You should observe two jobs:

```text
flask-ci-job
review-job
```

The first job creates the Artifact, while the second job downloads and consumes it.

Within **`flask-ci-job`**, verify that the following steps completed successfully:

```text
Checkout Repository
→ Build Docker Image
→ Run Container
→ Generate Smoke Test Report
→ Export Container Logs
→ Upload Artifacts
```

Within **`review-job`**, verify that the following steps completed successfully:

```text
Download Artifacts
→ Review Downloaded Artifacts
```

When reviewing the logs for the **Review Downloaded Artifacts** step, you should see output similar to:

```text
===== Smoke Test Report =====

{"message":"Welcome to Cloud With VarJosh","platform":"GitHub Actions","runtime":"Docker + Flask"}
{"status":"healthy"}

===== Container Logs =====

Cloud With VarJosh Flask Application Started
 * Serving Flask app 'app'
 * Debug mode: off
Home endpoint invoked
Health endpoint invoked
```

This confirms that:

* The files were successfully generated in **`flask-ci-job`**.
* The files were uploaded to **GitHub Artifact Storage**.
* The files were downloaded by **`review-job`**.
* The downloaded files contained the expected contents.

You can also verify the uploaded Artifacts directly from the workflow run summary page.

Navigate to:

```text
Workflow Run Summary
→ Artifacts
→ flask-ci-artifacts
```

From this section, GitHub allows you to download the uploaded Artifact as a ZIP file.

> **Key Takeaways:**
>
> * **Artifacts remain available even after the original runner is destroyed**, allowing files to be shared with downstream jobs and downloaded later. This is the fundamental problem that Artifacts solve in GitHub Actions.
> * **Artifacts can be downloaded directly from the GitHub Actions UI**, making them valuable for troubleshooting, reviewing test and security reports, auditing, compliance, and operational investigations.
> * If you use **Docker Buildx**, you may notice an automatically generated **`.dockerbuild` Artifact**. This is a **Docker Build Record** containing build metadata and logs, **not the Docker image itself**, and is independent of the Artifacts uploaded in this lecture.



---

## Why & What of Caching?

![Alt text](/images/8b.png)

### Why Caching?

As CI/CD pipelines grow, **workflow execution time**, **developer productivity**, and **cost optimization** become increasingly important.

Modern software delivery pipelines repeatedly download **application dependencies**, **programming language packages**, **container layers**, and **build tool assets** required to build, test, scan, and deploy applications.

Consider the following workflow executions:

```text
Workflow Run 1:
Checkout Code → Download Dependencies → Build Application → Run Tests

Workflow Run 2:
Checkout Code → Download Dependencies → Build Application → Run Tests

Workflow Run 3:
Checkout Code → Download Dependencies → Build Application → Run Tests
```

Although the **application code** may change between executions, the dependencies often remain exactly the same.

For example:

```text
Flask Version:    3.1.1
Requests Version: 2.32.4
Pytest Version:   8.4.1
```

Yet every workflow execution downloads these packages again, increasing **workflow duration**, **network utilization**, **runner costs**, and **developer wait time** without providing additional value.

The problem becomes even more significant because **GitHub-hosted runners are ephemeral**. Each job typically executes on a **fresh runner**, and once the job completes, that runner and its local filesystem are destroyed.

```text
Build Job Starts  → Runner Created
Build Job Ends    → Runner Destroyed

Test Job Starts   → New Runner Created
Test Job Ends     → Runner Destroyed

Security Job Starts → New Runner Created
Security Job Ends   → Runner Destroyed
```

As a result, locally downloaded dependencies, package manager caches, compiler caches, and other reusable files are lost when the runner is destroyed.

This repeated work occurs both:

* **Across jobs** within the same workflow.

```text
Build Job
Downloads Dependencies
↓
Test Job
Downloads Same Dependencies Again
↓
Security Scan Job
Downloads Same Dependencies Again
```

* **Across workflow executions.**

```text
Workflow Run 1
Downloads Dependencies
↓
Workflow Run 2
Downloads Same Dependencies Again
```

Even though the dependencies have not changed, they must be downloaded repeatedly because each job and workflow execution starts with a fresh environment.

> **Key Observation:** Many dependencies and other frequently used files remain unchanged across jobs and workflow executions. Re-downloading or regenerating these files on every run increases **workflow execution time**, **network utilization**, **CI/CD costs**, and overall **delivery latency**.
>
> The obvious question becomes:
>
> ***Can we reuse these files instead of downloading or regenerating them every time?***
>
> GitHub Actions addresses this through **Caching**, which stores and restores reusable dependencies and frequently used files, significantly reducing build times and improving pipeline performance.

---

### What is Caching?

Caching is a mechanism that allows **reusable files** to be stored and later restored using a **cache key**.

Instead of downloading or generating the same files repeatedly, GitHub Actions can save them in a cache and restore them whenever they are needed again.

Conceptually:

```text
Download Dependencies → Save Cache

Future Job or Workflow:
Restore Cache → Reuse Dependencies
```

A cache acts as a reusable storage layer for files that are expensive to recreate but do not change frequently.

Common examples include:

| Technology          | What is it?                     | Common Cache Location        |
| ------------------- | ------------------------------- | ---------------------------- |
| **Maven**           | Java build automation tool      | `~/.m2/repository`           |
| **Gradle**          | Build automation tool           | `~/.gradle/caches`           |
| **NPM**             | Node.js package manager         | `~/.npm`                     |
| **Yarn**            | JavaScript package manager      | `~/.cache/yarn`              |
| **Pip**             | Python package manager          | `~/.cache/pip`               |
| **NuGet**           | .NET package manager            | `~/.nuget/packages`          |
| **Go Modules**      | Go dependency management system | `~/go/pkg/mod`               |
| **Docker BuildKit** | Container image build engine    | Build cache and image layers |
| **Compiler Caches** | Compiler optimization tools     | `ccache`, `sccache`          |


Notice that GitHub Actions does **not** understand Maven, NPM, Pip, or other package managers. It simply stores and restores the specified files or directories. Each tool then reuses its own local cache, avoiding repeated downloads and reducing workflow execution time.

Unlike **Artifacts**, which are identified by an **Artifact name**, **Caches** are identified by a **cache key**.

The **cache key** uniquely identifies a cache and allows GitHub Actions to determine whether an existing cache can be restored. If an **exact key match** is found, the cache is restored; otherwise, a new cache may be created when the job completes successfully.


Conceptually:

```text
Cache Key
      ↓
Locate Existing Cache
      ↓
Restore Cached Files
```

For example:

```text
maven-linux-v1
```

or

```text
npm-linux-package-lock-hash
```

When a workflow requests a cache:

* If a matching cache exists, GitHub restores the cached files.
* If no matching cache exists, GitHub creates a new cache after the job completes.

These outcomes are commonly referred to as:

```text
Cache Hit  → Existing Cache Restored

Cache Miss → No Cache Found
             New Cache Created
```

A typical cache lifecycle looks like:

```text
Job or Workflow:
Request Cache
        ↓
Cache Hit?
        ↓
Yes → Restore Files
No  → Generate Files → Save Cache
```

> **Important:** Caches are intended for **reusable assets** that can be safely recreated if necessary. They should not be treated as a mechanism for preserving important workflow outputs.

> Artifacts and Caches may appear similar because both store files in **GitHub-managed storage**, but they solve different problems and **cannot be used interchangeably**.

| Mechanism     | Primary Purpose                                                                                                                                                                                                                   | Common Examples                                                                                                                                                                                                     |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Artifacts** | Preserve and share **files produced by a job**, such as application deliverables, reports, logs, and other workflow outputs, so they can be consumed by downstream jobs, downloaded by users, or reviewed after the workflow run. | **`application.jar`**, **`test-report.html`**, **`deployment.log`**, **`coverage-report.html`**, **`security-scan.json`**, **`sbom.json`**, **`terraform.tfplan`**                                                  |
| **Caching**   | Reuse **files that do not change frequently**, such as dependencies, package manager caches, and build tool caches, across **jobs** and **workflow executions** to reduce execution time, network utilization, and CI/CD costs.   | **Maven dependencies (`~/.m2`)**, **NPM packages (`~/.npm`)**, **Pip packages (`~/.cache/pip`)**, **Gradle cache (`~/.gradle`)**, **Yarn cache**, **NuGet packages**, **Go modules**, **Docker build cache layers** |


> **Key Observation:** A simple way to distinguish the two is:
>
> ```text
> Workflow Produces a File → Artifact
>
> Workflow Reuses a File → Cache
> ```
>
> If the file is an **output of the workflow** that needs to be preserved or shared, use an **Artifact**. If the file is **reused across jobs or workflow executions** to avoid downloading or regenerating it repeatedly, use a **Cache**.

> **Mental Model:** A cache can be thought of as a **reusable storage layer for frequently accessed files**.
>
> ```text
> Save Files Using Cache Key
>           ↓
> Restore Files Using Same Cache Key
> ```
>
> The purpose of caching is to reuse previously downloaded or generated assets, not to preserve important workflow outputs.

> **Important:** Although both **Artifacts** and **Caches** store files in **GitHub-managed storage**, they are designed for different purposes. **Artifacts** are primarily used to preserve **files generated during the software delivery lifecycle**, such as application binaries, test reports, coverage reports, security scan results, and deployment logs. These files can be **downloaded directly from the GitHub Actions UI** by engineers or consumed by downstream jobs. **Caches**, on the other hand, are primarily used to store **files downloaded or generated by build tools**, most commonly **dependencies** retrieved from the internet (for example, Maven, NPM, Pip, or Gradle packages) and other reusable build assets. Unlike Artifacts, **Caches are not intended for manual download or inspection by users**; they exist solely to speed up workflow execution by avoiding repeated downloads or regeneration of the same files. Another important distinction is retention: **Artifacts are retained for 90 days by default** (unless configured otherwise), whereas **Caches are automatically evicted if they are not accessed for more than 7 days** by default.


---

## Demo 2: Reusing Dependencies Across Jobs Using Caching

In this demo, we will learn how **GitHub Actions Caching** helps improve workflow performance by avoiding the repeated download and recreation of files that do not change frequently.

Rather than downloading the same dependencies during every job and every workflow execution, GitHub Actions allows us to store reusable files in a **Cache** and restore them whenever they are needed again.

Throughout this demo, we will explore:

* How to create and restore a Cache using the **GitHub Actions Cache Action**.
* How Caches can be reused across **multiple jobs within the same workflow**.
* How **Cache Keys** determine whether an existing Cache can be reused.
* The difference between a **Cache Hit** and a **Cache Miss**.

To keep the focus on the caching concepts, we will use a simple **Python Flask application** and demonstrate how Python dependencies can be cached and reused.

By the end of this demo, you will understand one of the most commonly used optimization techniques in modern CI/CD pipelines.

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

### Step 2: Preparing the Application and Supporting Components

Before creating the workflow, we first need an **application** and the supporting components required by the pipeline.

In this step, we will:

* create a simple **Flask application**
* define the application's **Python dependencies**
* prepare the files required by the workflow that we will build later

Unlike the previous Artifact demo, we do **not** need a Dockerfile because the focus of this lecture is understanding **Caching**, not containerization.

Many CI/CD pipelines deploy applications directly to **virtual machines**, **application servers**, **managed platforms**, or other runtime environments without building container images. Since our goal is to understand caching behavior, we will keep the example intentionally simple.

By the end of this step, we will have everything required to demonstrate how dependencies can be downloaded once and reused across jobs and workflow executions.

For simplicity, place all files under a directory called:

```text
project-files
```

Recommended directory structure:

```text
project-files/
├── app.py
├── requirements.txt
└── .github/
    └── workflows/
        └── 01-caching-demo.yaml
```

> **Why are we creating these components?**
>
> Modern applications typically depend on external libraries and packages.
>
> Before an application can be built, tested, or deployed, those dependencies often need to be downloaded from package repositories such as **PyPI**, **Maven Central**, **NPM**, or **NuGet**.
>
> In this demo, we will use Python dependencies because they provide a simple and realistic way to demonstrate how caching works in CI/CD pipelines.

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
        runtime="Python + Flask"
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

##### Understanding the Application

This application:

* creates a lightweight **Flask web server**
* exposes an application endpoint at **`/`**
* exposes a health-check endpoint at **`/health`**
* listens on port **5000**

The application itself is intentionally simple because our focus is not on Flask development. Instead, we want a realistic application that requires external dependencies so we can explore how GitHub Actions caching works.

---

#### Step 2.2: Create the Requirements File

Create the following dependency file:

**`requirements.txt`**

```text
flask==3.1.1
requests==2.32.4
pytest==8.4.1
```

##### Understanding the Requirements File

This file defines the Python dependencies required by the application and the workflow.

The dependencies used in this demo are:

* **Flask** – lightweight Python web framework.
* **Requests** – popular HTTP client library used for interacting with APIs and web services.
* **Pytest** – widely used Python testing framework.

The following lines instruct Python to install specific package versions:

```text
flask==3.1.1
requests==2.32.4
pytest==8.4.1
```

Pinning dependency versions is considered a **best practice** because it helps ensure consistent behavior across:

* developer workstations
* CI/CD pipelines
* testing environments
* production environments

Without version pinning, different environments could install different package versions, potentially resulting in inconsistent behavior and difficult-to-diagnose issues.

> **Why are we using multiple dependencies?**
>
> The primary purpose is to make caching behavior easier to observe.
>
> During the first workflow execution, GitHub Actions will need to download these packages from Python package repositories.
>
> During subsequent jobs and workflow executions, GitHub Actions can restore previously cached dependency files instead of downloading them again.

> **Operational Note:** The `requirements.txt` file provides a standardized way of defining Python dependencies. This allows developers, CI/CD pipelines, and deployment environments to install the same dependency versions consistently, improving reproducibility and reducing deployment-related issues.

> **Production Insight:** Dependency caching is one of the most common uses of GitHub Actions Caching. Similar patterns are widely used for **Maven dependencies**, **Gradle dependencies**, **NPM packages**, **Yarn packages**, **NuGet packages**, **Go modules**, and many other package management systems.

---

### Step 3: Creating the Workflow

Create the following workflow file:

**`.github/workflows/01-caching-demo.yaml`**

```yaml
name: 01 - Caching Demo

on:
  workflow_dispatch:

jobs:
  build-job:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v5

      - name: Setup Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.13"

      - name: Restore Pip Cache
        id: pip-cache
        uses: actions/cache@v5
        with:
          path: ~/.cache/pip
          key: pip-cache-${{ runner.os }}-${{ hashFiles('requirements.txt') }}

      - name: Display Cache Status
        run: |
          echo "Cache Hit: ${{ steps.pip-cache.outputs.cache-hit }}"

      - name: Install Dependencies
        run: |
          pip install -r requirements.txt

  test-job:
    runs-on: ubuntu-latest

    needs:
      - build-job

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v5

      - name: Setup Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.13"

      - name: Restore Pip Cache
        id: pip-cache
        uses: actions/cache@v5
        with:
          path: ~/.cache/pip
          key: pip-cache-${{ runner.os }}-${{ hashFiles('requirements.txt') }}

      - name: Display Cache Status
        run: |
          echo "Cache Hit: ${{ steps.pip-cache.outputs.cache-hit }}"

      - name: Install Dependencies
        run: |
          pip install -r requirements.txt
```

#### Explanation

```yaml
name: 01 - Caching Demo
```

* This block defines the **workflow name** displayed inside the **GitHub Actions UI**.
* The name helps engineers quickly identify workflow executions while reviewing pipeline history, troubleshooting failures, and monitoring CI/CD activities.
* The workflow name does not affect execution behavior but significantly improves usability and maintainability.

> **Operational Tip:** **Production repositories** often contain dozens of workflows supporting CI, CD, security scanning, compliance validation, dependency management, infrastructure automation, and operational activities. **Clear workflow names** make it much easier to locate the correct workflow during troubleshooting and audits.

---

```yaml
on:
  workflow_dispatch:
```

* This block defines the workflow trigger.
* The workflow executes only when manually started from the GitHub Actions UI.
* Using a manual trigger allows us to execute the workflow repeatedly while observing **Cache Misses**, **Cache Hits**, and cache reuse behavior.

> **Why are we using `workflow_dispatch`?**
>
> In this demo, we will intentionally run the workflow multiple times to observe how caching behaves across jobs and workflow executions.
>
> Using a manual trigger gives us complete control over when each execution occurs.

---

```yaml
jobs:
```

* This block defines the collection of jobs that belong to the workflow.
* A workflow may contain one or many jobs depending on the complexity of the pipeline.
* In this demo, we intentionally use two jobs to demonstrate how a Cache can be reused across different jobs.

The workflow contains:

```text
Build Job
     ↓
Test Job
```

This allows us to observe cache behavior from both perspectives:

* reuse across **jobs**
* reuse across **workflow executions**

---

```yaml
build-job:
```

* This block defines the first job in the workflow.
* The primary responsibility of this job is to **restore previously cached dependencies** and install any missing dependencies.
* If no matching cache exists, **GitHub Actions automatically creates a new cache when the job completes successfully**.
* This job acts as the **producer** of the dependency cache for future workflow executions.

Conceptually:

```text
Build Job
      ↓
Restore Cache
      ↓
Install Missing Dependencies
      ↓
Save Updated Cache
```


---

```yaml
runs-on: ubuntu-latest
```

* This block instructs GitHub Actions to provision a **GitHub-hosted Ubuntu runner**.
* All steps within the job execute on this runner.
* GitHub-hosted runners provide a clean and isolated execution environment for every job.

> **Important:** GitHub-hosted runners are **ephemeral**.
>
> When the job completes, the runner is automatically destroyed.
>
> This is one of the primary reasons caching becomes valuable. Without caching, dependencies often need to be downloaded repeatedly because each new job starts with a fresh environment.

---

```yaml
- name: Checkout Repository
  uses: actions/checkout@v5
```

* This step downloads the repository contents onto the runner.
* The workflow requires access to:

  * `app.py`
  * `requirements.txt`
  * workflow files
  * other repository assets

Without this step, the runner would not have access to the application's source code.

> **Production Insight:** The checkout step is one of the most common steps in GitHub Actions workflows because most CI/CD activities require access to repository contents.

---

```yaml
- name: Setup Python
  uses: actions/setup-python@v6
  with:
    python-version: "3.13"
```

* This step installs and configures the required Python runtime.
* The workflow requires Python because we will install dependencies from the `requirements.txt` file.
* The version is explicitly pinned to **Python 3.13** to ensure predictable behavior across workflow executions.

> **Operational Note:** Explicitly defining runtime versions is considered a best practice because it improves reproducibility and reduces environment-related issues.

---

```yaml
- name: Restore Pip Cache
  id: pip-cache
  uses: actions/cache@v5
  with:
    path: ~/.cache/pip
    key: pip-cache-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
```

* This step uses the **GitHub Actions Cache Action** to restore previously created Caches and make them available to the current job.
* Notice that the step contains four important components: **`id`**, **`uses`**, **`path`**, and **`key`**.
* Together, these determine **what should be cached**, **how GitHub identifies the Cache**, and **how downstream steps can determine whether a Cache was restored successfully**.

> **Important:** Although this step is named **Restore Pip Cache**, the Cache Action actually performs **two separate operations**.
>
> During workflow execution, it first attempts to **restore** an existing Cache:
>
> ```text
> Workflow Starts
> → Restore Existing Cache
> ```
>
> If no matching Cache exists, the workflow simply continues executing. GitHub does **not** create a new Cache immediately.
>
> Later, after the remaining workflow steps complete successfully and the configured **Cache Path** has been populated (for example, by **`pip install`**), GitHub automatically executes a **Post Restore Pip Cache** step. This post-job step uploads the contents of the configured Cache Path and associates them with the configured **Cache Key**.
>
> Conceptually:
>
> ```text
> Restore Cache
> → Cache Miss
> → Install Dependencies
> → ~/.cache/pip Populated
> → Job Completes Successfully
> → Post Restore Pip Cache
> → Create/Update Cache
> ```
>
> This explains why the **Build Job** experiences a **Cache Miss** during the first workflow execution, while the subsequent **Test Job** observes a **Cache Hit**. By the time the Test Job starts, the Build Job has already completed and GitHub has uploaded the newly created Cache.

---

```yaml
id: pip-cache
```

* The **`id`** keyword assigns a unique identifier to this step.
* We previously used **`id`** in the **Outputs lecture**, where it allowed us to reference outputs generated by earlier steps.
* The same concept applies here. By assigning **`id: pip-cache`**, we can later access outputs generated by the Cache Action.
* For example, **`${{ steps.pip-cache.outputs.cache-hit }}`** exposes information about the Cache lookup operation performed by the Cache Action.
* Depending on the outcome, the output may contain:

```text
true  → Exact Cache Match Found
false → Cache Restored Using Restore Keys
''     → No Cache Restored
```

> **Key Observation:** Many GitHub Actions expose outputs. The **`id`** keyword provides the mechanism for referencing those outputs from downstream steps.

---

```yaml
uses: actions/cache@v5
```

* This statement instructs GitHub Actions to execute the **Cache Action**.
* The Cache Action is responsible for **restoring previously created Caches** and **saving new or updated Caches** after a successful job execution.
* Unlike files stored on runners, GitHub stores Caches outside the lifecycle of individual runners, allowing them to survive after runners are destroyed and be reused by other jobs and future workflow executions.

> **Production Insight:** Dependency caching is one of the most common CI/CD optimizations because it significantly reduces workflow execution time and avoids repeated dependency downloads.

---

```yaml
with:
  path: ~/.cache/pip
  key: pip-cache-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
```

* The **`with`** block is used to provide configuration values to an Action.
* Most GitHub Actions expose customization options through a **`with`** block. Examples include **`actions/setup-python`**, **`actions/upload-artifact`**, **`actions/cache`**, and many others.
* The supported parameters vary from Action to Action, which is why reviewing the Action's documentation is always recommended.

> **Operational Tip:** Whenever you use a GitHub Action, **review its documentation** to understand the available configuration options and how they influence workflow behavior.

---

```yaml
path: ~/.cache/pip
```

* Before understanding **`path`**, it is important to understand how **pip** behaves.
* When pip downloads packages, it automatically stores them in its local cache directory:

```text
~/.cache/pip
```

* For example, when we execute:

```bash
pip install -r requirements.txt
```

pip downloads the packages defined in:

```text
flask==3.1.1
requests==2.32.4
pytest==8.4.1
```

* These downloaded packages are stored inside **`~/.cache/pip`**.
* By configuring:

```yaml
path: ~/.cache/pip
```

GitHub knows **which directory should be restored and later saved as a Cache**.

* Once these dependency packages have been downloaded and stored in the Cache, other **jobs** and future **workflow executions** that require the same dependencies can restore them directly from the Cache rather than downloading them again from external package repositories.
* This helps reduce **workflow execution time**, **network utilization**, **dependency download overhead**, and overall **CI/CD costs** while improving developer feedback cycles.

Conceptually:

```text
requirements.txt
→ Download Dependencies
→ Store in ~/.cache/pip
→ Save Cache
```

Later:

```text
Another Job / Workflow
→ Restore Cache
→ Reuse Dependencies
```

instead of:

```text
Another Job / Workflow
→ Download Dependencies Again
```

> **Important:** We are **not caching the Flask application**. We are caching the **dependency files downloaded by pip** based on the packages defined in **`requirements.txt`**.

> **Key Observation:** The primary purpose of caching is **not long-term storage**. The goal is to eliminate repeated work by reusing files that do not change frequently, thereby improving overall CI/CD efficiency.

---

```yaml
key: pip-cache-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
```

* The **Cache Key** uniquely identifies a Cache.
* A repository can contain multiple Caches. The **Cache Key** allows GitHub Actions to locate and restore the correct Cache associated with a specific dependency set, operating system, package manager, build tool, or application component.

Conceptually:

```text
Cache Key → Locate Existing Cache → Restore Cached Files
```

* When the Cache Action executes, GitHub attempts to locate a Cache matching this key.
* A matching Cache results in an **exact Cache Hit**. Otherwise, GitHub attempts to locate a matching **Restore Key** (if configured). If neither is found, a **Cache Miss** occurs.

The key contains two important components:

```yaml
${{ runner.os }}
```

* Uses the **Runner Context**, which we studied in the **Functions & Contexts lecture**.
* Examples include **Linux**, **Windows**, and **macOS**.
* Including the operating system helps prevent incompatible caches from being reused across different platforms.

```text
Linux Cache ≠ Windows Cache ≠ macOS Cache
```

```yaml
${{ hashFiles('requirements.txt') }}
```

* Uses the **`hashFiles()` function**, which we also studied in the **Functions lecture**.
* GitHub calculates a hash based on the contents of **`requirements.txt`**.
* If any content within **`requirements.txt`** changes, the generated hash also changes.
* Because the hash is part of the **Cache Key**, a change in the file contents results in a **new Cache Key** being generated.
* A new Cache Key means GitHub can no longer locate the previous Cache, ensuring that dependency changes automatically trigger the creation of a new Cache.

For example:

```text
requirements.txt
```

```text
flask==3.1.1
requests==2.32.4
pytest==8.4.1
```

Later:

```text
flask==3.1.1
requests==2.32.4
pytest==8.4.1
pandas==2.3.1
```

Results in:

```text
requirements.txt Changes → Hash Changes → Cache Key Changes → New Cache Created
```

This is extremely important because if the dependency definition changes, the Cache should also change. Otherwise, workflows may continue using dependencies that no longer match the application's requirements.

> **Key Observation:** GitHub Actions does not simply cache files forever. **Cache Keys determine whether an existing Cache can be reused or whether a new Cache must be created.** This pattern is widely used across package management systems such as **Maven**, **Gradle**, **NPM**, **Yarn**, **NuGet**, and **Pip**:
>
> ```text
> Dependency Definition Changes → Cache Key Changes → New Cache Created
> ```
>
> Regardless of the technology stack, the underlying principle remains the same: when the dependency definition changes, a new Cache is generated to ensure workflows use the correct dependency set rather than reusing potentially outdated packages.

---

```yaml
- name: Display Cache Status
  run: |
    echo "Cache Hit: ${{ steps.pip-cache.outputs.cache-hit }}"
```

* This step displays the result of the Cache lookup operation performed by the **Cache Action**.
* Notice that we are referencing:

```yaml
${{ steps.pip-cache.outputs.cache-hit }}
```

* The value is obtained from the output exposed by the step that we earlier assigned the identifier:

```yaml
id: pip-cache
```

* During execution, the Cache Action attempts to locate a Cache matching the configured Cache Key.
* The **`cache-hit`** output tells us the result of that lookup operation.

Possible outputs include:

```text
Cache Hit: true
```

or

```text
Cache Hit: false
```

or

```text
Cache Hit:
```

Meaning:

```text
true  → Exact Cache Match Found → Cached Files Restored

false → Cache Restored Using Restore Keys
         (No Exact Key Match Found)

''     → No Cache Restored (Cache Miss)
```

* In our current demo, we are **not using Restore Keys**, so you will typically observe only two outcomes:

```text
Cache Hit:
```

or

```text
Cache Hit: true
```

* A **blank value** indicates that **no matching Cache was found** and therefore **no Cache could be restored**.
* Once the dependencies are downloaded and the **job completes successfully**, GitHub creates a **new Cache** using the configured **Cache Key** and **Cache Path**.
* Subsequent **jobs** and **workflow executions** using the same **Cache Key** can then restore the previously created Cache.

For example:

```text
First Workflow Run
→ Cache Hit:
→ Download Dependencies
→ Create Cache
```

```text
Second Workflow Run
→ Cache Hit: true
→ Restore Cache
```

> **Key Observation:** In this demo, a **blank value (`''`) represents a Cache Miss**, while **`true` represents an exact Cache Hit**. You will typically not see **`false`** unless **Restore Keys** are configured.

This output becomes extremely useful during **troubleshooting** because it immediately tells us whether GitHub **restored an existing Cache**, **restored a fallback Cache using Restore Keys**, or **failed to restore a Cache entirely**.


> **Connection to the Outputs Lecture:** Some students may notice that we are accessing an output:
>
> ```yaml
> ${{ steps.pip-cache.outputs.cache-hit }}
> ```
>
> without explicitly writing anything to:
>
> ```text
> $GITHUB_OUTPUT
> ```
>
> This is because there are two different concepts involved:
>
> ```text
> Creating Outputs  → Requires GITHUB_OUTPUT
> Consuming Outputs → Does Not Require GITHUB_OUTPUT
> ```
>
> In the Outputs lecture, we manually created an output:
>
> ```yaml
> echo "release_version=v1.0.1" >> $GITHUB_OUTPUT
> ```
>
> and later consumed it using:
>
> ```yaml
> ${{ steps.version.outputs.release_version }}
> ```
>
> In this demo, the **Cache Action** automatically creates the **`cache-hit`** output on our behalf. We simply consume that output using:
>
> ```yaml
> ${{ steps.pip-cache.outputs.cache-hit }}
> ```
>
> Many GitHub Actions expose outputs such as **IDs**, **URLs**, **versions**, **status values**, and other runtime information. Workflow authors can consume these outputs directly without manually writing to **`GITHUB_OUTPUT`** because the Action has already done that internally.
>
> **Terraform Analogy:** This is similar to working with **Terraform resources** and **modules**. Many resources expose built-in attributes (such as **IDs**, **ARNs**, and **IP addresses**), and modules can expose outputs that consumers reference directly. Likewise, many GitHub Actions expose built-in outputs, allowing workflow authors to consume values such as **`cache-hit`** without creating those outputs manually.


> **Operational Tip:** Whenever you introduce caching into a workflow, it is often useful to log **Cache Hit** and **Cache Miss** information during initial testing and troubleshooting. This helps quickly validate that the Cache Key, Cache Path, and Cache restoration logic are behaving as expected.

> **Key Observation:** A successful **Cache Hit** does not mean dependencies are already installed. It simply means the cached files were restored successfully. The application or build tool may still need to consume those files during the installation or build process.

---

#### What are Restore Keys?

So far, we have restored a Cache only when GitHub finds an **exact match** for the configured **Cache Key**. However, in real-world CI/CD pipelines, dependency definitions change over time. Even a minor change to a dependency file results in a **new Cache Key**, causing GitHub to treat the request as a **Cache Miss**.

For example, consider the following dependencies:

```text
Flask 3.1.1
Requests 2.32.4
Pytest 8.4.1
```

Later, suppose we upgrade **Requests**:

```text
Flask 3.1.1
Requests 2.32.5
Pytest 8.4.1
```

or add a new package:

```text
Flask 3.1.1
Requests 2.32.4
Pytest 8.4.1
Pandas 2.3.1
```

Since the contents of **`requirements.txt`** have changed:

```text
requirements.txt Changes
→ Hash Changes
→ Cache Key Changes
→ Exact Cache Match Not Found
```

Without **Restore Keys**, GitHub treats this as a **Cache Miss**, downloads the required dependencies again, and creates a new Cache when the job completes successfully.

At first glance, this may appear inefficient because **only one dependency changed**, while the remaining packages are still identical.

This is where **Restore Keys** become useful.

Instead of restoring only an **exact Cache Key**, Restore Keys allow GitHub Actions to search for **similar Caches** using one or more **fallback keys**.

The restore keys are searched **from top to bottom**, starting with the **most specific** key and ending with the **least specific** key.

For example:

```yaml
- name: Restore Pip Cache
  uses: actions/cache@v5
  with:
    path: ~/.cache/pip
    key: pip-cache-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
    restore-keys: |
      pip-cache-${{ runner.os }}-
      pip-cache-
```

GitHub performs the lookup in the following order:

```text
Try Exact Cache Key
→ pip-cache-Linux-a8f32...
```

If no exact match is found:

```text
Try Restore Key #1
→ pip-cache-Linux-
```

If a suitable Cache is still not found:

```text
Try Restore Key #2
→ pip-cache-
```

If multiple Caches match a Restore Key, GitHub restores the **most recently created Cache**.

Conceptually:

```text
Exact Cache Match Not Found
→ Try Restore Keys
→ Restore Closest Matching Cache
→ Reuse Existing Dependencies
→ Download Only Missing or Updated Dependencies
→ Job Completes Successfully
→ Create Updated Cache
```

This significantly improves workflow performance because the package manager can reuse many of the previously downloaded dependencies while downloading only the packages that are new or have changed.

> **Important:** Restore Keys **do not replace the primary Cache Key**. GitHub always attempts to restore the **exact Cache Key first**. Restore Keys are evaluated **only if an exact match cannot be found**.

> **Key Observation:** Restore Keys are searched **sequentially**, from the **most specific** key to the **least specific** key. As soon as GitHub finds a matching Cache, it restores the **most recently created Cache** that matches that Restore Key.

> **Why aren't we using Restore Keys in this demo?** Our goal in this lecture is to understand the core caching concepts, namely **Cache Paths**, **Cache Keys**, **Cache Hits**, and **Cache Misses**. Introducing Restore Keys at this stage would add unnecessary complexity. We will revisit this feature later in the course, particularly during the **Mega Demo**, where advanced caching strategies provide greater real-world value.

---

#### Cache Retention

Like Artifacts, **Caches are not stored indefinitely**. However, unlike Artifacts, workflow authors **cannot configure retention for individual caches**.

Instead, GitHub manages cache retention centrally at the **repository**, **organization**, or **enterprise** level.

Some important characteristics include:

* Caches that have **not been accessed within the configured retention period** are automatically removed. On GitHub.com, the default retention period is **7 days**.
* Caches are also subject to **repository storage limits**, and older caches may be evicted to make room for newer ones.
* Workflow authors **cannot** configure cache retention within a workflow. Instead, repository, organization, or enterprise administrators define the **maximum cache retention policy**.

> **Cache Lifecycle & Best Practices**
>
> * Caches are designed to **improve workflow performance**, not to preserve files for long-term storage.
> * Cache only **reusable dependencies** and **frequently used files** that are expensive to download or regenerate.
> * Use **meaningful cache keys** so caches are invalidated only when dependencies change.
> * Avoid caching **logs**, **reports**, **application binaries**, and other **workflow outputs**. Such files should be stored as **Artifacts** instead.
>
> **References:**
>
> * GitHub Docs – Dependency caching reference: https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching
> * GitHub Docs – Dependency caching concepts: https://docs.github.com/en/actions/concepts/workflows-and-actions/dependency-caching

---

```yaml
- name: Install Dependencies
  run: |
    pip install -r requirements.txt
```

* This step installs the Python dependencies defined in **`requirements.txt`**.
* During installation, **pip** reads the dependency definitions and ensures the required packages are available on the runner.
* In our example, the following packages are installed:

```text
Flask
Requests
Pytest
```

* If an **exact Cache Match** was restored earlier (**`cache-hit='true'`**), many of the required package files may already exist within **`~/.cache/pip`**, allowing pip to reuse them rather than downloading them again from external repositories.
* If **no Cache was restored** (**`cache-hit=''`**), pip downloads the required packages from package repositories such as **PyPI**. Once the job completes successfully, GitHub can then create a new Cache for future reuse.
* In more advanced scenarios involving **Restore Keys**, pip may reuse some cached files while downloading only the missing or updated dependencies.

> **Important:** GitHub Actions **does not tell package managers such as Pip, Maven, NPM, or Gradle to use a cache**. Instead, the **Cache Action** simply restores the specified cache directory (for example, **`~/.cache/pip`** or **`~/.m2/repository`**) onto the runner before the dependencies are installed. The package manager then behaves exactly as it normally would, automatically checking its local cache first and downloading only the dependencies that are missing.
>
> The **cache key** is used **only by GitHub Actions** to determine whether an existing cache can be restored. It is **not** used by the package manager itself.


Conceptually:

```text
cache-hit='true'
→ Restore Cached Files
→ pip Reuses Files
→ Faster Installation
```

or

```text
cache-hit=''
→ Download Dependencies
→ Job Completes Successfully
→ New Cache Created
```

> **Important:** A Cache does not install dependencies on our behalf. The Cache simply stores reusable files. The **`pip install`** command must still execute, but when cached files are available, pip can often reuse them instead of downloading them again. This is what reduces dependency download time and improves workflow performance.

> **Key Observation:** Restoring a Cache and installing dependencies are two separate activities:
>
> ```text
> Cache → Stores/Reuses Files
> pip install → Installs Dependencies
> ```
>
> The Cache makes dependency installation faster, but it does not replace the installation step itself.

> **Production Insight:** Many students assume that a successful Cache restore eliminates the need for dependency installation. In reality, build tools such as **pip**, **Maven**, **Gradle**, **NPM**, and **Yarn** still execute their normal installation commands. The difference is that they can often reuse locally cached files instead of downloading them again, resulting in faster workflow execution and reduced network utilization.

---

```yaml
test-job:
```

* This block defines the second job in the workflow.
* The primary purpose of this job is to demonstrate that a Cache restored or created by one job can later be reused by another job.
* To keep the demo focused on caching, the Test Job performs the same **Cache restoration** and **dependency installation** activities that we performed in the Build Job.

Conceptually:

```text
Build Job → Restore/Create Cache

Test Job → Restore Cache → Reuse Dependencies
```

> **Important:** In real-world CI/CD pipelines, Build, Test, Security Scan, Package, and Deploy jobs often require access to the same dependencies. Caching helps eliminate repeated downloads and reduces overall workflow execution time.

---

```yaml
needs:
  - build-job
```

* This block creates a dependency between the two jobs.
* The **`test-job`** will not start until the **`build-job`** completes successfully.
* GitHub uses the **`needs`** keyword to control job execution order and build workflow dependencies.

Conceptually:

```text
Build Job → Test Job
```

* This sequencing is important because the Build Job may create or update a Cache that can later be restored by the Test Job.
* Without this dependency, both jobs could start independently, making it difficult to demonstrate cache reuse between jobs.

> **Key Observation:** Although both jobs execute on **different runners**, they can still access the same Cache because GitHub stores Caches outside the lifecycle of individual runners.

> **Production Insight:** The **`needs`** keyword is commonly used to model CI/CD stages such as:
>
> ```text
> Build → Test → Security Scan → Package → Deploy
> ```
>
> ensuring that downstream activities execute only after upstream validation has completed successfully.

---

The remaining steps inside **`test-job`** are intentionally identical to those in **`build-job`**.

* This allows us to isolate and observe caching behavior without introducing additional variables.
* By keeping the workflow logic consistent, it becomes much easier to identify when a **Cache Hit** or **Cache Miss** occurs and understand why.

During execution, you may observe:

**First Workflow Execution**

```text
Build Job → Cache Hit:
Test Job  → Cache Hit: true
```

**Second Workflow Execution**

```text
Build Job → Cache Hit: true
Test Job  → Cache Hit: true
```

The first execution demonstrates:

```text
Build Job → No Cache Restored → Download Dependencies → Create Cache
```

```text
Test Job → Restore Newly Created Cache → Reuse Dependencies
```

These results demonstrate two important caching capabilities:

```text
Cache Reuse Across Jobs
```

and

```text
Cache Reuse Across Workflow Executions
```

> **Key Observation:** The Build Job and Test Job execute on separate runners, yet both can restore the same Cache. This demonstrates that GitHub Caches are not tied to a specific runner; they are stored by GitHub and can be reused across both **jobs** and **workflow executions**.

> **Production Insight:** This is one of the primary reasons caching is so valuable in CI/CD systems. A dependency downloaded once can potentially be reused by multiple jobs and future workflow executions, significantly reducing dependency download time, network utilization, and overall pipeline duration.


---

### Step 4: Commit and Push the Changes

Commit the workflow and push it to GitHub.

```bash
# Add all workflow, application, and configuration changes to the Git staging area
git add .

# Create a commit containing the Caching demo implementation
git commit -m "feat: add caching demo"

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
→ Actions
→ 01 - Caching Demo
→ Run Workflow
```

and click:

```text
Run Workflow
```

to start the workflow.

> **Key Observation:** We are using **`workflow_dispatch`** because it gives us complete control over when the workflow executes. This makes it easier to observe cache behavior across multiple workflow runs without generating unnecessary executions.

> **Production Insight:** During development and troubleshooting, engineers frequently use **manual workflow triggers** to validate CI/CD changes, test caching strategies, verify deployment logic, and troubleshoot pipeline behavior before enabling automatic triggers such as **`push`** or **`pull_request`**.

---

### Step 5: Running the Workflow

Inside the repository:

1. Navigate to the **Actions** tab.
2. Select **01 - Caching Demo**.
3. Click **Run Workflow**.
4. Click **Run Workflow** again to start the execution.

GitHub now provisions the required runners and begins executing the workflow.

Conceptually:

```text
Run Workflow
→ Build Job Starts
→ Test Job Starts
→ Workflow Completes
```

During execution, you should observe the following job sequence:

```text
build-job
     ↓
test-job
```

because the Test Job depends on the Build Job through:

```yaml
needs:
  - build-job
```

> **Important:** If no Cache currently exists for the generated **Cache Key**, the Build Job will initially experience a **Cache Miss**, download the required dependencies, and create a new Cache when the job completes successfully.
>
> If a Cache already exists from a previous workflow execution, the Build Job may immediately restore that Cache and report a **Cache Hit**. Cache behavior is entirely determined by the configured **Cache Key**.

---

### Step 6: Observing Workflow Execution

Open the workflow run and inspect the logs generated by both jobs.

If this is the **first time a Cache Key is being used**, you will typically observe output similar to:

```text
Build Job
Cache Hit:
```

and:

```text
Test Job
Cache Hit: true
```

Conceptually:

```text
Build Job
→ No Cache Restored
→ Download Dependencies
→ Job Completes Successfully
→ Cache Created
```

```text
Test Job
→ Exact Cache Match Found
→ Restore Cache
→ Reuse Dependencies
```

This demonstrates **Cache Reuse Across Jobs**.

---

Now execute the workflow a second time.

During the **second workflow execution**, you will typically observe:

```text
Build Job
Cache Hit: true
```

and:

```text
Test Job
Cache Hit: true
```

Conceptually:

```text
Workflow Run #1
→ Create Cache
```

```text
Workflow Run #2
→ Restore Existing Cache
```

This demonstrates **Cache Reuse Across Workflow Executions**.

At this point, we have successfully demonstrated the two most common caching scenarios:

```text
Cache Reuse Across Jobs
```

and

```text
Cache Reuse Across Workflow Executions
```

> **Key Observation:** Even though the Build Job and Test Job execute on different runners, both jobs can access the same Cache because GitHub stores Caches outside the lifecycle of individual runners.

> **Production Insight:** This is one of the primary reasons caching is so valuable in CI/CD environments. Dependencies are often downloaded once and then reused by multiple jobs and future workflow executions, reducing dependency download time, network utilization, runner execution time, and overall CI/CD costs.

> **Try This:** Modify the **`requirements.txt`** file by adding a new package such as:
>
> ```text
> pandas==2.3.1
> ```
>
> Commit the change and execute the workflow again.
>
> You will typically observe:
>
> ```text
> Cache Hit:
> ```
>
> because:
>
> ```text
> requirements.txt Changes
> → Hash Changes
> → Cache Key Changes
> → No Matching Cache Found
> → Download Dependencies
> → Create New Cache
> ```
>
> After the new Cache is created, future jobs and workflow executions using the updated **`requirements.txt`** will observe:
>
> ```text
> Cache Hit: true
> ```
>
> This experiment clearly demonstrates how **Cache Keys** control **Cache reuse** and **Cache invalidation** in GitHub Actions.

---

## Conclusion

In this lecture, we explored two fundamental GitHub Actions capabilities that are used extensively in production CI/CD pipelines.

We learned that **Artifacts** preserve and share **workflow-generated files**, allowing downstream jobs, workflow runs, and engineers to access build outputs, test reports, logs, and other generated files even after the original runner has been destroyed.

We also learned that **Caching** serves a completely different purpose. Rather than preserving workflow outputs, it stores and restores **reusable dependencies and frequently used files**, reducing repeated downloads, improving workflow performance, lowering CI/CD costs, and shortening developer feedback cycles.

Finally, through two practical demos, we saw how Artifacts and Caches solve different problems while complementing one another in real-world pipelines. Understanding **when to use Outputs, Artifacts, and Caches** is an essential skill for designing efficient, scalable, and production-ready GitHub Actions workflows.

---

## References

### GitHub Documentation

* GitHub Actions Artifacts
  https://docs.github.com/actions/using-workflows/storing-workflow-data-as-artifacts

* Dependency Caching Reference
  https://docs.github.com/actions/reference/workflows-and-actions/dependency-caching

* Dependency Caching Concepts
  https://docs.github.com/actions/concepts/workflows-and-actions/dependency-caching

* Upload Artifact Action
  https://github.com/actions/upload-artifact

* Download Artifact Action
  https://github.com/actions/download-artifact

* Cache Action
  https://github.com/actions/cache

---
