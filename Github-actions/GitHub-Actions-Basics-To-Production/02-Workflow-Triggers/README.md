# GitHub Actions Triggers & Runners Explained | Events, Contexts & Hosted Runners

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/zpDH_tfOOqc/maxresdefault.jpg)](https://www.youtube.com/watch?v=zpDH_tfOOqc&ab_channel=CloudWithVarJosh)

---
## ⭐ Support the Project  
If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

- [Introduction](#introduction)  
- [Workflow Triggers in GitHub Actions](#workflow-triggers-in-github-actions)  
  - [1. Repository Events (`push`, `pull_request`, `issues`, `release`)](#1-repository-events-push-pull_request-issues-release)  
  - [2. Manual Triggers (`workflow_dispatch`)](#2-manual-triggers-workflow_dispatch)  
  - [3. Scheduled Triggers (`schedule`)](#3-scheduled-triggers-schedule)  
  - [4. External and Third-Party Triggers (`repository_dispatch`)](#4-external-and-third-party-triggers-repository_dispatch)  
  - [5. Cross-Workflow Triggers (`workflow_call`)](#5-cross-workflow-triggers-workflow_call)  
  - [Production Perspective on Workflow Trigger Categories](#production-perspective-on-workflow-trigger-categories)  
- [**Demo:** Using Different Events to Trigger Workflows](#demo-using-different-events-to-trigger-workflows)  
  - [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication)  
  - [Step 2: Understanding Built-In Contexts](#step-2-understanding-built-in-contexts)  
  - [Step 3: Using Multiple Event Types](#step-3-using-multiple-event-types)  
- [GitHub-Hosted Runner Types and Configurations](#github-hosted-runner-types-and-configurations)  
  - [Understanding GitHub-Hosted Runner Categories](#understanding-github-hosted-runner-categories)  
    - [1. Standard GitHub-Hosted Runners](#1-standard-github-hosted-runners)  
    - [2. Larger GitHub-Hosted Runners](#2-larger-github-hosted-runners)  
- [Runner Selection in Production Environments](#runner-selection-in-production-environments)  
- [**Demo:** Understanding GitHub-Hosted Runners](#demo-understanding-github-hosted-runners)  
  - [Step 1: Creating the Initial Runner Workflow](#step-1-creating-the-initial-runner-workflow)  
  - [Step 2: Extending the Workflow to Use Multiple Runner Types](#step-2-extending-the-workflow-to-use-multiple-runner-types)  
- [Conclusion](#conclusion)  
- [References](#references)  

---

## Introduction

Modern CI/CD systems are fundamentally **event-driven automation platforms** where workflows execute based on repository activities, manual operations, scheduled execution patterns, external systems, or reusable orchestration logic.

In GitHub Actions, workflows execute on systems called **runners**, which act as the compute environments responsible for executing builds, tests, deployment logic, scripts, and automation workflows.

In this lecture, we will build operational understanding around:

* **Workflow trigger categories in GitHub Actions**
* Repository, manual, scheduled, external, and reusable workflow triggers
* GitHub Actions contexts and workflow metadata access patterns
* GitHub-hosted runner architectures and execution environments
* Standard vs larger GitHub-hosted runners
* Ubuntu and Windows runner execution behavior
* Runner sizing considerations and production runner strategies

This lecture is intentionally designed to build strong conceptual clarity before moving into advanced GitHub Actions topics such as artifacts, caching, reusable workflows, self-hosted runners, and production-grade CI/CD pipelines.

---

## Workflow Triggers in GitHub Actions

![Alt text](/images/2a.png)

GitHub Actions workflows are **event-driven automation workflows**. A workflow remains idle until one or more configured events trigger its execution.

A single workflow can support **multiple trigger mechanisms simultaneously** depending on automation requirements.

Broadly, workflow triggers can be categorized into the following categories:

1. **Repository Events** → Trigger workflows automatically based on repository activities such as `push`, `pull_request`, `release`, and `issues`
2. **Manual Triggers (`workflow_dispatch`)** → Trigger workflows manually or through controlled on-demand execution mechanisms
3. **Scheduled Triggers (`schedule`)** → Execute workflows periodically using POSIX cron-based schedules
4. **External and Third-Party Triggers (`repository_dispatch`)** → Allow external systems outside GitHub to initiate workflow execution programmatically
5. **Cross-Workflow Triggers (`workflow_call`)** → Allow workflows to invoke reusable workflows directly within GitHub Actions

For the complete list of supported workflow events:
[https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)

We will now discuss each of these workflow trigger categories in detail.

---

### 1. Repository Events (`push`, `pull_request`, `issues`, `release`)

#### What it is

Repository events trigger workflows automatically whenever activities occur inside the repository, such as commits, pull requests, releases, branch creation, issue updates, or repository lifecycle operations.

These triggers form the foundation of **event-driven CI/CD automation** because workflows react automatically whenever repository state changes occur through developer or platform activity.


#### Production Use-Case

A production engineering team may configure:

* `push` events on feature, development, or integration branches to automatically trigger CI pipelines performing **Maven builds, unit tests, Docker image creation, SAST scanning, and container publishing workflows**
* `pull_request` events to execute pre-merge validation pipelines enforcing **code quality gates, SonarQube checks, dependency scanning, integration testing, and policy validation** before allowing merges into protected production branches such as `main`

> **Insight:** `pull_request`-based workflows are heavily used in production environments to shift validation and security checks earlier into the development lifecycle before code reaches protected branches.

---

### 2. Manual Triggers (`workflow_dispatch`)

#### What it is

`workflow_dispatch` allows workflows to execute only when intentionally triggered by users, operators, automation systems, or approved operational processes.

This event exposes a **Run workflow** button in the GitHub UI and also supports controlled on-demand execution through the GitHub CLI and GitHub REST API.

> **Note:** Although we’ve categorized `workflow_dispatch` under manual triggers, it is not limited only to manual execution through the GitHub UI. The `workflow_dispatch` event exposes workflows as **on-demand triggerable workflows** that can be executed using the GitHub UI, GitHub CLI, or GitHub REST API. Once a workflow contains:
>
> ```yaml id="m7q2pk"
> on:
>   workflow_dispatch:
> ```
>
> GitHub automatically enables:
>
> * the **Run workflow** button in the GitHub UI
> * CLI-based execution using:
>
> ```bash id="x8q2pw"
> gh workflow run workflow.yaml
> ```
>
> * API-based execution using the GitHub Actions workflow dispatch endpoint:
>
> ```text id="f4m8ks"
> POST /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches
> ```
> This makes `workflow_dispatch` useful for both manual operational workflows and controlled programmatic workflow execution patterns.


#### Production Use-Case

Engineering and platform teams commonly use `workflow_dispatch` workflows for:

* manually testing newly developed workflows, validating automation behavior, debugging CI/CD logic, and executing workflows on-demand when repository events such as `push` or `pull_request` are not configured or intentionally disabled
* controlled operational workflows such as **production deployments, rollback execution, infrastructure maintenance, or environment-specific automation tasks** requiring intentional human-triggered execution through the GitHub UI, GitHub CLI, or GitHub REST API

> **Insight:** `workflow_dispatch` becomes extremely useful whenever workflows must execute on-demand instead of waiting for repository, schedule, or external trigger events.


---

### 3. Scheduled Triggers (`schedule`)

#### What it is

The `schedule` event allows workflows to execute periodically at predefined intervals using **POSIX cron syntax** without requiring repository activity, manual interaction, or external trigger systems.

Example:

```yaml id="x8q2pw"
on:
  schedule:
    - cron: "*/5 * * * *"
```

GitHub officially supports a **minimum scheduling interval of 5 minutes** for scheduled workflows.

#### Production Use-Case

An enterprise DevSecOps platform may configure:

* nightly scheduled workflows performing **dependency vulnerability scanning, SBOM regeneration, container image rescanning, and compliance validation** across multiple repositories
* periodic infrastructure reconciliation workflows validating **Kubernetes cluster state, backup health, credential rotation, artifact cleanup, and operational compliance reporting**

> **Important:** GitHub Actions scheduled workflows operate using a **best-effort scheduling model** across all GitHub plans, including workflows using self-hosted runners. Although scheduled workflows are operationally reliable for most CI/CD and automation use-cases, GitHub does **not guarantee exact cron execution timing**, and workflows may experience delays during periods of high platform load. **Self-hosted runners** can **reduce** additional queueing and runner allocation delays because the execution infrastructure is controlled by the organization instead of GitHub-hosted shared runner pools.



> **Operational Insight:** Scheduled workflows are commonly used for background operational automation that does not require real-time execution guarantees.

---

### 4. External and Third-Party Triggers (`repository_dispatch`)

#### What it is

`repository_dispatch` allows workflows to be triggered by systems operating outside GitHub. External platforms can initiate workflow execution programmatically by sending HTTP POST requests along with **custom event payloads** to the GitHub REST API.

Unlike repository-native events, this trigger mechanism enables GitHub Actions to integrate with broader enterprise automation ecosystems involving operational tooling platforms, cloud services, observability systems, deployment orchestrators, and custom internal platforms.


#### Production Use-Case

A production observability or operations platform may:

* trigger GitHub Actions incident automation workflows whenever **high-severity Prometheus, Datadog, or cloud monitoring alerts** are generated, automatically initiating log collection, incident artifact generation, operational notifications, or remediation workflows
* allow enterprise orchestration systems such as **ServiceNow, internal deployment managers, or governance platforms** to initiate infrastructure provisioning, rollback execution, disaster recovery automation, or compliance workflows dynamically

> **Insight:** `repository_dispatch` is commonly used when external enterprise systems must initiate GitHub Actions workflows dynamically using externally generated operational events.

---

### 5. Cross-Workflow Triggers (`workflow_call`)

#### What it is

`workflow_call` allows workflows to invoke other workflows directly inside GitHub Actions, enabling modular, reusable, and standardized CI/CD architecture patterns across repositories and teams.

Reusable workflows help organizations centralize automation logic instead of duplicating deployment, testing, security, and compliance workflows across hundreds of repositories.

> **Note:** For engineers familiar with Jenkins, reusable workflows using `workflow_call` are conceptually similar to Jenkins Shared Libraries because both approaches promote **centralized CI/CD logic, reusable automation patterns, organizational standardization, and reduced pipeline duplication** across repositories and teams.

#### Production Use-Case

A centralized platform engineering team may:

* develop reusable enterprise-grade CI workflows implementing standardized **build, testing, security scanning, SBOM generation, artifact signing, and deployment logic** reused consistently across hundreds of repositories
* enforce organizational compliance and governance by ensuring all application teams consume **centrally managed reusable workflows** instead of maintaining fragmented custom pipeline implementations

> **Insight:** Reusable workflows become extremely important at scale because large organizations often manage hundreds or thousands of repositories requiring standardized CI/CD behavior.


---

### Production Perspective on Workflow Trigger Categories

In real production environments, organizations rarely rely on a single workflow trigger category. Modern CI/CD and platform engineering ecosystems typically combine multiple trigger mechanisms together depending on operational, security, governance, and deployment requirements.

Common production patterns include:

* **`push` and `pull_request` events** for Continuous Integration (CI), automated testing, validation pipelines, and pre-merge quality enforcement
* **`workflow_dispatch` triggers** for controlled production deployments, rollback workflows, operational maintenance, and human-approved release execution
* **`schedule` triggers** for background automation such as security scanning, dependency management, cleanup operations, compliance validation, and infrastructure reconciliation
* **`repository_dispatch` triggers** for integrating GitHub Actions with external enterprise ecosystems such as observability platforms, ITSM systems, cloud automation tooling, and deployment orchestrators
* **`workflow_call` triggers** for centralized platform engineering, reusable CI/CD standards, organizational governance, and large-scale workflow standardization

> **Operational Insight:** In production systems, the workflow trigger strategy is usually determined by the application's operational requirements, deployment criticality, governance controls, security posture, and organizational automation maturity.




---

## Demo: Using Different Events to Trigger Workflows

### Step 1: Repository Setup and Authentication

Ensure you already:

* Have a GitHub repository created
* Are authenticated with GitHub
* Can push code successfully using Git

These concepts were covered extensively in Lecture 01.

Lecture 01 Video:
https://youtu.be/w4c_NIjO3XI

Lecture 01 GitHub Notes:
https://github.com/CloudWithVarJosh/GitHub-Actions-Basics-To-Production/tree/main/01-GitHub-Actions

For this lecture, I will use the following repository throughout the demo:

* Repository Name: `cwvj-gha-practice`
* Visibility: `Private`

---

### Step 2: Understanding Built-In Contexts

We will now create a workflow file named `01-ci-contexts.yaml` inside the `.github/workflows` directory.

```yaml
name: "01 - Understanding Contexts"

on: push

jobs:
  event-info-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print Trigger Event
        run: echo "My trigger is ${{ github.event_name }} event"
```

The expression:

```yaml
${{ github.event_name }}
```

dynamically retrieves the GitHub event that triggered the workflow execution.

Breaking it down:

* `${{ }}` represents GitHub Actions expression syntax used for evaluating dynamic values during workflow execution.
* `github` refers to the built-in GitHub context object containing workflow metadata such as repository information, actor details, branch names, event payloads, workflow identifiers, and execution metadata.
* `event_name` is a property inside the `github` context object storing the exact GitHub event responsible for triggering the workflow.

Since the workflow currently uses:

```yaml
on: push
```

the output will become:

```text
My trigger is push event
```

We will now push the workflow into the repository.

```bash
# Initialize a new local Git repository
git init

# Stage all files for commit
git add .

# Create a new commit with a meaningful message
git commit -m "feat: add workflow event trigger demo"

# Rename the current branch to main
git branch -M main

# Connect the local repository to the remote GitHub repository
git remote add origin git@github.com:CloudWithVarJosh/cwvj-gha-practice.git

# Push the local main branch to GitHub
git push -u origin main
```

> **Note:** If the repository already contains files from previous demos or lectures, the push operation may fail because of unrelated Git history. You can either clean the repository beforehand or use a force (`--force`) push carefully if appropriate for the demo environment.

After pushing the workflow:

* Navigate to the **Actions** tab inside the repository.
* Observe that a new workflow run has been created automatically.
* Open the workflow execution logs and inspect the step output.
* Observe how the value of `${{ github.event_name }}` dynamically changes based on the triggering event.

At this stage, the workflow only supports the `push` event trigger.

> **Note:** GitHub Actions primarily uses a **context-based metadata system** (`github`, `runner`, `job`, `steps`, etc.) instead of relying only on flat environment variables like traditional CI/CD systems such as Jenkins.
>
> * Contexts provide **structured and namespaced workflow metadata** accessed using **expression/interpolation syntax** such as `${{ github.event_name }}` or `${{ github.event.pull_request.title }}`.
> * Unlike traditional flat environment variables, contexts support **hierarchical metadata access** through nested properties and structured event payloads.
> * Jenkins commonly exposes runtime metadata using flat environment variables such as `BUILD_NUMBER`, `JOB_NAME`, and `WORKSPACE`.
> * The context-based model provides **better organization, reduced naming collisions, richer expressions, and easier access to deeply nested workflow and event metadata** during workflow execution.


---

### Step 3: Using Multiple Event Types

GitHub Actions workflows are fundamentally **event-driven automation workflows**. A workflow remains idle until one or more configured events trigger its execution.

A single workflow can support **multiple independent trigger mechanisms simultaneously**, allowing the same automation logic to execute under different operational scenarios.

The complete list of supported workflow events is available here:
https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows

We will create a new workflow file names **`02-ci-events.yaml`**.

```yaml id="t6m2qp"
name: "02 - Understanding Events"

on:
  workflow_dispatch:
  push:
  pull_request:
  schedule:
    - cron: "*/5 * * * *"

jobs:
  event-info-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print Trigger Event
        run: echo "My trigger is ${{ github.event_name }} event"
```

Observations from the workflow configuration:

* The same workflow can now execute through **manual execution, repository events, and scheduled automation** simultaneously.
* The `on` section is now configured as a **dictionary structure** instead of a single scalar value.
* Dictionary-based trigger definitions provide significantly greater flexibility because each event can later contain **event-specific configuration** such as:

  * branch filters
  * path filters
  * activity types
  * cron schedules
  * conditional execution behavior
  * workflow input parameters

For example:

```yaml id="h9m4ks"
on:
  push:
    branches:
      - main
```

The above configuration restricts workflow execution only to pushes targeting the `main` branch.

This workflow now supports the following trigger mechanisms:

* `workflow_dispatch` → Manual execution from the GitHub UI, API, or GitHub CLI
* `push` → Automatic execution whenever commits are pushed into the repository
* `pull_request` → Automatic execution whenever pull request activities occur
* `schedule` → Periodic workflow execution using cron-based schedules

The cron expression:

```yaml id="m3q8xt"
cron: "*/5 * * * *"
```

means:

> Execute the workflow every 5 minutes.

GitHub Actions scheduled workflows use **standard cron syntax**. However, GitHub officially supports a **minimum scheduling interval of 5 minutes** for scheduled workflows.

Useful cron expression generator:
https://crontab.guru/

Important **production considerations** for scheduled workflows:

* GitHub Actions scheduled workflows operate using a **best-effort scheduling model** and are not guaranteed to start exactly on time.
* During periods of high GitHub Actions platform load, scheduled workflow execution may experience noticeable delays.
* Frequently used schedules such as `*/5 * * * *` often experience higher scheduling contention because many repositories execute at identical time boundaries.
* GitHub officially recommends avoiding heavily synchronized schedules whenever possible to reduce contention and scheduling delays.
* Scheduled workflows are commonly used for:

  * dependency update automation
  * security scanning
  * periodic cleanup tasks
  * infrastructure reconciliation
  * scheduled reporting workflows
  * health validation jobs

We will now push the updated workflow.

```bash id="f8m2qw"
# Stage the modified workflow file
git add .

# Create a new commit containing multiple workflow triggers
git commit -m "feat: add multiple workflow event triggers"

# Push the updated workflow to GitHub
git push -u origin main
```

After pushing the workflow:

* Navigate again to the **Actions** tab inside the repository.
* Observe different workflow executions being created based on different trigger mechanisms.
* Trigger the workflow manually using the **Run workflow** button available through `workflow_dispatch`.
* Create pull requests or push additional commits and observe how the triggering event changes dynamically.
* Open workflow logs and verify the value of `${{ github.event_name }}` for each workflow execution.
* Observe how the same workflow logic behaves differently depending on the event responsible for triggering execution.

> **Important Observation:** Scheduled (`cron`) workflows in GitHub Actions may not trigger immediately or precisely at configured intervals, especially in free-tier, low-activity, or highly synchronized scheduling scenarios. GitHub officially documents scheduled workflows as a **best-effort scheduling system**, and workflows may be delayed during periods of high platform load.
> Official documentation: [https://docs.github.com/en/actions/reference/events-that-trigger-workflows#schedule](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#schedule)

---

## GitHub-Hosted Runner Types and Configurations

In the previous lecture, we already understood that GitHub Actions runners are broadly categorized into:

1. **GitHub-hosted runners**
2. **Self-hosted runners**

We also discussed the operational differences between them, including:

* ephemeral vs persistent execution environments
* GitHub-managed vs organization-managed infrastructure
* isolation, scalability, and infrastructure ownership models

In this lecture, we will focus specifically on:

* how **GitHub-hosted runners** are further categorized
* what compute configurations they provide
* when organizations typically upgrade runner capacity
* what kinds of workloads require larger or specialized runners

---

### Understanding GitHub-Hosted Runner Categories

GitHub-hosted runners are fully managed compute environments provisioned and maintained by GitHub.

For every workflow job execution:

> GitHub provisions a fresh **ephemeral execution environment**.

This means:

* each job executes in an isolated environment
* jobs do not share filesystem state by default
* previous workflow executions cannot directly impact future executions
* workflow execution becomes reproducible and operationally predictable

GitHub-hosted runners are further categorized into:

1. **Standard runners**
2. **Larger runners**

---

### 1. Standard GitHub-Hosted Runners

Standard runners are included by default and provide predefined compute configurations managed entirely by GitHub.

At the time of recording, standard runners commonly provide:

| Runner Type | Approximate Configuration         |
| ----------- | --------------------------------- |
| Ubuntu      | 2-4 vCPUs, 8-16 GB RAM, 14 GB SSD |
| Windows     | 2-4 vCPUs, 8-16 GB RAM, 14 GB SSD |
| macOS       | 3-4 vCPUs, 7-14 GB RAM, 14 GB SSD |

> **Note:** Runner specifications may vary depending on repository visibility (public vs private), runner architecture, GitHub plan, and future GitHub infrastructure updates.

Official GitHub documentation:
[GitHub-Hosted Runner Specifications](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)

Standard runners are sufficient **for many common CI/CD workloads**, although actual compute, memory, and storage requirements vary significantly depending on application architecture, tooling, concurrency levels, testing strategy, and pipeline complexity.


Common standard runner labels include:

* `ubuntu-latest`
* `windows-latest`
* `macos-latest`

---
### Why Runner Sizing Matters

* Workflow execution performance directly depends on available CPU, memory, storage, network throughput, and **parallel execution capacity**
* As CI/CD complexity grows, standard runner configurations may become insufficient for large monolithic builds, multi-module Maven or Gradle builds, browser-based end-to-end testing, heavy integration testing, large Docker image builds, **SAST scanning, SBOM generation, GPU-based workloads, and high-concurrency matrix workflows**
* Insufficient runner capacity may lead to slow execution, **memory exhaustion, disk pressure, timeout failures, unstable pipeline behavior, or failed workflow execution** under heavy workload conditions


---


### 2. Larger GitHub-Hosted Runners

GitHub also provides **larger runners** for workloads requiring significantly higher compute, memory, storage, networking, or execution scale than standard runners.

Unlike standard runners, larger runners support:

* higher vCPU and memory configurations
* autoscaling capabilities
* static IP address support
* Azure private networking
* grouping and access control mechanisms
* GPU-enabled runner configurations for compute-intensive workloads

Larger runners are particularly useful for:

* high-concurrency execution workloads
* heavy parallel matrix builds
* browser-based end-to-end testing at scale
* large-scale monorepo builds
* GPU-based machine learning workloads
* performance-intensive security scanning
* enterprise deployment orchestration pipelines

> **Important:** GitHub-hosted larger runners are available only for organizations and enterprises using **GitHub Team** or **GitHub Enterprise Cloud** plans. Enterprise or organization owners manage and provision these runners.

Official documentation:
[https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners)

---

## Runner Strategy in Production Environments

Most production organizations commonly use a **hybrid runner strategy** where:

* **standard GitHub-hosted runners** handle general CI/CD workloads requiring simplicity, rapid onboarding, and minimal infrastructure management
* **self-hosted runners** handle security-sensitive, compliance-controlled, private-network, GPU-based, or highly customized workloads requiring stronger infrastructure ownership and operational control

Although GitHub also provides **larger GitHub-hosted runners**, they are typically adopted only for specific workload requirements such as:

* high-concurrency enterprise CI/CD workloads
* large-scale browser or integration testing pipelines
* GPU-based machine learning workloads
* memory-intensive security scanning or code analysis pipelines
* workflows requiring static IPs, autoscaling, or Azure private networking

In many production environments, organizations often choose **self-hosted runners instead of larger GitHub-hosted runners** whenever they require:

* deeper infrastructure customization
* stronger compliance isolation
* private networking integration
* cost optimization at scale
* Kubernetes-native runner orchestration
* long-running specialized workloads

> **Operational Insight:** Runner strategy in production environments is influenced not only by technical workload requirements, but also by security policies, compliance controls, networking constraints, infrastructure ownership models, scalability requirements, and overall CI/CD operating costs.

Official GitHub-hosted runner documentation:
[https://docs.github.com/en/actions/reference/runners/github-hosted-runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)

Official larger runner documentation:
[https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners)

Official self-hosted runner documentation:
[https://docs.github.com/en/actions/hosting-your-own-runners](https://docs.github.com/en/actions/hosting-your-own-runners)

[1]: https://docs.github.com/en/actions/using-github-hosted-runners/using-larger-runners/about-larger-runners?utm_source=chatgpt.com "Larger runners - GitHub Docs"



---

## Demo: Understanding GitHub-Hosted Runners

### Step 1: Creating the Initial Runner Workflow

We will create a new workflow file named:

```text id="m7q2pk"
03-ci-runners.yaml
```

inside:

```text id="f4m8ks"
.github/workflows/
```

Workflow file:

```yaml id="x8q2pw"
name: 03 - Understanding Runners

on: push

jobs:
  runner-info:
    runs-on: ubuntu-latest

    steps:
      - name: Print Runner Details
        run: |
          echo "Workflow is executing on a GitHub-hosted runner."
          echo "Runner Name: $RUNNER_NAME"
          echo "Runner OS: $RUNNER_OS"
          echo "Runner Architecture: $RUNNER_ARCH"
```

Observations from the workflow:

* `runs-on: ubuntu-latest` instructs GitHub Actions to provision an Ubuntu-based GitHub-hosted runner for this job.
* `RUNNER_NAME`, `RUNNER_OS`, and `RUNNER_ARCH` are predefined environment variables automatically exposed by the runner environment.
* The `|` symbol inside the `run` block represents YAML multi-line block syntax, allowing multiple shell commands to execute sequentially inside the same step.
* Without `|`, commands would typically need to be written using inline command chaining (`&&`, `;`) or alternative YAML string formats.
* The `run` block executes shell commands directly inside the provisioned runner environment.

Official predefined variable documentation:
[https://docs.github.com/en/actions/reference/variables-reference](https://docs.github.com/en/actions/reference/variables-reference)

We will now push the workflow into GitHub.

```bash id="n8q2pk"
# Stage the newly created workflow file
git add .

# Create a commit containing the runner demo workflow
git commit -m "feat: add github-hosted runner demo"

# Push workflow changes to GitHub
git push -u origin main
```

After pushing the workflow:

* Navigate to the **Actions** tab inside the repository.
* Open the latest workflow execution.
* Observe the workflow logs and runner metadata being printed.
* Open the **Set up job** section carefully.
* Expand the **Runner Image** and **Included Software** sections.
* Observe the extensive list of pre-installed software, developer tools, CLIs, SDKs, package managers, container tooling, and runtimes already available inside the GitHub-hosted runner environment.

This is operationally extremely important because:

> GitHub-hosted runners already include a large software ecosystem pre-installed.

Examples commonly available on GitHub-hosted runners include **Git, Docker, Java, Python, Node.js, .NET, Azure CLI, AWS CLI, kubectl, Terraform, along with various build tools and package managers**.


> **Note:** If your workflow requires software that is not already pre-installed, you can install it dynamically during workflow execution using shell commands or setup actions.

> **Contexts vs Environment Variables in GitHub Actions**
>
> * GitHub Actions **contexts** primarily belong to the orchestration/control plane, while **runners** act as the execution or data plane responsible for executing scripts and commands
> * Environment variables such as `RUNNER_NAME`, `RUNNER_OS`, or `GITHUB_REF` exist directly inside the runner operating system and are accessed using shell syntax such as `$VAR` or `$env:VAR`
> * Contexts such as `${{ github.event_name }}` are structured metadata objects evaluated by the GitHub Actions workflow engine using `${{ }}` expression syntax
> * Contexts can often be accessed before a job is even routed to a runner, which is why they are commonly used in workflow logic such as `if:` conditions, matrix definitions, job configuration, and conditional execution behavior
> * The evaluated context values are injected into generated scripts, step metadata, temporary files, or environment variables that are ultimately executed by the runner
> * Runners do not directly understand contexts themselves, but they do receive and execute the **resolved values** originating from those contexts during workflow execution

---

### Step 2: Extending the Workflow to Use Multiple Runner Types

We will now extend our understanding further by modifying the workflow and introducing:

* Multiple jobs
* Multiple operating systems
* Multiple GitHub-hosted runner types

We will create another workflow file named:

```text id="g7m2qs"
04-ci-runners.yaml
```

Workflow file:

```yaml id="t6m2qw"
name: 04 - Understanding Runners (Win + Ubuntu)

on: push

jobs:
  ubuntu-runner:
    runs-on: ubuntu-latest

    steps:
      - name: Print Ubuntu Runner Details
        run: |
          echo "Workflow is executing on a GitHub-hosted Ubuntu runner."
          echo "Runner Name: $RUNNER_NAME"
          echo "Runner OS: $RUNNER_OS"
          echo "Runner Architecture: $RUNNER_ARCH"

  windows-runner:
    runs-on: windows-latest

    steps:
      - name: Print Windows Runner Details
        shell: bash

        run: |
          echo "Workflow is executing on a GitHub-hosted Windows runner."
          echo "Runner Name: $RUNNER_NAME"
          echo "Runner OS: $RUNNER_OS"
          echo "Runner Architecture: $RUNNER_ARCH"
```

Important observations from the workflow:

* The workflow now contains two completely independent jobs executing on different operating systems.
* `ubuntu-latest` provisions an Ubuntu-based GitHub-hosted runner.
* `windows-latest` provisions a Windows-based GitHub-hosted runner.
* Different jobs inside the same workflow can execute on entirely different runner operating systems simultaneously.
* Each job still receives its own fresh isolated ephemeral runner environment.
* Jobs do not share filesystem state, installed software, runtime memory, or generated artifacts by default.

Special attention should be given to the following configuration:

```yaml id="a5m8kt"
shell: bash
```

This is important because:

* Ubuntu runners use Bash by default.
* Windows runners commonly execute commands using PowerShell by default.
* Our commands use Bash-style environment variable syntax such as:

```bash id="z4m8qt"
$RUNNER_NAME
```

which would not work correctly using native PowerShell syntax.

By explicitly configuring:

```yaml id="m4q8ks"
shell: bash
```

we instruct the Windows runner to execute commands using Git Bash instead of PowerShell.

GitHub-hosted Windows runners already include Git Bash pre-installed, allowing Bash-based execution even on Windows systems.

This approach keeps the syntax:

* consistent
* beginner-friendly
* cross-platform compatible

This is operationally important because:

* Different operating systems provide different tooling ecosystems.
* Some enterprise applications require Windows-specific execution environments.
* Some workflows require Linux-native tooling.
* Cross-platform CI/CD validation often requires testing applications across multiple operating systems simultaneously.

We will now push the updated workflow.

```bash id="q4m8ks"
# Stage the multi-runner workflow
git add .

# Create a commit containing Ubuntu and Windows runner jobs
git commit -m "feat: add multi-runner workflow demo"

# Push workflow changes to GitHub
git push -u origin main
```

After pushing the workflow:

* Navigate again to the **Actions** tab.
* Observe that multiple jobs execute independently inside the same workflow.
* Open both job logs and compare runner metadata outputs.
* Observe how different operating systems are provisioned dynamically for different jobs.
* Compare software availability, execution behavior, shell behavior, and runner metadata across Ubuntu and Windows environments.
* Observe that both jobs execute inside isolated ephemeral runner environments even though they belong to the same workflow execution.
* Open the **Set up job** section for both runners and compare the installed software ecosystems available inside Ubuntu and Windows GitHub-hosted runners.

---

## Conclusion

In this lecture, we explored how GitHub Actions workflows are triggered and how workflow execution environments behave operationally.

We covered:
* repository, manual, scheduled, external, and reusable workflow triggers
* GitHub Actions contexts and workflow metadata
* GitHub-hosted runner architectures
* standard vs larger runners
* Ubuntu and Windows runner execution behavior
* runner sizing considerations and production runner strategies

Through the demos, we also observed:
* event-driven workflow execution
* predefined runner environment variables
* ephemeral runner behavior
* cross-platform workflow execution patterns

These concepts form the operational foundation for advanced GitHub Actions topics such as reusable workflows, artifacts, caching, deployment pipelines, self-hosted runners, and production CI/CD orchestration.

---

## References

* GitHub Actions Events Documentation  
  https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows

* GitHub Actions Variables Reference  
  https://docs.github.com/en/actions/reference/variables-reference

* GitHub Actions Contexts Reference  
  https://docs.github.com/en/actions/reference/workflows-and-actions/contexts

* GitHub-Hosted Runner Documentation  
  https://docs.github.com/en/actions/reference/runners/github-hosted-runners

* Larger GitHub-Hosted Runners  
  https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners

* Self-Hosted Runner Documentation  
  https://docs.github.com/en/actions/hosting-your-own-runners

* GitHub Actions Workflow Syntax  
  https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
