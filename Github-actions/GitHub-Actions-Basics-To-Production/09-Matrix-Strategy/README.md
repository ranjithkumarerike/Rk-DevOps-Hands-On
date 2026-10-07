# GitHub Actions Matrix Strategy Explained | Multi-OS, Multi-Version Testing at Scale

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/B5XzHnO_guo/maxresdefault.jpg)](https://www.youtube.com/watch?v=B5XzHnO_guo&ab_channel=CloudWithVarJosh)

---

## ⭐ Support the Project  

If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

- [Introduction](#introduction)  
- [Why & What of Matrix Strategy?](#why--what-of-matrix-strategy)  
  - [Why Matrix Strategy?](#why-matrix-strategy)  
  - [What is Matrix Strategy?](#what-is-matrix-strategy)  
- [**Demo:** Testing Across Multiple Python Versions Using Matrix Strategy](#demo-testing-across-multiple-python-versions-using-matrix-strategy)  
  - [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication)  
  - [Step 2: Preparing the Application](#step-2-preparing-the-application)  
    - [Step 2.1: Create the Flask Application](#step-21-create-the-flask-application)  
    - [Step 2.2: Create the Requirements File](#step-22-create-the-requirements-file)  
  - [Step 3: Creating the Workflow](#step-3-creating-the-workflow)  
  - [Step 4: Commit and Push the Changes](#step-4-commit-and-push-the-changes)  
  - [Step 5: Running the Workflow](#step-5-running-the-workflow)  
  - [Step 6: Observing Workflow Execution](#step-6-observing-workflow-execution)  
- [Conclusion](#conclusion)  
- [References](#references)  

---

## Introduction

In the previous lectures, we learned how to build workflows, share information using **Outputs**, preserve workflow-generated files using **Artifacts**, and improve workflow performance using **Caching**.

In this lecture, we will explore **Matrix Strategy**, one of the most powerful features in GitHub Actions for executing the **same job across multiple environments** without duplicating workflow logic.

We will begin by understanding **why Matrix Strategy is needed**, the challenges it solves, and how GitHub automatically generates multiple job executions from a **single job definition**. We will then build a complete hands-on demo that validates a Python application across multiple **Python versions**, while also learning how **Matrix Variables**, the **Matrix Context**, and **parallel job execution** work under the hood.

By the end of this lecture, you will understand how to design **scalable**, **maintainable**, and **production-ready** GitHub Actions workflows that can validate applications across different operating systems, runtime versions, browsers, databases, cloud providers, and many other environments.

---

## Why & What of Matrix Strategy?

![Alt text](/images/9a.png)

### Why Matrix Strategy?

So far in this course, every workflow that we have created has executed a **single job** on a **single runner**.

For many applications, this is perfectly sufficient.

However, whether a single environment is enough depends entirely on **how your software is distributed and where it runs**.

Some applications are deployed onto platforms such as:

* Kubernetes
* Amazon ECS
* Azure Container Apps
* Google Cloud Run

In these environments, the runtime is usually **standardized**. Every deployment is built from the same container image, making the operating system, runtime version, and application dependencies consistent across environments.

For these applications, testing against a single environment is often sufficient because every deployment behaves almost identically.

However, not every application is deployed this way.

Many applications are distributed or deployed into environments that **you do not control**.

For example:

* **Virtual Machines:** Your application may be deployed onto customer-managed VMs where different operating systems, Python versions, Java versions, installed libraries, or system configurations already exist.
* **Desktop Applications:** Software distributed for **Windows**, **macOS**, and **Linux** must be validated on every supported operating system before release.
* **CLI Tools & SDKs:** Developers install these tools on their own laptops using different operating systems and runtime versions.
* **Open Source Projects:** Maintainers cannot control the environments used by the community, so applications are often tested across multiple platforms before publishing.
* **Libraries & Frameworks:** If you publish a Python package, Node.js package, Java library, or similar artifact, users expect it to work across every officially supported runtime version.

If you've ever downloaded software from the Internet, you've probably seen messages similar to:

```text
Requires Java 17 or later
Supports Python 3.11+
Compatible with Windows, macOS and Linux
```

These compatibility statements are not assumptions. They are usually the result of testing the application across multiple operating systems and runtime versions before release.

This immediately creates a challenge for CI/CD pipelines.

Suppose our Python application officially supports:

```text
Ubuntu
Windows
macOS
```

and also supports:

```text
Python 3.11
Python 3.12
Python 3.13
```

Simply validating the application on:

```text
Ubuntu + Python 3.13
```

does **not** guarantee that it will behave correctly everywhere.

For example:

* A dependency may behave differently on **Windows** than on **Linux**.
* A library compatible with **Python 3.13** may produce unexpected behavior on **Python 3.11**.
* File paths, shell commands, environment variables, or filesystem behavior may vary across operating systems.

As a result, organizations often validate their applications against every supported combination before releasing software.

```text
Ubuntu   + Python 3.11
Ubuntu   + Python 3.12
Ubuntu   + Python 3.13

Windows  + Python 3.11
Windows  + Python 3.12
Windows  + Python 3.13

macOS    + Python 3.11
macOS    + Python 3.12
macOS    + Python 3.13
```

Now imagine implementing this using only the concepts we've learned so far.

One approach would be to create a separate job for every combination.

```text
test-ubuntu-python311
test-ubuntu-python312
test-ubuntu-python313

test-windows-python311
test-windows-python312
test-windows-python313

test-macos-python311
test-macos-python312
test-macos-python313
```

Even this small example already requires **nine nearly identical jobs**.

Now suppose we also need to validate:

```text
PostgreSQL 15
PostgreSQL 16
```

and later:

```text
Chrome
Firefox
Edge
Safari
```

The number of required jobs quickly becomes:

```text
3 Operating Systems
× 3 Python Versions
× 2 Database Versions
× 4 Browsers

= 72 Job Executions
```

Add another dimension:

```text
AWS
Azure
Google Cloud
```

and it becomes:

```text
3 × 3 × 2 × 4 × 3

= 216 Job Executions
```

Imagine manually creating and maintaining **216 nearly identical jobs**, where the only differences are the operating system, runtime version, browser, database version, or cloud provider.

Even a small workflow change would need to be copied into every one of those jobs, making the workflow difficult to maintain and highly prone to configuration drift.

The obvious question becomes:

> ***Can we define a job only once and have GitHub automatically execute it multiple times using different combinations of values, instead of manually creating hundreds of nearly identical jobs?***

We will answer this question next when we discuss **Matrix Strategy**.

---

### What is Matrix Strategy?

![Alt text](/images/9a.png)

Now that we understand the problem, the next question becomes:

> ***How can we execute the same job multiple times using different combinations of values without manually creating separate jobs?***

GitHub Actions solves this problem using a feature called **Matrix Strategy**.

A **Matrix Strategy** allows a **single job definition** to execute **multiple times**, with each execution using a different combination of values that you specify.

For example, consider the following workflow:

```yaml
jobs:
  test-job:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ["3.11", "3.12", "3.13"]

    runs-on: ${{ matrix.os }}

    steps:
      - name: Setup Python
        uses: actions/setup-python@v6
        with:
          python-version: ${{ matrix.python-version }}

      - name: Run Tests
        run: pytest
```

Notice that this workflow contains **only one job**:

```yaml
test-job:
```

However, because we defined a **Matrix Strategy**, GitHub does **not** execute this job just once.

Instead, it automatically generates multiple job executions by combining every operating system with every Python version.

Conceptually:

```text
test-job
      ↓
Matrix Expansion
      ↓
Automatically Generated Job Executions
```

Result:

```text
Ubuntu   + Python 3.11
Ubuntu   + Python 3.12
Ubuntu   + Python 3.13

Windows  + Python 3.11
Windows  + Python 3.12
Windows  + Python 3.13

macOS    + Python 3.11
macOS    + Python 3.12
macOS    + Python 3.13
```

GitHub therefore executes:

```text
3 Operating Systems × 3 Python Versions = 9 Job Executions
```

Each generated job receives its own **GitHub-hosted runner**, executes independently of the others, and produces its own logs, status, and results.

Notice another important detail.

We never hardcoded:

```yaml
runs-on: ubuntu-latest
```

Instead, we wrote:

```yaml
runs-on: ${{ matrix.os }}
```

Similarly, instead of writing:

```yaml
python-version: "3.13"
```

we wrote:

```yaml
python-version: ${{ matrix.python-version }}
```

This allows GitHub Actions to substitute the appropriate values for each generated job.

For example, one generated job receives:

```text
matrix.os             → ubuntu-latest
matrix.python-version → 3.11
```

while another receives:

```text
matrix.os             → windows-latest
matrix.python-version → 3.12
```

and another receives:

```text
matrix.os             → macos-latest
matrix.python-version → 3.13
```

This means the **workflow logic remains identical**, while the **execution environment changes** automatically for every generated job.

Conceptually:

```text
Same Workflow Logic
        ↓
Different Matrix Values
        ↓
Different Job Executions
```

This provides several advantages:

* **Eliminates duplicate workflow definitions**, since the job is written only once.
* **Improves maintainability**, because workflow changes are made in a single location.
* **Scales easily**, allowing additional operating systems, runtime versions, browsers, cloud providers, or deployment environments to be added with minimal changes.
* **Supports parallel execution**, significantly reducing overall workflow execution time.

> **Key Observation:** A Matrix Strategy does **not** create different workflow logic. It creates **multiple executions of the same job**, where each execution receives a different set of **matrix values**.

> **Production Insight:** Matrix Strategies are commonly used to validate applications across multiple **operating systems**, **programming language versions**, **database versions**, **browser versions**, **Kubernetes versions**, and **cloud providers**. Instead of maintaining dozens of nearly identical jobs, organizations define a single job and let GitHub automatically generate the required execution matrix.

> **Key Observation:**
>
> * A **Matrix Strategy** does **not** cause a single runner to execute the same job repeatedly. Instead, GitHub expands the matrix into **multiple independent job executions**.
> * Every generated job receives its own **fresh GitHub-hosted runner**, executes the **entire sequence of workflow steps** independently, and produces its own **logs**, **status**, and **results**.
> * By default, GitHub attempts to **schedule matrix jobs in parallel**. However, the actual execution order depends on **runner availability** and is **not guaranteed**.
> * Since every matrix combination is treated as a separate job execution, **runner consumption and billing increase with the number of generated jobs**, even though the workflow contains only a **single job definition**.

---


## Demo: Testing Across Multiple Python Versions Using Matrix Strategy

In this demo, we will learn how **Matrix Strategy** allows GitHub Actions to execute the same job multiple times using different runtime configurations.

More specifically, we will:

* define a **Matrix Strategy** containing multiple Python versions
* automatically generate multiple job executions from a single job definition
* execute the same workflow steps using each Python version
* verify that the application behaves consistently across all supported runtimes

By the end of this demo, you will understand how Matrix Strategy eliminates duplicate workflow definitions while making it easy to validate applications across multiple environments.

---

### Step 1: Repository Setup and Authentication

Before starting this demo, ensure that you already:

* have a GitHub repository created
* are authenticated with GitHub
* can push code successfully using Git

These concepts were covered extensively in **Lecture 01**.

* **Lecture 01 Video**
  [https://youtu.be/w4c_NIjO3XI](https://youtu.be/w4c_NIjO3XI)

* **Lecture 01 GitHub Notes**
  [https://github.com/CloudWithVarJosh/GitHub-Actions-Basics-To-Production/tree/main/01-GitHub-Actions](https://github.com/CloudWithVarJosh/GitHub-Actions-Basics-To-Production/tree/main/01-GitHub-Actions)

For this lecture, we will use the following repository:

* **Repository Name:** `cwvj-gha-practice`
* **Visibility:** Private

> **Operational Note:** GitHub Actions workflows execute directly inside repositories. Whenever workflow YAML files are pushed into the repository, GitHub automatically discovers them and evaluates whether they should execute based on their configured workflow triggers.

---

### Step 2: Preparing the Application

Before creating the workflow, we first need a simple application that can execute successfully regardless of the Python version selected by the Matrix Strategy.

In this step, we will:

* create a lightweight **Flask application**
* define the application's Python dependencies
* prepare the workflow file that will execute the application using multiple Python versions

Unlike the previous lecture, **we do not need Docker** because our objective is not to build or package the application. Instead, we want to focus entirely on understanding how **Matrix Strategy** generates multiple job executions from a single workflow definition.

Place all files under:

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
        └── 01-matrix-demo.yaml
```

> **Why are we creating these components?**
>
> Matrix Strategy executes the **same workflow** multiple times using different matrix values. To clearly observe this behavior, we need a simple application that behaves consistently regardless of which Python version executes it. Keeping the application simple allows us to focus entirely on how the workflow expands into multiple job executions.

---

### Step 2.1: Create the Flask Application

Create the following Flask application.

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

#### Understanding the Application

This application:

* creates a lightweight **Flask web server**
* exposes an application endpoint at **`/`**
* exposes a health endpoint at **`/health`**
* listens on port **5000**
* generates simple runtime logs

The application generates log messages such as:

```text
Cloud With VarJosh Flask Application Started
Home endpoint invoked
Health endpoint invoked
```

During the workflow, we will start the application, validate it using the **`/health`** endpoint, display the configured Python version, and then terminate the application before the job completes.

> **Operational Note:** Production CI/CD pipelines commonly expose health endpoints that are used by smoke tests, monitoring systems, load balancers, Kubernetes readiness probes, and deployment validation workflows.

---

#### Optional Deep Dive

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

#### Step 2.2: Create the Requirements File

Create the following dependency file.

**`requirements.txt`**

```text
flask==3.1.1
```

#### Understanding the Requirements File

This file defines the Python dependencies required by the application.

For this demo, we require only one dependency:

```text
Flask 3.1.1
```

When the workflow executes, GitHub Actions installs this dependency before starting the application. Because every matrix job executes on a **fresh GitHub-hosted runner**, each generated job performs its own dependency installation.

Pinning dependency versions ensures consistent behavior across developer machines, CI/CD pipelines, testing environments, and production systems.

> **Operational Note:** In later lectures, we will combine **Matrix Strategy** with **GitHub Actions Caching** so that dependency installation can be accelerated even when multiple matrix jobs are generated.

---

### Step 3: Creating the Workflow

Create the following workflow file.

**`.github/workflows/01-matrix-demo.yaml`**

```yaml
name: 01 - Matrix Strategy Demo

on:
  workflow_dispatch:

jobs:
  test-job:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version:
          - "3.11"
          - "3.12"
          - "3.13"

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v5

      - name: Setup Python
        uses: actions/setup-python@v6
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install Dependencies
        run: |
          pip install -r requirements.txt

      - name: Execute Application
        run: |
          python app.py &
          APP_PID=$!

          sleep 5

          curl --fail http://127.0.0.1:5000/health

          echo "Application executed successfully."

          echo "Matrix Python Version : ${{ matrix.python-version }}"
          python --version

          kill $APP_PID
```

---

#### Explanation

> **Note:** The workflow contains several steps such as **Checkout Repository**, **Setup Python**, and **Install Dependencies**, which we have already covered in detail in previous lectures. To avoid unnecessary repetition, we will focus primarily on the new concepts introduced in this lecture, namely **Matrix Strategy**, the **Matrix Context**, and how GitHub Actions automatically generates multiple job executions from a single job definition. Where appropriate, we will briefly revisit earlier concepts and explain how they interact with Matrix Strategy.

---

```yaml
name: 01 - Matrix Strategy Demo
```

* This block defines the **workflow name** displayed in the **GitHub Actions UI**. We have discussed this in previous lectures, and it simply helps identify workflow runs.

---

```yaml
on:
  workflow_dispatch:
```

* This block configures the workflow to execute only when it is **manually triggered**. We covered **`workflow_dispatch`** in detail in earlier lectures, so we will use it here without revisiting its implementation.

---

```yaml
jobs:
  test-job:
```

* This block defines the **job** that GitHub Actions will execute. Unlike our previous workflows, this job will **not execute just once** because we are introducing a **Matrix Strategy**, which automatically generates multiple executions of the same job.

---

```yaml
runs-on: ubuntu-latest
```

* This block instructs GitHub Actions to execute the job on a **GitHub-hosted Ubuntu runner**. As discussed previously, GitHub-hosted runners are **ephemeral**. Later in this lecture, we'll see that **every generated matrix job receives its own fresh runner**, even though all jobs use the same `ubuntu-latest` image.

---

```yaml
strategy:
  matrix:
    python-version:
      - "3.11"
      - "3.12"
      - "3.13"
```

* This block defines the **Matrix Strategy** for the job.
* A **strategy** determines **how a job should execute**. GitHub Actions supports several strategy-related features, one of the most commonly used being **Matrix Strategy**.
* The **`matrix`** block defines one or more **Matrix Variables** along with the values they should iterate over during workflow execution.
* In this example, we define a single Matrix Variable named **`python-version`**, containing the following values:

```text
3.11
3.12
3.13
```

Unlike a traditional workflow where a job executes only once, GitHub Actions automatically expands the Matrix and generates one independent job execution for each value.

Conceptually:

```text
One Job Definition
        ↓
Matrix Expansion
        ↓
Job 1 → Python 3.11
Job 2 → Python 3.12
Job 3 → Python 3.13
```

Although our workflow defines only **one job**, GitHub internally generates **three independent job executions**, each configured with a different Python version.

Remember what we learned earlier in the course: **every GitHub-hosted job executes on its own fresh, ephemeral runner by default**. Matrix Strategy does **not** change this behavior. Instead, every generated Matrix job is treated as a completely independent job, meaning GitHub provisions a separate runner for every generated job, even when all jobs use the same operating system.

Conceptually:

```text
Job 1 → Ubuntu Runner #1 → Python 3.11

Job 2 → Ubuntu Runner #2 → Python 3.12

Job 3 → Ubuntu Runner #3 → Python 3.13
```

This means every generated job:

* executes the **same workflow steps**
* runs on its own **fresh GitHub-hosted runner**
* has its own **logs**, **status**, and **results**
* is isolated from every other generated job

> **Key Observation:** A **Matrix Strategy** does **not** duplicate your workflow. Instead, GitHub automatically generates **multiple executions of the same job**, where each execution receives a different **Matrix Value** while following the same workflow definition.

> **Production Insight:** Matrix Variables are **not limited to programming language versions**. Organizations commonly create matrices for **operating systems**, **compiler versions**, **database versions**, **browser versions**, **cloud providers**, **Kubernetes versions**, **deployment environments**, and many other dimensions.

---

```yaml
python-version: ${{ matrix.python-version }}
```

* We previously studied **Expressions**, **Functions**, and **Contexts** earlier in this course. The syntax:

```yaml
${{ ... }}
```

represents a **GitHub Actions Expression**.

* In this lecture, GitHub automatically provides a new context called the **Matrix Context**.
* The **`matrix`** context exposes the Matrix Values associated with the current job execution.

For example, one generated job receives:

```text
matrix.python-version → 3.11
```

another receives:

```text
matrix.python-version → 3.12
```

while another receives:

```text
matrix.python-version → 3.13
```

These values are then supplied to the **Setup Python Action**:

```yaml
python-version: ${{ matrix.python-version }}
```

As a result, every generated job installs a different version of Python while executing exactly the same workflow steps.

Conceptually:

```text
Matrix Value
        ↓
Setup Python
        ↓
Install Corresponding Python Version
```

> **Connection to Previous Lectures:** Earlier in the course, we worked with contexts such as **`github`**, **`runner`**, **`steps`**, and **`inputs`**. The **`matrix`** context follows the same principle. The only difference is that its values are automatically generated from the **Matrix Strategy**.

---

```yaml
- name: Execute Application
  run: |
    python app.py &
    APP_PID=$!

    sleep 5

    curl --fail http://127.0.0.1:5000/health

    echo "Application executed successfully."

    echo "Matrix Python Version : ${{ matrix.python-version }}"
    python --version

    kill $APP_PID
```

* This step starts the Flask application, validates that it has started successfully, displays the configured Python version, and then terminates the application before the job completes.
* The application is started in the **background** using:

```bash
python app.py &
```

* The **`&`** symbol instructs the shell to start the application as a **background process**.
* Without **`&`**, the workflow would wait for **`python app.py`** to terminate before executing the next command. Since a Flask application continues running until it is explicitly stopped, the workflow would remain blocked at this step.
* Running the application in the background allows the workflow to continue executing the remaining commands while the Flask application continues serving requests.

* Immediately afterwards:

```bash
APP_PID=$!
```

* The special Bash variable **`$!`** contains the **Process ID (PID)** of the most recently started background process.
* By storing this value in the **`APP_PID`** variable, we can later terminate the exact Flask application started by the workflow.


* The command:

```bash
sleep 5
```

provides the application with sufficient time to start before the workflow attempts to access it.

* The following command performs a simple **health check**:

```bash
curl --fail http://127.0.0.1:5000/health
```

* This command sends an HTTP request to the application's **`/health`** endpoint to verify that the application has started successfully.
* The **`--fail`** option instructs **`curl`** to return a **non-zero exit code** if the server responds with an HTTP error status such as **404**, **500**, or **503**.
* GitHub Actions treats a non-zero exit code as a **step failure**, causing the workflow to stop immediately unless configured otherwise.

If the application responds successfully with an HTTP status code in the **2xx** range, the workflow continues. Otherwise, the step fails immediately.

* Once the application has been validated, we display both:

```text
Matrix Python Version
```

and

```text
Actual Installed Python Version
```

using:

```bash
echo "Matrix Python Version : ${{ matrix.python-version }}"
python --version
```

This allows us to verify that the **Matrix Value** supplied to the **Setup Python Action** matches the version that was actually installed on the runner.

Finally:

```bash
kill $APP_PID
```

terminates the Flask application, allowing the workflow to complete successfully.

Conceptually:

```text
Start Application
        ↓
Validate Health Endpoint
        ↓
Display Matrix Python Version
        ↓
Display Installed Python Version
        ↓
Stop Application
```

> **Key Observation:** A **Matrix Strategy** does **not** cause a single runner to execute the same job repeatedly with different values. Instead, GitHub expands the Matrix into **multiple independent job executions**.
>
> * Every generated job receives its own **fresh GitHub-hosted runner**, executes the **entire sequence of workflow steps** independently, and produces its own **logs**, **status**, and **results**.
> * By default, GitHub attempts to **schedule Matrix jobs in parallel**. However, the actual execution order depends on **runner availability** and is **not guaranteed**.
> * Since every Matrix combination is treated as a separate job execution, **runner consumption and billing increase with the number of generated jobs**, even though the workflow contains only a **single job definition**.

---

### Step 4: Commit and Push the Changes

Commit the workflow and push it to GitHub.

```bash
# Add all workflow, application, and configuration changes to the Git staging area
git add .

# Create a commit containing the Matrix Strategy demo implementation
git commit -m "feat: add matrix strategy demo"

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
→ 01 - Matrix Strategy Demo
→ Run Workflow
```

and click:

```text
Run Workflow
```

to start the workflow.

> **Key Observation:** We are using **`workflow_dispatch`** because it gives us complete control over when the workflow executes. This allows us to repeatedly observe how **Matrix Strategy** expands a single job definition into multiple independent job executions without generating unnecessary workflow runs.

> **Production Insight:** During development and troubleshooting, engineers frequently use **manual workflow triggers** to validate workflow changes, test Matrix configurations, verify application compatibility across different environments, and troubleshoot CI/CD pipelines before enabling automatic triggers such as **`push`** or **`pull_request`**.

---

### Step 5: Running the Workflow

Inside the repository:

1. Navigate to the **Actions** tab.
2. Select **01 - Matrix Strategy Demo**.
3. Click **Run Workflow**.
4. Click **Run Workflow** again to start the execution.

GitHub now provisions the required runners and begins executing the workflow.

Although our workflow defines only a single job:

```yaml
jobs:
  test-job:
```

GitHub automatically expands the Matrix into **three independent job executions**, one for each configured Python version.

Conceptually:

```text
One Job Definition
        ↓
Matrix Expansion
        ↓
Job 1 → Python 3.11
Job 2 → Python 3.12
Job 3 → Python 3.13
```

As the workflow begins executing, you will notice **three separate jobs** in the GitHub Actions UI, even though the workflow YAML contains only a **single job definition**.

> **Key Observation:** This is the core purpose of **Matrix Strategy**. Instead of manually creating multiple nearly identical jobs, GitHub automatically generates one job execution for every Matrix Value.

---

### Step 6: Observing Workflow Execution

Open the workflow run and observe the jobs generated by GitHub Actions.

You should see three independent job executions similar to:

```text
test-job (3.11)
test-job (3.12)
test-job (3.13)
```

Each job executes the **same sequence of workflow steps**, but with a different Matrix Value.

During execution, each job will:

```text
Checkout Repository
→ Setup Python
→ Install Dependencies
→ Start Application
→ Validate Health Endpoint
→ Display Python Version
→ Stop Application
```

When you inspect the logs of each job, notice the following output:

**Job 1**

```text
Matrix Python Version : 3.11
Python 3.11.x
```

**Job 2**

```text
Matrix Python Version : 3.12
Python 3.12.x
```

**Job 3**

```text
Matrix Python Version : 3.13
Python 3.13.x
```

This confirms that GitHub automatically substituted the appropriate Matrix Value for each job before executing the workflow.

Conceptually:

```text
Matrix Value
        ↓
Setup Python
        ↓
Install Matching Python Version
        ↓
Execute Same Workflow Steps
```

Although every job performs exactly the same activities, each executes using a different Python runtime.

> **Key Observation:** A Matrix Strategy generates **multiple independent job executions**, not multiple workflow definitions. Every generated job receives its own **fresh GitHub-hosted runner**, executes the **same workflow steps**, and produces its own **logs**, **status**, and **results**.

> **Try This:** Modify the Matrix by adding another Python version, for example:

```yaml
python-version:
  - "3.10"
  - "3.11"
  - "3.12"
  - "3.13"
```

Execute the workflow again.

Instead of **three jobs**, GitHub will now generate **four independent job executions**, demonstrating that the number of generated jobs automatically scales with the number of Matrix Values you define.

---

## Conclusion

In this lecture, we learned how **Matrix Strategy** eliminates the need to manually create multiple nearly identical jobs by allowing GitHub Actions to automatically generate multiple job executions from a **single job definition**.

We understood **why Matrix Strategy is needed**, how **Matrix Variables** and the **Matrix Context** work, how GitHub expands a matrix into multiple independent job executions, and why every generated job receives its own **fresh GitHub-hosted runner**.

Through a hands-on demo, we validated a Python application across multiple **Python versions**, observed how Matrix Strategy creates separate jobs, and verified that each job executes independently while following the same workflow logic.

In the next lecture, we will continue exploring more advanced GitHub Actions capabilities and build upon the concepts learned so far to create even more flexible and production-ready CI/CD workflows.

---

## References

* **GitHub Actions Matrix Strategy**
  https://docs.github.com/actions/using-jobs/using-a-matrix-for-your-jobs

* **Workflow Syntax for GitHub Actions**
  https://docs.github.com/actions/reference/workflows-and-actions/workflow-syntax

* **GitHub Contexts**
  https://docs.github.com/actions/learn-github-actions/contexts

* **Expressions**
  https://docs.github.com/actions/learn-github-actions/expressions

* **actions/setup-python**
  https://github.com/actions/setup-python

---
