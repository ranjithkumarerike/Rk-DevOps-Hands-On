# What is GitHub Actions | Build Your First Workflow from Scratch

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/w4c_NIjO3XI/maxresdefault.jpg)](https://www.youtube.com/watch?v=w4c_NIjO3XI)

---
## ⭐ Support the Project  
If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

- [Introduction](#introduction)
- [Pre-requisites for This Course](#pre-requisites-for-this-course)
- [CI/CD Tooling Landscape](#cicd-tooling-landscape)
- [What is CI/CD?](#what-is-cicd)
  - [Continuous Integration (CI)](#continuous-integration-ci)
  - [Continuous Delivery & Continuous Deployment (CD)](#continuous-delivery--continuous-deployment-cd)
  - [Example: Typical CI/CD Pipeline for a Java Containerized Application](#example-typical-cicd-pipeline-for-a-java-containerized-application)
  - [Comparing Popular CI/CD Tools](#comparing-popular-cicd-tools)
- [What is GitHub Actions?](#what-is-github-actions)
  - [Why GitHub Actions Became Popular](#why-github-actions-became-popular)
    - [Advantages of Platform-Native CI/CD](#advantages-of-platform-native-cicd)
    - [Advantages Specific to GitHub Actions](#advantages-specific-to-github-actions)
- [Core Constructs of GitHub Actions](#core-constructs-of-github-actions)
    - [Workflow](#1-workflow)
    - [Jobs](#2-jobs)
    - [Steps](#3-steps)
 - [Runners](#runners)
   - [GitHub-Hosted Runners](#1-github-hosted-runners)
   - [Self-Hosted Runners](#2-self-hosted-runners)
- [Putting Everything Together](#putting-everything-together)
- [**Demo:** Creating Your First Workflow](#demo-creating-your-first-workflow)
  - [Step 1: Create a Private Repository](#step-1-create-a-private-repository)
  - [Step 2: Authenticate to GitHub Using SSH](#step-2-authenticate-to-github-using-ssh)
  - [Step 3: Create the Workflow Structure](#step-3-create-the-workflow-structure)
  - [Step 4: Push to GitHub](#step-4-push-to-github)
  - [Step 5: Verify Workflow Execution on GitHub](#step-5-verify-workflow-execution-on-github)
  - [Bonus Step: Trigger the Workflow Again](#bonus-step-trigger-the-workflow-again)
- [Conclusion](#conclusion)
- [References](#references)

---

## Introduction

Modern software delivery requires engineering teams to **build, test, secure, package, and deploy applications** rapidly, reliably, and at scale. Performing these operations manually introduces **inconsistency, operational bottlenecks, deployment risks, and reduced engineering velocity**.

This is where **CI/CD platforms** become critical.

**GitHub Actions** is GitHub’s **event-driven automation and workflow orchestration platform** that enables teams to automate modern software delivery workflows directly from GitHub repositories.

In this lecture, we will build a strong foundational understanding of:

- **CI/CD fundamentals**
- The modern **CI/CD tooling landscape**
- **GitHub Actions architecture and execution model**
- **Workflows, jobs, steps, and runners**
- **GitHub-hosted vs self-hosted runners**
- Workflow execution behavior
- Creating and executing your first GitHub Actions workflow

This lecture is intentionally designed to build **conceptual clarity** before moving into **production-grade CI/CD pipelines** later in the series.

---

## Pre-requisites for This Course

Before starting this course, there are a few important concepts and tools you should already be comfortable with. GitHub Actions is an **automation and orchestration platform**, so understanding the surrounding ecosystem is extremely important for long-term success.

Everything required for this course has already been covered on this channel.

---

#### **1. Understanding Git**

Git is the **de-facto standard** for version controlling code and forms the foundation of modern software engineering, DevOps, CI/CD, and platform engineering workflows.

Since GitHub Actions workflows are tightly integrated with **Git repositories** and **Git events**, you must understand Git concepts thoroughly before moving ahead.

Recommended topics:

* **Commits** and commit history
* **Branching** and merging
* **Rebasing** and cherry-picking
* **Pull requests** and code reviews
* **Remote repositories**
* Git workflows used in production

Resources:

* YouTube Playlist:
  [https://www.youtube.com/playlist?list=PLmPit9IIdzwT6nq8hIuf7MBcPVzw3cX3K](https://www.youtube.com/playlist?list=PLmPit9IIdzwT6nq8hIuf7MBcPVzw3cX3K)

* GitHub Notes:
  [https://github.com/CloudWithVarJosh/Git-Masterclass](https://github.com/CloudWithVarJosh/Git-Masterclass)

---

#### **2. Understanding YAML**

YAML is one of the most commonly used configuration languages in modern DevOps, cloud-native, and infrastructure automation ecosystems.

GitHub Actions workflows are written using **YAML**, so you should be comfortable reading, writing, and troubleshooting YAML configurations before moving ahead.

YAML knowledge is heavily used across:

* **GitHub Actions**
* Kubernetes
* Docker Compose
* Ansible
* Helm
* Argo CD
* GitLab CI/CD
* Azure Pipelines

Resources:

* Video:
  [https://youtu.be/LT3U9fkOVDQ](https://youtu.be/LT3U9fkOVDQ)

* GitHub Notes:
  [https://github.com/CloudWithVarJosh/CKA-Certification-Course-2025/tree/main/Day%2009](https://github.com/CloudWithVarJosh/CKA-Certification-Course-2025/tree/main/Day%2009)

---

#### **3. Understanding Modern SDLC**

CI/CD tooling only makes sense when you understand the broader **Software Development Lifecycle (SDLC)** and how modern applications move from **source code to production**.

Although this lecture was recorded as part of the Jenkins series, the concepts are completely **platform agnostic** and apply equally to GitHub Actions.

Topics covered:

* Modern SDLC explained
* **Compiled vs interpreted languages**
* Build workflows for containerized applications
* Build workflows for non-containerized applications
* Why build automation matters
* Why deployment standardization matters

Resources:

* Video:
  [https://youtu.be/imEHsgvJbYo](https://youtu.be/imEHsgvJbYo)

* GitHub Notes:
  [https://github.com/CloudWithVarJosh/Jenkins-Basics-To-Production/tree/main/Day%2001](https://github.com/CloudWithVarJosh/Jenkins-Basics-To-Production/tree/main/Day%2001)

---

#### **4. Understanding CI/CD Fundamentals**

Before learning GitHub Actions, you should clearly understand the purpose behind **CI/CD systems** and the operational problems they solve.

This lecture covers the conceptual foundations behind modern software delivery practices and is again completely **platform agnostic**.

Topics covered:

* **Continuous Integration (CI)**
* **Continuous Testing (CT)**
* **Continuous Delivery (CD)**
* **Continuous Deployment (CDp)**
* **Continuous Monitoring (CM)**
* **GitFlow vs Trunk-Based Development**
* Environment promotion strategies
* Production deployment workflows

Resources:

* Video:
  [https://youtu.be/szPE1NKc614](https://youtu.be/szPE1NKc614)

* GitHub Notes:
  [https://github.com/CloudWithVarJosh/Jenkins-Basics-To-Production/tree/main/Day%2002](https://github.com/CloudWithVarJosh/Jenkins-Basics-To-Production/tree/main/Day%2002)


---

### **Understanding the Surrounding DevOps Ecosystem**

GitHub Actions is an **automation orchestrator**. Its primary role is to automate and coordinate execution of other tools used during software delivery workflows.

As we progress through the course, GitHub Actions workflows will integrate with tools such as:

* **Maven** or **Gradle** for application builds
* **SonarQube** for SAST and code quality analysis
* **Docker** for containerization
* **Kubernetes** for workload orchestration
* **Argo CD** for GitOps deployments
* **Terraform** for infrastructure provisioning
* Cloud platforms like **AWS, Azure, or GCP**

You do **not** need expert-level knowledge of these tools before starting the course. However, as we integrate them into workflows later in the series, understanding their fundamentals will significantly improve your learning experience.

Whenever deeper understanding of a tool becomes necessary, I will explicitly point it out during the course.

If you would like to learn these technologies, you can explore the curated playlists and tutorials available on the channel:

* **Git:** [Git Masterclass](https://www.youtube.com/playlist?list=PLmPit9IIdzwT6nq8hIuf7MBcPVzw3cX3K)
* **Kubernetes & CKA Prep:** [CKA Course Preparation](https://lnkd.in/g-7UEQfk)
* **Argo CD & GitOps:** [Argo CD Tutorial Series](https://youtu.be/m4lDTQwK1T8)
* **Maven:** [Maven Tutorial](https://youtu.be/3OKc5y_3wMM)
* **DevSecOps & SonarQube:** [DevSecOps and SonarQube Tutorial](https://youtu.be/qyYsLVZDieU)
* **Real-World Kubernetes Projects:** [Kubernetes Projects Playlist](https://lnkd.in/gg4tFfTD)


---

## CI/CD Tooling Landscape

Before understanding GitHub Actions, it is important to understand where it fits in the broader **CI/CD ecosystem**. GitHub Actions is not the first CI/CD platform in the industry. Organizations have been automating software delivery pipelines for years using various automation servers and CI/CD platforms.

Traditionally, organizations used tools like **Jenkins** where teams were responsible for:

* Provisioning infrastructure
* Managing build agents
* Installing and upgrading plugins
* Configuring credentials
* Designing and maintaining pipelines
* Scaling automation infrastructure

Over time, the industry started moving towards **platform-native and managed CI/CD systems** where the source control platform and automation platform became tightly integrated.

Today, the three most dominant CI/CD ecosystems are:

* **Jenkins**
  A highly customizable and extensible automation server widely adopted across enterprises.

* **GitLab CI/CD**
  A tightly integrated DevSecOps platform combining source control, CI/CD, security, and deployment tooling.

* **GitHub Actions**
  GitHub’s event-driven automation and workflow orchestration platform deeply integrated with the GitHub ecosystem.

These tools dominate the industry because they solve CI/CD from different operational philosophies:

* Infrastructure control
* Developer experience
* Ecosystem integration
* Platform standardization
* Enterprise governance

---


## What is CI/CD?

**CI/CD** refers to modern software delivery practices used to **automate, standardize, and operationalize** application delivery workflows.

Modern software delivery involves repetitive engineering operations that must execute **consistently, reliably, and at scale**.

![Alt text](/images/1a.png)

---

### Continuous Integration (CI)

**Continuous Integration (CI)** focuses on frequently integrating application code changes into a shared repository and automatically validating those changes using build and testing workflows.

Typical CI activities include:

* **Fetching source code** from repositories
* **Building applications and binaries**
* **Running automated tests**
* **Executing security and quality scans**
* **Building container images**
* **Publishing build artifacts**

The primary goal of CI is to identify integration issues, regressions, and quality problems as early as possible during software development.

---

### Continuous Delivery & Continuous Deployment (CD)

**Continuous Delivery (CD)** focuses on keeping applications in a **production-ready deployable state** by automating release preparation, validation, and deployment workflows.

Production deployments in CD may still require:

* Manual approvals
* Change management reviews
* Release authorization steps

**Continuous Deployment (CDp)** extends this further by automatically deploying validated changes directly into **production environments** without requiring manual approval steps.

Automatically deploying changes only into:

* Development
* Testing
* Staging

does **not** qualify as Continuous Deployment.

Typical CD activities include:

* **Deploying applications** across environments
* **Running integration validation workflows**
* **Managing approvals and release promotions**
* **Executing post-deployment validation**

The primary goal of CD is to deliver software changes **faster, more reliably, and with lower operational risk**.

---

Performing these operations manually introduces several operational challenges:

* **Human inconsistency** across deployments
* Slower software delivery cycles
* **Operational bottlenecks** and team dependency
* Increased deployment and configuration risks
* Poor auditability and operational visibility
* **Scaling limitations** across teams and repositories

**CI/CD tooling automates these workflows**, enabling organizations to deliver software faster, more reliably, and with significantly lower operational risk.



---

## Example: Typical CI/CD Pipeline for a Java Containerized Application

The below diagram represents a typical **production-grade CI/CD pipeline** for a modern **Java containerized application**. While tooling varies across organizations, the overall software delivery lifecycle and execution stages remain conceptually similar.

![Alt text](/images/1b.png)

**1. Fetch Source Code**

* The CI/CD platform fetches the latest **application source code, manifests, and workflow definitions** before pipeline execution begins.
* Pipeline execution is commonly triggered using **pushes, pull requests, releases, or scheduled workflows**.
* **Common tools/platforms:** Git, GitHub, GitLab, AWS CodeCommit, Bitbucket.

**2. Build the Application**

* Application source code is compiled and packaged into **deployable artifacts** such as JAR or WAR files.
* Modern Java build systems also execute **dependency resolution, lifecycle phases, and artifact packaging operations**.
* **Common tools/examples:** Maven, Gradle, `.jar`, `.war`.

> **Note:** Even interpreted languages such as **Python, JavaScript, or PHP** commonly include build stages in modern CI/CD pipelines. These stages may perform operations such as **dependency installation, transpilation, bundling, minification, packaging, static analysis, or executable artifact generation** before deployment workflows begin.


**3. Execute Automated Testing**

* Automated testing validates **application behavior** and helps identify regressions before deployment workflows begin.
* Modern CI pipelines commonly execute **unit, integration, API, and dependency validation workflows** automatically.
* **Common tools/examples:** JUnit, Mockito, TestNG, integration testing.

> **Example:** In Maven-based workflows, **JUnit** and **TestNG** commonly execute **unit tests** using the **Surefire plugin** and **integration tests** using the **Failsafe plugin** during commands such as `mvn test` or `mvn verify`. Tools like **JaCoCo** record code coverage metrics that are later consumed by platforms such as **SonarQube** during quality analysis workflows.


**4. Run Security and Quality Scans**

* Security and quality tools analyze **source code, dependencies, secrets, and configurations** for vulnerabilities or policy violations.
* Modern pipelines commonly enforce **Quality Gates** before allowing downstream workflows to continue.
* **Common tools/examples:** SonarQube, Trivy, Snyk, SAST, dependency scanning.

**5. Build the Container Image**

* Applications and runtime dependencies are packaged into **OCI-compliant container images** for standardized deployments.
* Container images are commonly tagged using **versions, commits, or release identifiers** before registry publication.
* **Common tools/examples:** Docker, Podman, OCI container images.

**6. Publish Artifacts and Container Images**

* Generated artifacts and container images are pushed to **centralized artifact repositories or container registries**.
* Modern pipelines may also publish **SBOMs, signatures, provenance metadata, and deployment artifacts** during this stage.
* **Common tools/examples:** Amazon ECR, Docker Hub, GHCR, JFrog Artifactory.

**7. Deploy the Application**

* Applications are deployed into **development, staging, testing, or production environments** using automated deployment workflows.
* In GitOps models, deployment agents continuously **monitor Git repositories and synchronize changes automatically**.
* **Common tools/examples:** Kubernetes, Helm, Argo CD, GitOps workflows.

**8. Execute Post-Deployment Validation**

* Post-deployment validation verifies **application availability, health, connectivity, and deployment correctness** after release operations complete.
* Validation workflows commonly execute **smoke tests, health checks, API validation, and observability verification** after deployments.
* **Common tools/examples:** Smoke testing, Postman, Prometheus, Grafana, k6.

**9. Continuous Monitoring**

* Continuous monitoring tracks **application health, availability, performance, logs, and operational metrics** after deployment workflows complete.
* Monitoring systems act as an operational safety layer by generating **alerts, dashboards, anomaly detection, and incident visibility** for production workloads.
* **Common tools/examples:** Prometheus, Grafana, Loki, ELK Stack, Alertmanager.


> **Key Learning:** CI/CD platforms typically do not perform build, testing, security, or deployment operations themselves. Instead, they orchestrate and automate workflows by executing the right tools at the right stages of the software delivery lifecycle.

---


## Comparing Popular CI/CD Tools

| Tool               | Operational Model                            | Major Strengths                                                                                                                                                                                    | Major Limitations                                                                                                                                                                        | Best Suited For                                                     |
| ------------------ | -------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Jenkins**        | Primarily **self-managed** automation server | • **Extremely flexible** and highly customizable workflows<br>• Massive plugin ecosystem supporting diverse integrations<br>• Strong **infrastructure-level control** and extensibility            | • Significant **operational overhead**<br>• Plugin compatibility and upgrade stability issues<br>• Requires infrastructure, agent, and security management                               | Enterprises requiring deep customization and infrastructure control |
| **GitLab CI/CD**   | Integrated **DevSecOps platform**            | • Unified SCM, CI/CD, security, and registry platform<br>• Strong DevSecOps and enterprise governance capabilities<br>• Native integration across GitLab ecosystem components                      | • Best experience primarily within GitLab ecosystem<br>• Self-hosted deployments can become operationally complex<br>• Advanced enterprise capabilities may increase platform complexity | Organizations standardizing around GitLab ecosystem                 |
| **GitHub Actions** | Managed **event-driven automation** platform | • Deep native integration with GitHub repositories and pull requests<br>• Developer-friendly YAML workflows and onboarding experience<br>• Large marketplace ecosystem with managed runner support | • Primarily optimized for GitHub-hosted source code<br>• Advanced scaling may require self-hosted runners<br>• Limited infrastructure-level customization compared to Jenkins            | Teams already using GitHub for source control                       |

---

## What is GitHub Actions?

![Alt text](/images/1c.png)

**GitHub Actions** is GitHub’s event-driven automation and workflow orchestration platform that allows developers and DevOps engineers to automate software delivery and repository workflows directly from GitHub repositories.

> GitHub Actions is called an **event-driven automation platform** because workflows can be triggered natively using **GitHub repository events** such as `push`, `pull_request`, `release`, `issue_comment`, branch creation, or tag creation.
>
> Since GitHub Actions is built directly into the **GitHub platform**, these events are available natively without requiring external webhook configuration.
>
> In traditional external CI/CD platforms like **Jenkins**, GitHub repository events are commonly integrated using **webhooks and plugins**, where GitHub sends event notifications to the external automation server.


Although GitHub Actions is commonly categorized as a **CI/CD tool**, it is more accurately an automation platform deeply integrated with the GitHub ecosystem.

GitHub Actions can automate:

* Application builds
* Testing pipelines
* Security scans
* Container workflows
* Release automation
* Deployment pipelines
* Infrastructure provisioning
* Repository management operations

GitHub Actions is primarily a **managed service**, meaning engineers mainly focus on defining automation logic while GitHub manages the underlying automation infrastructure.

In GitHub Actions, the orchestration layer, often conceptually referred to as the **control plane**, is always managed by GitHub. This includes workflow orchestration, event handling, scheduling, and execution coordination.

The execution layer, often referred to as the **data plane**, performs the actual work of executing jobs and steps through runners. These runners can either be:

* **GitHub-hosted runners** managed by GitHub
* **Self-hosted runners** managed by you

This is fundamentally different from traditional Jenkins setups where organizations are typically responsible for managing both the orchestration infrastructure and the execution infrastructure themselves.

> We will understand runners, execution architecture, and hosting models in much greater depth **later in this course**.



---

### Why GitHub Actions Became Popular

One of the primary reasons behind GitHub Actions adoption is its **deep integration with the GitHub platform** itself.

Traditional CI/CD systems like **Jenkins** often operate as external automation servers that integrate with source control systems using plugins, webhooks, PATs, SSH keys, and external authentication configurations.

GitHub Actions, however, is built directly into GitHub, significantly simplifying CI/CD adoption and reducing infrastructure management overhead for engineering teams already using GitHub.

---

#### Advantages of Platform-Native CI/CD

**Platform-native CI/CD systems** are automation platforms built directly into **source control platforms** instead of operating as completely external automation servers.

Examples include:

* **GitHub Actions** integrated into GitHub
* **GitLab CI/CD** integrated into GitLab

Because the **source control platform** and **automation platform** operate together, these systems provide several **operational**, **security**, and **developer productivity** advantages compared to many traditional external CI/CD systems.

* **No separate CI/CD server setup and management:**
  Teams can start building automation pipelines directly inside repositories without provisioning, patching, upgrading, or maintaining dedicated CI/CD infrastructure. This significantly reduces operational complexity compared to traditional self-managed CI/CD systems.

* **Native repository authentication and permissions integration:**
  GitHub Actions can access repositories, pull requests, secrets, and environments using GitHub’s built-in authentication system. For many common workflows, engineers do not need to separately configure PATs, SSH keys, repository credentials, or external access-control integrations.

* **Workflows triggered directly using repository events:**
  GitHub repository events such as `push`, `pull_request`, `release`, `issue_comment`, branch creation, and tag creation can trigger workflows natively. Since GitHub Actions is built directly into GitHub, external webhook configuration is often unnecessary for common automation workflows.

* **Unified platform for code, PRs, and automation:**
  Source code, pull requests, issues, releases, environments, secrets, and automation workflows exist within the same platform experience. This creates a smoother developer workflow by reducing constant context switching between tools.

* **Managed runners reduce CI/CD infrastructure overhead:**
  GitHub provides managed runners that allow teams to execute workflows without managing build infrastructure for many common workloads. Engineering teams can focus more on workflow engineering instead of infrastructure management.

---

#### Advantages Specific to GitHub Actions

While many **platform-native CI/CD advantages** are also available in systems like **GitLab CI/CD**, GitHub Actions became especially popular because of GitHub’s **massive ecosystem**, **developer adoption**, and strong **open-source community support**.

The following advantages are more strongly associated with **GitHub Actions** and the broader **GitHub ecosystem** specifically.

* **Massive GitHub developer ecosystem adoption:**
  GitHub is one of the largest software development platforms globally, making GitHub Actions naturally accessible to a massive engineering community already hosting repositories on GitHub. This significantly accelerated adoption across startups, enterprises, and open-source communities.

* **Large reusable GitHub Marketplace actions ecosystem:**
  GitHub Actions provides a large ecosystem of reusable automation components through GitHub Marketplace. Engineers can quickly integrate prebuilt actions for Docker workflows, Kubernetes deployments, cloud authentication, security scanning, notifications, and many other common tasks.


* **Strong open-source ecosystem and community support:**
  GitHub’s massive open-source ecosystem contributed heavily to GitHub Actions adoption. A large community continuously builds reusable actions, workflow templates, integrations, automation patterns, and best-practice implementations.


---

## Core Constructs of GitHub Actions

![Alt text](/images/1d.png)

Before writing GitHub Actions workflows, it is important to understand the three primary building blocks used inside the platform.

GitHub Actions follows a hierarchical execution model:

```text
Workflow → Jobs → Steps
```

**Runners** execute the jobs and steps defined inside workflows.

The three primary constructs are:

1. **Workflow**
   A workflow is the top-level automation definition that defines when automation should run and what operations should be executed.

2. **Jobs**
   Jobs divide a workflow into logical execution units such as build, testing, security scanning, packaging, or deployment stages.

3. **Steps**
   Steps are the individual execution tasks inside jobs such as running shell commands, checking out source code, building applications, or invoking reusable actions.

A repository can contain multiple workflows, each workflow can contain multiple jobs, and each job can contain multiple sequentially executed steps.

---

## 1. Workflow

A **workflow** is the **top-level automation definition** in GitHub Actions. It defines:

* Which GitHub events should trigger automation
* Which jobs should execute
* Job execution order and dependencies
* Permissions, conditions, and environment configuration
* Overall CI/CD or repository automation behavior

Workflows are written using **YAML syntax** and stored inside the repository under:

```text id="sqk72e"
.github/workflows/
```

Example:

```text id="cb4hzt"
.github/workflows/ci.yml
```

A repository can contain **multiple workflows** where each workflow is responsible for a different automation objective.

**Examples:**

* `ci.yml` handles application build, linting, and testing workflows.
* `deployment.yml` manages staging or production deployment automation.
* `release.yml` handles release packaging and publishing operations.
* `security-scan.yml` executes vulnerability and dependency scanning workflows.

Each workflow executes in response to one or more **GitHub events**.

Common workflow **triggers** include:

* `push` triggers workflows when commits are pushed to branches.
* `pull_request` triggers validation workflows during PR creation or updates.
* `workflow_dispatch` allows manually triggering workflows from the GitHub UI.
* `schedule` executes workflows using cron-based scheduling.
* `release` triggers workflows during GitHub release creation or publication.
* `issues` and `issue_comment` trigger repository management or automation workflows.

**Example scenarios:**

* A **pull request** can trigger automated testing and validation pipelines.
* **Pull request merges into `main`** can trigger deployment workflows.
* A **nightly scheduled workflow** can execute dependency or security scans.
* A **release event** can trigger container image publishing and deployment workflows.


Conceptually, a workflow behaves similarly to a **pipeline definition** in traditional CI/CD platforms, acting as the **top-level orchestration layer** for automation execution.



---

### 2. Jobs

A **job** is a **logical execution unit** inside a workflow. Jobs are commonly used to separate major automation stages within a CI/CD pipeline.

Typical examples include:

* Application build operations
* Unit and integration testing
* Security and compliance scanning
* Docker image packaging
* Artifact publishing
* Deployment execution

Each job executes on a **runner** and contains one or more **sequentially executed steps**.

Jobs define important execution properties such as:

* Operating system selection
* Runtime environment configuration
* Environment variables
* Permissions
* Dependencies between jobs
* Conditional execution logic

GitHub Actions supports multiple operating systems including:

* Ubuntu
* Windows
* macOS

Example:

```yaml id="k3p7xa"
runs-on: ubuntu-latest
```

By default:

* **Jobs execute in parallel**
* **Steps execute sequentially**

This behavior is extremely important for understanding **workflow execution performance**, **pipeline optimization**, and **dependency management**.

Example scenarios:

* A frontend testing job and backend testing job can execute simultaneously to reduce overall pipeline execution time.
* A deployment job may wait until all validation and testing jobs complete successfully.

GitHub Actions supports explicit **job dependency management** using the `needs` keyword.

Example:

```yaml id="5qj7ze"
deploy:
  needs: test
```

This enables creation of **multi-stage CI/CD pipelines** where:

* Build jobs execute first
* Test jobs depend on successful build completion
* Deployment jobs depend on validation and approval stages


---

## 3. Steps

A **step** is the **smallest executable unit** inside a GitHub Actions job. Steps perform the actual operational tasks required during workflow execution.

Common examples include:

* Checking out repository source code
* Installing application dependencies
* Running unit or integration tests
* Building application binaries
* Executing shell commands
* Building Docker images
* Publishing artifacts
* Deploying applications

Steps execute **sequentially within a job** and share the same runner environment during execution.

> Important workflow execution behavior:
>
> * GitHub Actions follows a **fail-fast execution model** at the job level. If a step fails, the remaining steps in that job are skipped automatically and the corresponding job is marked as **failed**.
>
> * By default, if any job in a workflow fails, the overall workflow run is also marked as **failed** unless failure handling behavior is explicitly customized.
>
> * Jobs depending on failed or skipped jobs using the `needs` keyword are skipped automatically unless conditional execution logic is defined explicitly.



GitHub Actions primarily supports two **step** types:

### A. `run`

The `run` keyword executes shell commands directly on the runner.

Example:

```yaml id="m7j2sq"
- name: Install dependencies
  run: npm install
```
`run` steps are commonly used for:

* **Shell scripting and command execution:** Execute Linux, Windows, or macOS shell commands directly on the runner. Example: `echo`, `ls`, or `pwd`.
* **Build and test operations:** Compile applications and execute validation or testing workflows. Example: `mvn package` or `npm test`.
* **Package installation:** Install application dependencies, libraries, or required tooling during workflow execution. Example: `npm install` or `pip install -r requirements.txt`.
* **Deployment commands:** Execute deployment scripts and release automation commands. Example: deploying applications using `kubectl apply` or Helm commands.
* **Infrastructure automation:** Run infrastructure provisioning or configuration management operations using tools like Terraform or Ansible. Example: `terraform apply`.



The commands execute directly inside the operating system environment of the runner using shells such as Bash, PowerShell, or CMD.

---

### B. `uses`

The `uses` keyword executes reusable GitHub Actions components called **actions**.

Example:

```yaml id="s1d9kl"
- name: Checkout source code
  uses: actions/checkout@v4
```

Reusable actions are commonly consumed from:

* GitHub Marketplace
* Public repositories
* Internal organizational repositories

We will explore reusable actions, GitHub Marketplace integrations, and advanced workflow composition in detail later in the course.

---

## Runners

![Alt text](/images/1e.png)

While workflows, jobs, and steps define the automation logic, the actual execution is performed by **runners**.

A runner is the execution environment responsible for:

* Receiving workflow jobs
* Executing workflow steps
* Streaming execution logs
* Returning execution status back to GitHub

GitHub Actions primarily supports **two runner types**:

1. **GitHub-hosted runners**
   Fully managed runners provisioned and maintained by GitHub where teams primarily select the operating system while GitHub manages infrastructure provisioning, scaling, patching, maintenance, and runner lifecycle operations.
    > **Note:** GitHub-hosted runners are primarily provisioned as **fresh ephemeral virtual machines (VMs)** managed entirely by GitHub for every workflow job execution. Depending on how workflows are configured, workflow steps can execute either **directly on the VM** or **inside containers running on top of that VM**.
    >
    > ```text
    > GitHub Hosted Runner
    >         └── Ephemeral VM
    >                 ├── Workflow steps execute directly on VM
    >                 └── OR inside containers running on that VM
    > ```



2. **Self-hosted runners**
   Organization-managed runners deployed on custom infrastructure where teams control operating systems, networking, installed software, hardware configuration, security controls, and execution environments.
    > **Note:** Self-hosted runners provide **significantly greater infrastructure and execution flexibility** and can execute on **virtual machines, physical servers, containers, Kubernetes pods, GPU systems, and other custom infrastructure environments**.


The choice between runner types typically depends on:

* Infrastructure ownership requirements
* Compliance and security requirements
* Custom software or hardware dependencies
* Private network accessibility requirements
* Operational management and cost considerations

> By default, workflow jobs execute on isolated runner environments. Jobs commonly execute on separate runners, while steps inside the same job execute within the same runner environment.

> **Production Insight:** Most mature organizations use a **hybrid runner strategy** in production. Standard CI/CD workloads commonly execute on **GitHub-hosted runners**, while security-sensitive, compliance-controlled, private-network, or highly customized workloads execute on **self-hosted runners**.
https://github.blog/enterprise-software/ci-cd/when-to-choose-github-hosted-runners-or-self-hosted-runners-with-github-actions/


---

### 1. GitHub-Hosted Runners

GitHub-hosted runners are fully managed execution environments provided and maintained by GitHub.

With GitHub-hosted runners:

* **Runner infrastructure fully managed by GitHub:**
  GitHub handles infrastructure provisioning, scaling, patching, maintenance, security updates, and runner lifecycle operations. Engineering teams primarily focus on workflow development instead of CI/CD infrastructure management.

* **Fresh ephemeral execution environments for every job:**
  Most GitHub-hosted jobs execute on fresh ephemeral virtual machines provisioned specifically for individual jobs. This improves execution isolation, reproducibility, and reduces environment drift between workflow runs.

* **No patching or maintenance responsibilities required:**
  Organizations do not manage operating system updates, runner upgrades, monitoring agents, infrastructure hardening, or runner availability operations for GitHub-hosted environments.

* **Limited customization compared to self-hosted runners:**
  Teams primarily select operating systems such as **Ubuntu, Windows, or macOS** using the `runs-on` keyword. While customization is possible during workflow execution, deep infrastructure-level customization and private network access are more limited compared to self-hosted environments.

* **Best suited for common CI/CD automation workloads:**
  GitHub-hosted runners are commonly preferred when teams want faster CI/CD onboarding, simplified infrastructure management, and reduced operational overhead for standard automation workloads.

Example:

```yaml id="gh7m2k"
runs-on: ubuntu-latest
```

Additional considerations:

* GitHub-hosted runners support Linux, Windows, and macOS environments.
* GitHub also provides larger managed runners with additional CPU, memory, GPU, autoscaling, and networking capabilities for enterprise workloads.
* Billing depends on GitHub subscription plans and workflow usage consumption.

---

### 2. Self-Hosted Runners

Self-hosted runners execute workflows on infrastructure managed by the organization itself.

These runners can execute on:

* On-premises servers
* Cloud virtual machines
* Kubernetes clusters
* Specialized hardware systems

With self-hosted runners:

* **Runner infrastructure managed by the organization itself:**
  Organizations are responsible for provisioning, scaling, patching, monitoring, securing, and maintaining runner infrastructure and execution environments.

* **Jobs may execute on persistent runner environments:**
  Unlike GitHub-hosted runners, self-hosted environments are not ephemeral by default and may retain filesystem state, installed software, caches, and configuration data across workflow executions.

* **Organizations manage patching and lifecycle operations:**
  Teams are responsible for operating system updates, runner upgrades, security hardening, monitoring agents, scaling strategies, and overall infrastructure lifecycle management.

* **Supports deep customization and private network integrations:**
  Organizations can preinstall custom software, enterprise agents, internal tooling, runtime dependencies, and provide workflows access to private infrastructure, internal VPC resources, licensed software, or specialized hardware.

* **Best suited for enterprise and isolated environments:**
  Self-hosted runners are commonly used for compliance-controlled workloads, private networking requirements, GPU-based workloads, specialized hardware systems, enterprise-restricted environments, and highly customized execution requirements.

Example:

```yaml id="s9p4tx"
runs-on: self-hosted
```

Additional considerations:

* Self-hosted runners can be configured as **ephemeral runners** for stronger isolation and cleaner execution environments.
* Organizations must carefully manage runner security because compromised workflows can impact persistent self-hosted environments.
* Billing depends on the underlying infrastructure provider being used such as AWS EC2, Azure Virtual Machines, or Google Cloud Virtual Machines.

Self-hosted runners provide significantly greater flexibility but also introduce substantially higher operational responsibility compared to GitHub-hosted runners.

---

## Putting Everything Together

By now, we have understood the four foundational building blocks of GitHub Actions:

```text id="sz1u8f"
Workflow
 └── Jobs
      └── Steps
           └── Executed by runners
```

Conceptually:

* A **workflow** defines the overall automation pipeline.
* **Jobs** divide the workflow into logical execution stages.
* **Steps** define the actual operations being executed.
* **Runners** provide the execution environment where jobs and steps run.

The following example combines all these concepts into a simple GitHub Actions workflow:

```yaml id="6j1wqb"
name: My First Workflow
on: push
jobs:
  job-1:
    runs-on: ubuntu-latest
    steps:
      - name: Step 1
        run: echo "Hello from Step 1"
      - name: Step 2
        run: echo "Hello from Step 2"
  job-2:
    runs-on: ubuntu-latest
    needs: job-1
    steps:
      - name: Final Step
        run: echo "Job 2 executed after Job 1"
```

In this workflow:

* `name` defines the workflow name displayed in the GitHub Actions UI.
* `on: push` triggers the workflow whenever code is pushed to the repository.
* `jobs` contains multiple jobs inside the workflow.
* `job-1` and `job-2` are two separate execution units.
* `runs-on` defines the runner operating system.
* `steps` contains sequentially executed operations inside a job.
* `run` executes shell commands directly on the runner.
* `needs: job-1` ensures `job-2` executes only after `job-1` completes successfully.

> **Note:** `job-1` and `job-2` execute on **separate runner environments**. By default, GitHub Actions executes jobs in **parallel**, unless explicit dependencies are defined using the *`needs`* keyword.

---

## Demo: Creating Your First Workflow

In this demo, we will create and execute our very first GitHub Actions workflow. The objective of this demo is not to build a production CI/CD pipeline yet, but to understand:

* Repository setup
* GitHub authentication
* Workflow placement
* Workflow syntax
* Jobs and steps execution
* GitHub Actions execution flow

We will intentionally keep the workflow logic simple so that the focus remains on understanding the GitHub Actions architecture and execution model.

---

## Step 1: Create a Private Repository

Since most enterprise applications use **private repositories**, we will use a private repository for this course as well.

Create a new repository with the following details:

* Repository name: `cwvj-gha-practice`
* Visibility: **Private**

Using a private repository also helps us understand GitHub Actions behavior in environments closer to real organizational workflows.

At this point, do not initialize the repository with:

* README
* `.gitignore`
* License

We will create and push everything from the local system manually.

---

## Step 2: Authenticate to GitHub Using SSH

Before pushing code to GitHub, we must authenticate our local machine with GitHub.

Although Git supports:

* HTTPS authentication
* Personal Access Tokens (PAT)
* SSH authentication

we will use **SSH authentication**, which is one of the most common approaches in enterprise environments.

Generate a new SSH key pair:

```bash
ssh-keygen -t ed25519 -C "cloudwithvarjosh@gmail.com" -f ~/.ssh/cwvj_gha_ed25519
```
---

This command generates a **public-private key pair**.

* The **private key** remains on your machine and must never be shared.
* The **public key** is added to GitHub, allowing GitHub to recognize your machine.

Let us understand the flags:

* **`-t ed25519`**
  Specifies the type of key to generate. Ed25519 is a modern, secure, and recommended algorithm.

* **`-C`**
  Adds a comment to the key. This is simply metadata used for identification and is not limited to email addresses. In practice, developers use their email so platforms like GitHub can associate the key with their account.

* **`-f`**
  Specifies the file name and location of the key. This becomes especially important when managing multiple keys.

> **Note:** The value passed with `-C` does not play any role in authentication. It is only used for identification.

---

#### Configure SSH Authentication

The SSH agent manages SSH keys loaded into memory during the current session.

```bash id="8k2xjd"
# Start the SSH agent
eval "$(ssh-agent -s)"

# Add the private key to the SSH agent
ssh-add ~/.ssh/cwvj_gha_ed25519

# Verify loaded SSH keys
ssh-add -l
```
> These commands load the generated SSH private key into the local SSH agent so Git operations can authenticate securely with GitHub without repeatedly prompting for credentials.


If successful, `ssh-add -l` displays the fingerprint of the loaded SSH key.

Now display the public key:

```bash id="v9v4y3"
cat ~/.ssh/cwvj_gha_ed25519.pub
```

Copy the displayed public key and navigate inside GitHub:

```text id="4y9kg1"
Profile Picture → Settings → SSH and GPG Keys → New SSH Key
```

Provide:

* **Title:** `cwvj-gha-practice`
* **Key:** Paste the copied public key

Once the key is added, GitHub can recognize and trust your local machine for SSH-based Git operations.

Now copy the SSH repository URL from:

```text id="3n7zqp"
Repository → Code → SSH
```

Example:

```bash id="7f8mqa"
git@github.com:CloudWithVarJosh/cwvj-gha-practice.git
```

This SSH URL will be used for authenticated Git operations.

---

## Step 3: Create the Workflow Structure

As discussed earlier, GitHub Actions workflows must be placed under:

```text id="n2w4qy"
.github/workflows/
```

Create a project directory, initialize a local Git repository, and create the workflow structure:

```bash id="8w7fjl"
# Create project directory
mkdir project-files

# Move into the project directory
cd project-files

# Initialize local Git repository
git init

# Create GitHub Actions workflow directory structure
mkdir -p .github/workflows

# Create workflow file
touch .github/workflows/my-workflow.yaml
```


Add the following workflow definition:

```yaml id="6v1xdp"
name: My First Workflow
on: push
jobs:
  job-1:
    runs-on: ubuntu-latest
    steps:
      - name: Step 1
        run: echo "Hello from Step 1"
      - name: Step 2
        run: echo "Hello from Step 2"
  job-2:
    runs-on: ubuntu-latest
    steps:
      - name: Final Step
        run: echo "Hello from Job 2"
```

This workflow demonstrates several important GitHub Actions concepts:

* `name` defines the workflow name displayed inside the GitHub Actions UI.
* `on: push` triggers the workflow whenever code is pushed to the repository.
* `jobs` defines multiple execution units inside the workflow.
* `runs-on` specifies the runner operating system used for job execution.
* `steps` contains sequentially executed operations inside each job.
* `run` executes shell commands directly on the runner.

Important execution behavior:

* `job-1` and `job-2` execute on separate **runner environments**.
* Jobs execute in **parallel by default**.
* Steps inside a job execute sequentially in the order they are defined.


---

## Step 4: Push to GitHub

Now that the workflow has been created locally, we will push the repository to GitHub.

```bash id="7f2qmd"
# Create a sample README file
touch README.md

# Add all files to the Git staging area
git add .

# Create the first commit
git commit -m "ci: add initial GitHub Actions workflow"

# Rename the default branch to main
git branch -M main

# Configure GitHub repository as remote origin
git remote add origin git@github.com:CloudWithVarJosh/cwvj-gha-practice.git

# Push code to GitHub
git push -u origin main
```

Once the push completes successfully:

* GitHub receives the workflow definition present under `.github/workflows/`
* The `push` event automatically triggers workflow execution
* GitHub Actions provisions runners and starts executing the jobs

This also confirms:

* SSH authentication is working correctly
* GitHub recognizes and trusts the local machine
* Remote repository connectivity is properly configured
* GitHub Actions workflow triggering is functioning correctly

---

## Step 5: Verify Workflow Execution on GitHub

Once the code is pushed successfully, GitHub automatically detects the workflow present under `.github/workflows/` and starts workflow execution.

Now navigate inside the repository:

```text id="8w3jfp"
Repository → Actions
```

Inside the **Actions** tab, you should see the workflow named:

```text id="4k9qsm"
My First Workflow
```

Open the workflow execution to observe:

* Workflow execution status
* Individual jobs
* Steps inside each job
* Runner operating system
* Workflow execution logs

You should observe:

* `job-1` and `job-2` executing independently
* Steps inside each job executing sequentially
* GitHub provisioning runners automatically
* Workflow logs streamed in real time

Clicking individual jobs and steps allows you to inspect:

* Shell command execution
* Step output
* Execution duration
* Workflow execution order
* Failure and debugging information

This is one of the most important aspects of GitHub Actions because the **Actions tab becomes the central visibility layer for CI/CD execution**.

---

## Bonus Step: Trigger the Workflow Again

Now let us slightly modify the workflow and observe GitHub Actions behavior again.

Add another step inside `job-2`:

```yaml id="1m7xqa"
- name: Another Step
  run: echo "Workflow executed again"
```

Updated `job-2`:

```yaml id="7d2zrl"
job-2:
  runs-on: ubuntu-latest
  steps:
    - name: Final Step
      run: echo "Hello from Job 2"
    - name: Another Step
      run: echo "Workflow executed again"
```

Now push the changes again:

```bash id="6v8jyp"
git add .
git commit -m "workflow: add another step to job-2"
git push
```

Once the push completes:

* GitHub automatically triggers the workflow again
* A new workflow execution appears under the **Actions** tab
* The newly added step becomes visible inside `job-2`

This happens because the workflow trigger is configured as:

```yaml id="2j9qwe"
on: push
```

This means **every push event** to the repository triggers workflow execution automatically.

---

## Conclusion

In this lecture, we established the **foundational concepts** required to begin working with **GitHub Actions** and modern **CI/CD systems**.

We started by understanding:
- The broader **CI/CD ecosystem**
- The operational problems CI/CD platforms solve
- How GitHub Actions fits into modern software delivery workflows

We then explored:

- **Continuous Integration, Delivery, and Deployment**
- The **GitHub Actions execution model**
- **Workflows, jobs, steps, and runners**
- **GitHub-hosted vs self-hosted runners**
- Workflow execution behavior and dependencies
- Repository event-driven automation
- Creating and executing a real GitHub Actions workflow

Most importantly, this lecture focused on building strong **architectural and conceptual understanding** instead of jumping directly into YAML syntax and pipeline implementation.

In upcoming lectures, we will move deeper into:
- Workflow syntax
- Marketplace actions
- Variables and secrets
- Artifacts and caching
- Matrix builds
- Reusable workflows
- Deployment automation
- Docker, Kubernetes, and GitOps integrations
- Production-grade CI/CD design patterns

At this stage, you should now clearly understand how **GitHub Actions workflows** are structured, triggered, executed, and orchestrated.

---

## References

- **GitHub Actions Documentation**  
  https://docs.github.com/actions

- **GitHub-Hosted Runners**  
  https://docs.github.com/actions/using-github-hosted-runners/about-github-hosted-runners

- **Self-Hosted Runners**  
  https://docs.github.com/actions/hosting-your-own-runners

- **Workflow Syntax for GitHub Actions**  
  https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions

- **Events That Trigger Workflows**  
  https://docs.github.com/actions/using-workflows/events-that-trigger-workflows

---

#### Recommended Learning Resources

- **Git Masterclass Playlist**  
  https://www.youtube.com/playlist?list=PLmPit9IIdzwT6nq8hIuf7MBcPVzw3cX3K

- **Jenkins Basics to Production**  
  https://github.com/CloudWithVarJosh/Jenkins-Basics-To-Production

- **Kubernetes & CKA Preparation**  
  https://lnkd.in/g-7UEQfk

- **Argo CD Tutorial**  
  https://youtu.be/m4lDTQwK1T8

- **Maven Tutorial**  
  https://youtu.be/3OKc5y_3wMM

- **DevSecOps & SonarQube Tutorial**  
  https://youtu.be/qyYsLVZDieU



