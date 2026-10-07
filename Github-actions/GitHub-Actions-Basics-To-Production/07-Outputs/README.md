# GitHub Actions Outputs Explained | Step, Job & Reusable Workflow Outputs

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/gkIXTCr1Iiw/maxresdefault.jpg)](https://www.youtube.com/watch?v=gkIXTCr1Iiw&ab_channel=CloudWithVarJosh)

---

## ⭐ Support the Project  

If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents

- [Introduction](#introduction)  
- [Why & What of Outputs](#why--what-of-outputs)  
  - [Why are Outputs Needed?](#why-are-outputs-needed)  
  - [What are Outputs?](#what-are-outputs)  
- [Types of Outputs](#types-of-outputs)  
  - [Type 1: Step Outputs](#type-1-step-outputs)  
  - [Type 2: Job Outputs](#type-2-job-outputs)  
  - [Type 3: Reusable Workflow Outputs](#type-3-reusable-workflow-outputs)  
- [**Demo 1:** Sharing Deployment Information Using Step Outputs](#demo-1-sharing-deployment-information-using-step-outputs)  
  - [Step 1: Create the Workflow](#step-1-create-the-workflow)  
  - [Step 2: Commit and Push the Changes](#step-2-commit-and-push-the-changes)  
  - [Step 3: Execute the Workflow](#step-3-execute-the-workflow)  
  - [Step 4: Observe the Workflow Output](#step-4-observe-the-workflow-output)  
- [**Demo 2:** Sharing Deployment Information Using Job Outputs](#demo-2-sharing-deployment-information-using-job-outputs)  
  - [Step 1: Create the Workflow](#step-1-create-the-workflow-1)  
  - [Step 2: Commit and Push the Changes](#step-2-commit-and-push-the-changes-1)  
  - [Step 3: Execute the Workflow](#step-3-execute-the-workflow-1)  
  - [Step 4: Observe the Workflow Output](#step-4-observe-the-workflow-output-1)  
- [**Demo 3:** Returning Deployment Information Using Reusable Workflow Outputs](#demo-3-returning-deployment-information-using-reusable-workflow-outputs)  
  - [Step 1: Create the Reusable Workflow](#step-1-create-the-reusable-workflow)  
  - [Step 2: Create the Calling Workflow](#step-2-create-the-calling-workflow)  
  - [Step 3: Commit and Push the Changes](#step-3-commit-and-push-the-changes-2)  
  - [Step 4: Execute the Workflow](#step-4-execute-the-workflow-2)  
  - [Step 5: Observe the Workflow Output](#step-5-observe-the-workflow-output)  
- [Conclusion](#conclusion)  
- [References](#references)  

---

## Introduction

As GitHub Actions workflows grow in complexity, different parts of a workflow often need to exchange information with one another.

A deployment step may generate a deployment URL that subsequent steps need to display. A build job may generate a release version that downstream jobs need to deploy. A reusable workflow may produce deployment metadata that the calling workflow needs to consume after execution completes.

Without a structured mechanism for sharing this information, workflows would need to repeatedly generate the same values, hardcode information, or rely on custom workarounds that are difficult to maintain.

GitHub Actions solves this problem through **Outputs**.

Outputs provide a standardized mechanism for exposing runtime-generated information and making it available to other execution units within GitHub Actions. Depending on the required scope, outputs can be shared between:

* **Steps within the same job**
* **Jobs within the same workflow**
* **Reusable Workflows and Calling Workflows**

In this lecture, we will explore all three output types:

* **Step Outputs** – Used to share information between steps.
* **Job Outputs** – Used to share information between jobs.
* **Reusable Workflow Outputs** – Used to share information between workflows.

Throughout the lecture, we will use practical deployment-based examples to demonstrate how information flows across different execution boundaries and how Outputs enable workflows to remain modular, reusable, and maintainable.

By the end of this lecture, you will understand not only how to create Outputs, but also how to choose the appropriate Output type based on the scope at which information needs to be consumed.

---

## Why & What of Outputs

### Why are Outputs Needed?

As workflows become more sophisticated, it is common for one **job** to generate information that another **job** needs to consume.

For example:

* A deployment job may generate a **deployment URL** that a notification job needs to send to users.
* A testing job may generate a **test result** that a reporting job needs to publish.
* A security scanning job may generate a **scan result** that a deployment job needs to evaluate.
* A reusable workflow may generate a **release version** that the calling workflow needs to consume.

Without a mechanism for sharing this information, workflows would need to repeatedly generate the same values, hardcode them, or rely on custom workarounds.

Consider the following workflow consisting of **multiple jobs**:

```text
Deploy Application Job
         ↓
Creates Deployment URL

Send Notification Job
         ↓
Needs Deployment URL
```

During deployment, the workflow may generate a URL such as:

```text
https://cwvj-demo.com
```

The **Deploy Application Job** creates this value, while the **Send Notification Job** needs the exact same value to inform users where the application has been deployed.

The question is:

**How can one job share information with another job?**

GitHub Actions solves this problem through **Outputs**.

---

### What are Outputs?

Outputs are values generated during workflow execution and made available to other **steps**, **jobs**, or even **reusable workflows**.

Think of outputs as a mechanism for passing information from one execution unit to another. Instead of hardcoding values or generating the same information repeatedly, a workflow can generate a value once and expose it as an output for downstream consumers.

Common examples include:

```text id="z3bgcv"
Build Number
Application Version
Commit SHA
Deployment URL
Security Scan Result
Release Version
```

In the previous example, the deployment job can generate:

```text id="g8s5a0"
https://cwvj-demo.com
```

and expose it as an **output**, allowing downstream jobs to consume the exact same value.

This improves **consistency**, **maintainability**, **reusability**, and **traceability** because every job operates on the exact same information.

> **Terraform Analogy:** If you have worked with Terraform, this concept may feel familiar. Terraform **Outputs** are commonly used to expose values such as **Public IP Addresses**, **DNS Names**, **Load Balancer Endpoints**, or **Resource IDs** after infrastructure creation.
>
> GitHub Actions Outputs follow a similar principle, but their primary purpose is to share values between **steps**, **jobs**, and **workflows** during workflow execution.
>
> Unlike **Terraform Outputs**, which are frequently consumed directly by **users** and **automation tools**, **GitHub Actions Outputs** are primarily intended for **workflow orchestration**. However, the values contained within Outputs can still be surfaced to **humans** or **external systems**. For example, an Output may be **displayed in workflow logs**, **included in deployment notifications**, **sent to external APIs**, **published to dashboards**, or **consumed by custom automation** built around GitHub Actions.
>
> In practice, Outputs often represent runtime-generated information such as **deployment URLs**, **release versions**, **image tags**, **security scan results**, or **infrastructure metadata** that needs to be shared both within the workflow and, in some cases, with downstream operational processes.

> **Important:** Outputs are designed for sharing **values and metadata** such as **deployment URLs**, **build numbers**, **versions**, **image tags**, **resource identifiers**, and **deployment results**. They are not intended for sharing files between jobs.
>
> When you need to transfer files across jobs, GitHub Actions provides **Artifacts**, which we will cover in the next lecture.
>
> Artifacts typically represent files or deliverables generated during the software delivery lifecycle, including **application binaries**, **container images**, **deployment manifests**, **test reports**, **security scan reports**, **coverage reports**, **log files**, **Helm charts**, and other build or deployment outputs that need to be preserved or consumed by downstream processes.
>
> A useful way to think about it is:
>
> ```text
> Outputs   → Values and Metadata
> Artifacts → Files and Deliverables
> ```


> **Key Observation:** Inputs and Outputs are closely related concepts. **Inputs bring data into a workflow**, while **Outputs expose data generated by a workflow**. Together, they form the primary mechanism for exchanging information across different execution stages of a GitHub Actions workflow.

---

### Types of Outputs

GitHub Actions supports three primary types of outputs:

**1. Step Outputs**

* Used to share values between steps within the same job.

* **Example:** Sharing a deployment URL, generated version, build metadata, or API response from one step to another step in the same job.

**2. Job Outputs**

* Used to share values from one job to another job.

* **Example:** Sharing a deployment URL, release version, security scan result, or image tag generated by a build job with downstream jobs such as deployment, testing, or notification jobs.

**3. Reusable Workflow Outputs**

* Used to return values from a reusable workflow back to the calling workflow.

* **Example:** Returning deployment metadata such as deployment URL, release version, environment details, or validation results from a centralized deployment workflow to the calling workflow.

The examples used throughout this lecture focus on a **deployment URL** because it is easy to visualize and understand. However, Outputs are not limited to deployment URLs. In production environments, teams commonly use Outputs to share many different types of runtime-generated information between steps, jobs, and reusable workflows.

Some common examples include:

* **Release Version**

  * Generated during build processes and shared with packaging, publishing, or deployment jobs.
  * Ensures all downstream stages operate on the exact same application version.

* **Container Image Tag**

  * Generated during container image build stages and consumed by image publishing, deployment, or rollback workflows.
  * Ensures all environments deploy the exact same container image that was previously validated and tested.

* **Commit SHA**

  * Shared across testing, security scanning, packaging, and deployment jobs.
  * Provides **traceability** by ensuring all stages execute against the same source code revision.

* **Security Scan Results**

  * Generated by security or compliance validation jobs and consumed by approval, reporting, notification, or deployment jobs.
  * Commonly used to prevent deployments when vulnerabilities, policy violations, or compliance issues are detected.

* **Artifact Name or Artifact Location**

  * Generated during build processes and shared with downstream jobs responsible for downloading, validating, publishing, or deploying artifacts.
  * Ensures downstream jobs consume the correct build output.

* **Cloud Resource Information**

  * Examples include **Load Balancer DNS names**, **Kubernetes Ingress URLs**, **API Gateway endpoints**, or **infrastructure identifiers** generated during provisioning workflows.
  * Allows deployment, testing, monitoring, and notification jobs to consume dynamically created infrastructure details.

* **API-Generated Metadata**

  * Examples include **change request IDs**, **ticket numbers**, **deployment IDs**, **approval references**, or **release identifiers** returned by external systems.
  * Commonly used for **auditability**, **change management**, **governance**, and integration with enterprise operational processes.

The actual value being shared is often less important than the **scope at which it needs to be consumed**. The same information can be shared using a **Step Output**, **Job Output**, or **Reusable Workflow Output** depending on how the workflow has been designed and where the downstream consumers exist.


We will now discuss each of these **Output Types** in detail.

> **Key Observation:** The primary difference between the three output types is **scope**.
>
> * **Step Outputs** share information between steps within the same job.
> * **Job Outputs** share information between jobs.
> * **Reusable Workflow Outputs** share information between a reusable workflow and the calling workflow.
>
> The underlying concept remains the same: **one execution unit creates a value, another execution unit consumes that value.**

> **Architectural Note:** The type of output you use depends entirely on your workflow design and how far the generated information needs to travel. The same value can be shared using different output types depending on the scope of consumption. For example, a deployment step may generate a **deployment URL** and share it with subsequent steps using a **Step Output**. In another workflow, a deployment job may generate the same deployment URL and expose it as a **Job Output** for downstream jobs. Similarly, a centralized deployment workflow may generate the same deployment URL and return it as a **Reusable Workflow Output** to the calling workflow.
>
> The value being shared is often irrelevant when selecting an output type. What matters is **where the value is generated** and **who needs to consume it**.
>
> ```text
> Same Deployment URL
>          ↓
> Step → Step              → Step Output
> Job → Job                → Job Output
> Workflow → Workflow      → Reusable Workflow Output
> ```
>
> > **Key Observation:** Outputs are primarily a mechanism for controlling information flow across different execution scopes. When designing workflows, think less about the value itself and more about the execution boundary that the value must cross.


---

### Type 1: Step Outputs

Step Outputs allow one **step** to share information with another **step** within the **same job**.

Consider the following scenario:

```text
Generate Release Version Step
          ↓
Creates Version

Build Docker Image Step
          ↓
Needs Version
```

The **first step** may generate:

```text
v1.0.1
```

The **second step** then needs the exact same value while building, tagging, or publishing the application.

Step Outputs provide a simple mechanism for passing such values between steps without hardcoding them or generating them multiple times.

Example:

```yaml
jobs:
  release-job:
    steps:
      - name: Generate Release Version
        id: version
        run: |
          echo "release_version=v1.0.1" >> $GITHUB_OUTPUT

      - name: Display Release Version
        run: |
          echo "${{ steps.version.outputs.release_version }}"
```

#### Explanation

```yaml
jobs:
  release-job:
    steps:
      - name: Generate Release Version
        id: version
        run: |
          echo "release_version=v1.0.1" >> $GITHUB_OUTPUT
```

* This step executes within the **`release-job`** job. Because Step Outputs are scoped to a job, they can be consumed by subsequent steps within the same job.

* The step is assigned the identifier **`version`** using:

  ```yaml
  id: version
  ```

* The **`id`** uniquely identifies the step within the current job.

* When a step generates outputs, GitHub Actions associates those outputs with the step identifier.

* Downstream steps use this identifier to reference the generated outputs through the **`steps`** context.

* Without a step identifier, other steps would have no mechanism to reference the outputs generated by this step.

  > **Important:** Any step that generates outputs should typically have an **`id`** because downstream consumers use the identifier to access the generated values. This becomes particularly important when **multiple steps within the same job generate outputs**, as the step identifier allows GitHub Actions to determine exactly **which step's outputs** are being referenced.

* The **`run`** block executes the following command:

  ```bash
  echo "release_version=v1.0.1" >> $GITHUB_OUTPUT
  ```

* This command generates a value named **`release_version`** with a value of **`v1.0.1`** and writes it to **`$GITHUB_OUTPUT`**.

* The special file **`$GITHUB_OUTPUT`** is provided by GitHub Actions and is used to expose output values from a step. Any outputs written to this file are stored by GitHub Actions and can later be consumed by subsequent steps using the **`steps.<step-id>.outputs.<output-name>`** syntax.

* Any value written to this file using the format **`key=value`** becomes available as a Step Output.

  > **`$GITHUB_ENV`** and **`$GITHUB_OUTPUT`** store data as named entries (keys). Most commonly these are simple **`key=value`** pairs, but GitHub Actions also supports multiline values using the **`<<EOF`** syntax.

* In this example, the step exposes:

  * Output Name → `release_version`
  * Output Value → `v1.0.1`

The expression:

```bash
echo "release_version=v1.0.1" >> $GITHUB_OUTPUT
```

can be broken down as:

* **`release_version`** refers to the output name.
* **`v1.0.1`** refers to the output value.
* **`$GITHUB_OUTPUT`** is the special file used by GitHub Actions to capture Step Outputs.

Flow:

```text
Generate Release Version Step
           ↓
Creates Version
           ↓
Step Output
```

> **Important:** Writing a value to **`$GITHUB_OUTPUT`** does not automatically make it available to all jobs in the workflow. The value is initially associated only with the step that generated it. Since steps within a job execute sequentially, only **subsequent steps** can consume that output using the `steps.<step-id>.outputs.<output-name>` syntax. A step cannot consume outputs from a step that has not yet executed.


> **Connection to Previous Lectures:** The special file **`$GITHUB_OUTPUT`** is conceptually similar to **`$GITHUB_ENV`**, which we used in earlier lectures. Both files are provided by GitHub Actions and are used to persist information during workflow execution.
>
> * **`$GITHUB_ENV`** is used to create **environment variables** that can be consumed by subsequent steps within the same job.
> * **`$GITHUB_OUTPUT`** is used to create **outputs** that can be consumed through GitHub Actions output expressions.
>
> For example:
>
> ```bash
> echo "APPLICATION_VERSION=v1.0.1" >> $GITHUB_ENV
> ```
>
> creates an environment variable, whereas:
>
> ```bash
> echo "release_version=v1.0.1" >> $GITHUB_OUTPUT
> ```
>
> creates a Step Output.
>
> While the syntax is very similar, the purpose is different. **`$GITHUB_ENV`** is used for environment variables, whereas **`$GITHUB_OUTPUT`** is used for passing values through the GitHub Actions output mechanism.

---

```yaml
- name: Display Release Version
  run: |
    echo "${{ steps.version.outputs.release_version }}"
```

* This step consumes the **Step Output** generated by the previous step.
* Because both steps execute within the same **`release-job`** job, the second step can access outputs exposed by earlier steps through the **`steps`** context.
* The **`echo`** command simply prints the resolved output value to the workflow logs. In real-world workflows, the output could also be used to make deployment decisions, construct file names, build image tags, call APIs, or drive other automation tasks.

The expression:

```yaml
${{ steps.version.outputs.release_version }}
```

can be broken down as:

* **`steps`** refers to all previously executed steps within the current job.
* **`version`** refers to the step identifier assigned using **`id: version`**.
* **`outputs`** refers to values exposed by that step through **`$GITHUB_OUTPUT`**.
* **`release_version`** refers to the specific output name generated by the step.

GitHub Actions evaluates the expression by:

```text
Locating the Step
       ↓
Finding its Outputs
       ↓
Retrieving release_version
       ↓
Substituting the Actual Value
```

During execution, GitHub Actions resolves:

```yaml
${{ steps.version.outputs.release_version }}
```

to:

```text
v1.0.1
```

and the workflow ultimately executes:

```bash
echo "v1.0.1"
```

which prints the value to the workflow logs.

> **Key Observation:** Step Outputs are only available to **subsequent steps within the same job**. They are not automatically available to other jobs. If information needs to cross **job boundaries**, it must be exposed using a **Job Output**, which we will discuss next.


Flow:

```text
Generate Release Version Step
           ↓
Creates Version
           ↓
Step Output
           ↓
Display Release Version Step
           ↓
Consumes Version
```

> **Production Insight:** Step Outputs are commonly used to share generated versions, build metadata, commit information, API responses, dynamically calculated values, and release details between steps within the same job.

---

**Common use cases include:** sharing **release versions**, **build metadata**, **commit identifiers**, **API responses**, **security scan results**, **dynamic resource identifiers**, and other runtime-generated values between steps within the same job.


> **Important:** Step Outputs can only be consumed by other steps within the same job. If information needs to be shared across multiple jobs, GitHub Actions provides **Job Outputs**, which we will discuss next.


---

### Type 2: Job Outputs

Job Outputs allow one **job** to share information with another **job**.

Consider the following scenario:

```text
Deploy Application Job
         ↓
Creates Deployment URL

Send Notification Job
         ↓
Needs Deployment URL
```

The deployment job may generate:

```text
https://cwvj-demo.com
```

The notification job then needs the exact same value to inform users where the application has been deployed.

Job Outputs provide a mechanism for sharing such values across job boundaries.

This is particularly important because jobs execute on **independent runners** and do not automatically share runtime-generated information with one another.

Example:

```yaml
jobs:
  deploy-job:
    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

    outputs:
      deployment_url: ${{ steps.deploy.outputs.deployment_url }}

  notify-job:
    needs:
      - deploy-job
    steps:
      - name: Send Notification
        run: |
          echo "${{ needs.deploy-job.outputs.deployment_url }}"
```

#### Explanation

```yaml
deploy-job:
  steps:
    - name: Deploy Application
      id: deploy
      run: |
        echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

  outputs:
    deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* This block defines the **`deploy-job`** job.

* The job contains a step named **Deploy Application**, which is responsible for generating a deployment URL.

* The step is assigned the identifier **`deploy`** using:

  ```yaml
  id: deploy
  ```

* The **`id`** uniquely identifies the step within the current job and allows its outputs to be referenced later.

* Without a step identifier, GitHub Actions would have no mechanism to determine which step's outputs should be exposed or consumed.

The step executes:

```bash
echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

* This command generates a value named **`deployment_url`** and stores it as a **Step Output**.
* The special file **`$GITHUB_OUTPUT`** is provided by GitHub Actions and is used to expose output values from a step.
* Any value written to **`$GITHUB_OUTPUT`** using the format **`key=value`** becomes available as a Step Output.

In this example, the step exposes:

* Output Name → `deployment_url`
* Output Value → `https://cwvj-demo.com`

By default, Step Outputs are only accessible to other steps within the same job.

To make the value available outside the job, GitHub Actions requires it to be explicitly exposed as a **Job Output** using:

```yaml
outputs:
  deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* The **`outputs`** block performs this mapping by assigning the Step Output generated by the **`deploy`** step to a Job Output named **`deployment_url`**.
* Once exposed, downstream jobs can consume the value through the **`needs`** context.

The expression:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

can be broken down as:

* **`steps`** refers to previously executed steps within the current job.
* **`deploy`** refers to the step identifier.
* **`outputs`** refers to values exposed by that step.
* **`deployment_url`** refers to the specific output name.

GitHub Actions resolves:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

and assigns the resulting value to the Job Output:

```yaml
outputs:
  deployment_url: ...
```

> **Important:** Notice that **Step Outputs** do not require an **`outputs`** block because they are automatically available to **subsequent steps within the same job** through the **`steps`** context. However, when information needs to cross a **job boundary**, GitHub Actions requires the value to be explicitly exposed using a **Job Output**.
>
> Think of a **Job Output** as a **Step Output that has been intentionally exported** so that downstream jobs can consume it through the **`needs`** context.
>
> In this example, the **Step Output** name (**`deployment_url`**) and the **Job Output** name (**`deployment_url`**) are intentionally kept the same for simplicity and readability. However, this is not a requirement.
>
> The job's **`outputs`** block acts as a **mapping layer** between **Step Outputs** and **Job Outputs**. This allows a Job Output to reference any Step Output generated within the job and expose it using a different name if desired.
>
> For example, the following mapping is also valid:
>
> ```yaml
> outputs:
>   application_endpoint: ${{ steps.deploy.outputs.deployment_url }}
> ```
>
> Here:
>
> ```text
> deployment_url      → Step Output Name
> application_endpoint → Job Output Name
> ```
>
> Although the names are different, both refer to the same underlying value. Downstream jobs would then consume the output using:
>
> ```yaml
> ${{ needs.deploy-job.outputs.application_endpoint }}
> ```
>
> This flexibility allows workflow authors to expose outputs using names that are more meaningful to downstream consumers without changing the names of the underlying Step Outputs.

Flow:

```text
Deploy Step
      ↓
Creates Deployment URL
      ↓
Step Output
      ↓
Mapped to Job Output
      ↓
Available to Downstream Jobs
```

> **Key Observation:** A **Job Output** does not generate any value itself. Instead, it exposes information that was already generated by one or more **steps within the same job**. Think of a Job Output as a **Step Output that has been intentionally exported** so that downstream jobs can consume it.
>
> As discussed in **Type 1**, Step Outputs allow information sharing between **steps within the same job**. Job Outputs build upon this concept by allowing selected Step Outputs to cross **job boundaries** and become available to downstream jobs through the **`needs.<job-id>.outputs.<output-name>`** syntax.
>
> In other words, **Step Outputs enable communication within a job**, whereas **Job Outputs enable communication between jobs**.

---

```yaml
notify-job:
  needs:
    - deploy-job
  steps:
    - name: Send Notification
      run: |
        echo "${{ needs.deploy-job.outputs.deployment_url }}"
```

* This block defines the **Send Notification Job**.
* The **`needs`** keyword creates a dependency on **`deploy-job`**, ensuring that the deployment job completes before the notification job starts.
* Because the notification job depends on the deployment job, it can access any Job Outputs exposed by that job.

The expression:

```yaml
${{ needs.deploy-job.outputs.deployment_url }}
```

can be broken down as:

* **`needs`** provides access to information exposed by dependent jobs.
* **`deploy-job`** refers to the upstream job.
* **`outputs`** refers to Job Outputs exposed by that job.
* **`deployment_url`** refers to the specific output name.

During execution, GitHub Actions resolves the expression to:

```text
https://cwvj-demo.com
```

and makes the value available inside the notification job.

Flow:

```text
Deploy Application Job
         ↓
Creates Deployment URL
         ↓
Exposes Job Output
         ↓
Send Notification Job
         ↓
Consumes Deployment URL
```

> **Connection to Previous Lectures:** As we learned earlier, the **`needs`** keyword controls execution order and creates job dependencies. Job Outputs are commonly consumed through these dependencies.


---

> **Common use cases include:** sharing **deployment URLs**, **release versions**, **security scan results**, **build metadata**, **generated resource identifiers**, **API-generated values**, and **environment-specific deployment information** between jobs within the same workflow.


> **Important:** Job Outputs are designed for sharing values across jobs. They are not intended for transferring files, reports, binaries, logs, or other artifacts. For those use cases, GitHub Actions provides **Artifacts**, which we will cover in the next lecture.

> **Production Insight:** Job Outputs are commonly used whenever one job generates information that downstream jobs need to consume. Typical examples include deployment URLs, release versions, security scan results, infrastructure identifiers, approval metadata, and deployment status information.

---

### Type 3: Reusable Workflow Outputs

Reusable Workflow Outputs allow a **Reusable Workflow** to return information back to the **Calling Workflow** that invoked it.

As discussed in previous lectures, **Reusable Workflows** are commonly used to centralize shared automation logic such as **application deployments**, **security validations**, **compliance checks**, **platform engineering operations**, and **infrastructure provisioning**.

However, a common challenge arises when the Reusable Workflow generates information that the Calling Workflow needs to consume after execution completes.

Consider the following scenario:

```text
Calling Workflow
         ↓
Invokes Reusable Deployment Workflow

Reusable Workflow
         ↓
Deploys Application
         ↓
Creates Deployment URL

Calling Workflow
         ↓
Needs Deployment URL
```

During deployment, the Reusable Workflow may generate:

```text
https://cwvj-demo.com
```

The Calling Workflow may then need this value for additional activities such as:

* Sending deployment notifications.
* Creating change management records.
* Updating monitoring systems.
* Configuring synthetic health checks.
* Recording deployment metadata for auditing purposes.

The question becomes:

**How can a Reusable Workflow return information back to the Calling Workflow?**

GitHub Actions solves this problem through **Reusable Workflow Outputs**.

Reusable Workflow Outputs allow values generated inside a Reusable Workflow to be exposed and returned to the Calling Workflow after execution completes successfully.

Example:

**Reusable Workflow:**

```yaml
on:
  workflow_call:
    outputs:
      deployment_url:
        value: ${{ jobs.deploy-job.outputs.deployment_url }}

jobs:
  deploy-job:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

    outputs:
      deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

**Calling Workflow:**

```yaml
jobs:
  deploy-job:
    uses: ./.github/workflows/deploy.yml

  notify-job:
    needs:
      - deploy-job
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "${{ needs.deploy-job.outputs.deployment_url }}"
```

#### Explanation

```yaml
jobs:
  deploy-job:
    runs-on: ubuntu-latest

    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

    outputs:
      deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* This block defines the **`deploy-job`** job.

* The job contains a step named **Deploy Application**, which is responsible for generating a deployment URL.

* The step is assigned the identifier **`deploy`** using:

  ```yaml
  id: deploy
  ```

* The **`id`** uniquely identifies the step within the current job and allows its outputs to be referenced later.

* Without a step identifier, GitHub Actions would have no mechanism to determine which step's outputs should be exposed or consumed.

The step executes:

```bash
echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

* As discussed in **Type 1**, this command generates a value named **`deployment_url`** and stores it as a **Step Output**.

* The special file **`$GITHUB_OUTPUT`** is provided by GitHub Actions and is used to expose output values from a step.

* Any value written to **`$GITHUB_OUTPUT`** using the format **`key=value`** becomes available as a Step Output.

In this example, the step exposes:

* Output Name → **`deployment_url`**
* Output Value → **`https://cwvj-demo.com`**

By default, Step Outputs are only accessible to other steps within the same job.

To make the value available outside the step, GitHub Actions requires it to be explicitly exposed as a **Job Output** using:

```yaml
outputs:
  deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* This block defines a **Job Output** for **`deploy-job`**.

* The **`outputs`** block performs this mapping by assigning the Step Output generated by the **`deploy`** step to a Job Output named **`deployment_url`**.

* As discussed in **Type 2**, this allows the value to cross the **step boundary** and become available at the **job level**.

The expression:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

can be broken down as:

* **`steps`** refers to previously executed steps within the current job.
* **`deploy`** refers to the step identifier.
* **`outputs`** refers to values exposed by that step.
* **`deployment_url`** refers to the specific output name.

GitHub Actions resolves:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

and assigns the resulting value to the Job Output:

```yaml
outputs:
  deployment_url: ...
```

At this point, the deployment URL is available as a **Job Output**.

However, the value is still confined to the Reusable Workflow itself.

To make it available to the Calling Workflow, GitHub Actions requires the Job Output to be explicitly exposed as a **Reusable Workflow Output**.

---

```yaml
on:
  workflow_call:
    outputs:
      deployment_url:
        value: ${{ jobs.deploy-job.outputs.deployment_url }}
```

* This block defines a **Reusable Workflow Output**.

* The output is declared within the **`workflow_call`** section because it represents information that the Reusable Workflow will return to the Calling Workflow.

* The Reusable Workflow exposes an output named **`deployment_url`**.

* The output value originates from the **Job Output** generated by **`deploy-job`**.

* Once exposed, GitHub Actions automatically makes the value available to the Calling Workflow after the Reusable Workflow completes successfully.

The expression:

```yaml
${{ jobs.deploy-job.outputs.deployment_url }}
```

can be broken down as:

* **`jobs`** refers to jobs defined within the Reusable Workflow.
* **`deploy-job`** refers to the job that generated the output.
* **`outputs`** refers to outputs exposed by that job.
* **`deployment_url`** refers to the specific Job Output being returned.

In this example, GitHub Actions resolves:

```yaml
${{ jobs.deploy-job.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

and exposes the resulting value as a **Reusable Workflow Output** named **`deployment_url`**.

> **Important:** Reusable Workflow Outputs do not generate values themselves. They simply expose **Job Outputs** from within the Reusable Workflow so that the Calling Workflow can consume them.
>
> Notice that the deployment URL is generated only once inside the deployment step. Each subsequent output layer simply exposes the same value to a broader scope.
>
> ```text
> Step Output
>       ↓
> Job Output
>       ↓
> Reusable Workflow Output
> ```
>
> Each output type builds upon the previous one and allows information to cross a larger execution boundary.

> **Connection to Type 2:** Just as **Job Outputs** allow information to cross **job boundaries**, **Reusable Workflow Outputs** allow information to cross **workflow boundaries**.

---

Consider the following Calling Workflow:

```yaml
jobs:
  deploy-job:
    uses: ./.github/workflows/deploy.yml

  notify-job:
    needs:
      - deploy-job

    runs-on: ubuntu-latest

    steps:
      - run: |
          echo "${{ needs.deploy-job.outputs.deployment_url }}"
```

* This workflow contains a job named **`deploy-job`** that invokes the Reusable Workflow.

* The **`uses`** keyword instructs GitHub Actions to execute the Reusable Workflow.

* When the Reusable Workflow completes, GitHub Actions automatically exposes any Reusable Workflow Outputs through the job that invoked it.

* In this example, the Reusable Workflow returns an output named **`deployment_url`**, which becomes available through the **`deploy-job`** job.

The notification job then consumes the value using:

```yaml
${{ needs.deploy-job.outputs.deployment_url }}
```

* This expression is evaluated within the **`notify-job`** job.

* The **`needs`** keyword creates a dependency on the **`deploy-job`** job, ensuring that the deployment completes before the notification job starts.

* Because the notification job depends on **`deploy-job`**, it can access any outputs exposed by that job.

The expression can be broken down as:

* **`needs`** provides access to information exposed by dependent jobs.
* **`deploy-job`** refers to the job that invoked the Reusable Workflow.
* **`outputs`** refers to outputs returned by that workflow execution.
* **`deployment_url`** refers to the specific output name being consumed.

During execution, GitHub Actions resolves:

```yaml
${{ needs.deploy-job.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

allowing the Calling Workflow to consume the exact value generated inside the Reusable Workflow.

> **Key Observation:** A **Reusable Workflow Output** does not generate any value itself. Instead, it exposes information already generated inside the Reusable Workflow and makes it available to the Calling Workflow.
>
> As discussed in **Type 1** and **Type 2**, Outputs are fundamentally a mechanism for sharing information across execution boundaries.
>
> * **Step Outputs** enable communication between steps.
> * **Job Outputs** enable communication between jobs.
> * **Reusable Workflow Outputs** enable communication between workflows.
>
> In other words:
>
> ```text
> Step Output
>       ↓
> Job Output
>       ↓
> Reusable Workflow Output
> ```
>
> Each layer expands the visibility of information generated during workflow execution.

> **Connection to Previous Lectures:** In the Inputs lecture, we learned how a Calling Workflow can pass values into a Reusable Workflow using **Reusable Workflow Inputs**. Reusable Workflow Outputs provide the reverse capability, allowing Reusable Workflows to return values back to the Calling Workflow.

---

**Common use cases include:** returning **deployment URLs**, **release versions**, **security validation results**, **compliance check results**, **generated resource identifiers**, **environment-specific deployment information**, and other platform-generated metadata from Reusable Workflows back to Calling Workflows.

> **Important:** Reusable Workflow Outputs are designed for sharing values and metadata between workflows. They are not intended for transferring files, reports, binaries, logs, or other artifacts. For those use cases, GitHub Actions provides **Artifacts**, which we will cover in the next lecture.

> **Production Insight:** Reusable Workflow Outputs are commonly used in organizations that centralize deployment, compliance, security scanning, infrastructure provisioning, and platform engineering workflows. They allow platform teams to encapsulate complex logic inside Reusable Workflows while still returning critical information back to application teams.

---

> **Mental Model:** Inputs and Outputs are closely related concepts and are often used together within the same workflow.
>
> ```text
> Input
>   ↓
> environment = prod
>
> Workflow Executes
>
> Output
>   ↓
> deployment_url = https://cwvj-demo.com
> ```
>
> Think of:
>
> ```text
> Inputs  → Data entering the workflow
> Outputs → Data leaving the workflow
> ```
>
> This is not a strict technical definition, but it is a useful way to visualize workflow data flow. Throughout GitHub Actions, **Inputs** are commonly used to provide information to workflows, jobs, actions, and Reusable Workflows, while **Outputs** are used to expose information generated during execution back to downstream consumers.

---

## Demo 1: Sharing Deployment Information Using Step Outputs

In this demo, we will learn how **Step Outputs** allow one step to share information with subsequent steps within the same job.

We will simulate a simple deployment workflow where:

```text
Deploy Application Step
         ↓
Creates Deployment URL

Display Deployment Details Step
         ↓
Needs Deployment URL

Send Deployment Notification Step
         ↓
Needs Deployment URL
```

The deployment step will generate a deployment URL and expose it as a **Step Output**. Subsequent steps will consume the same value without hardcoding it or generating it again.

By the end of this demo, you will understand how to:

* Create Step Outputs using **`$GITHUB_OUTPUT`**
* Assign identifiers using **`id`**
* Access outputs using **`steps.<step-id>.outputs.<output-name>`**
* Share information between steps within the same job

---

### Step 1: Create the Workflow

Create the following workflow:

**`.github/workflows/01-step-outputs-demo.yaml`**

```yaml
name: 01 - Step Outputs Demo

on:
  workflow_dispatch:

jobs:
  deployment-job:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "Deploying application..."
          sleep 3
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

      - name: Display Deployment Details
        run: |
          echo "Application deployed successfully."
          echo "Deployment URL:"
          echo "${{ steps.deploy.outputs.deployment_url }}"

      - name: Send Deployment Notification
        run: |
          echo "Sending notification..."
          echo "Application URL: ${{ steps.deploy.outputs.deployment_url }}"
          echo "Notification sent successfully."
```

---

#### Explanation

```yaml
name: 01 - Step Outputs Demo
```

* This block defines the workflow name displayed in the GitHub Actions UI.
* The name helps engineers identify workflow runs while monitoring execution history, troubleshooting failures, and reviewing workflow activity.

---

```yaml
on:
  workflow_dispatch:
```

* This block defines the workflow trigger.
* The workflow executes only when a **`workflow_dispatch`** event is generated. This can occur when a user manually starts the workflow from the **GitHub Actions UI**, invokes the **Workflow Dispatch API**, or triggers the workflow through tools such as the **GitHub CLI (`gh`)**.
* Using **`workflow_dispatch`** allows us to focus entirely on the Step Output functionality without requiring repository changes.

---

```yaml
jobs:
  deployment-job:
    runs-on: ubuntu-latest
```

* This block defines a job named **`deployment-job`**.
* The job executes on a GitHub-hosted Ubuntu runner.
* All steps within this job execute sequentially on the same runner.

> **Key Observation:** Step Outputs can only be consumed by other steps within the same job. This is possible because all steps execute within the same job context.

---

```yaml
- name: Deploy Application
  id: deploy

  run: |
    echo "Deploying application..."
    sleep 3

    echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

* This step simulates an application deployment.
* After the deployment completes, the step generates a deployment URL.
* The URL is written to **`$GITHUB_OUTPUT`**, which exposes the value as a Step Output.
* The step is assigned the identifier **`deploy`**, allowing downstream steps to reference its outputs.

The expression:

```bash
echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

can be broken down as:

* **`deployment_url`** refers to the output name.
* **`https://cwvj-demo.com`** refers to the output value.
* **`$GITHUB_OUTPUT`** is the special file used by GitHub Actions to capture Step Outputs.

Flow:

```text
Deploy Application Step
         ↓
Creates Deployment URL
         ↓
Step Output
```

> **Important:** Writing a value to **`$GITHUB_OUTPUT`** does not automatically make it available to all jobs in the workflow. The value is initially associated only with the step that generated it.

> **Connection to Previous Lectures:** The special file **`$GITHUB_OUTPUT`** is conceptually similar to **`$GITHUB_ENV`**.
>
> * **`$GITHUB_ENV`** creates environment variables.
> * **`$GITHUB_OUTPUT`** creates outputs.
>
> While the syntax is similar, the purpose is different.

---

```yaml
- name: Display Deployment Details

  run: |
    echo "Application deployed successfully."
    echo "Deployment URL:"
    echo "${{ steps.deploy.outputs.deployment_url }}"
```

* This step consumes the output generated by the deployment step.
* The deployment URL is retrieved using the GitHub Actions output expression syntax.

The expression:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

can be broken down as:

* **`steps`** refers to all previously executed steps within the current job.
* **`deploy`** refers to the step identifier.
* **`outputs`** refers to values exposed by that step.
* **`deployment_url`** refers to the specific output name.

During execution, GitHub Actions resolves the expression to:

```text
https://cwvj-demo.com
```

and prints the value to the workflow logs.

---

```yaml
- name: Send Deployment Notification

  run: |
    echo "Sending notification..."
    echo "Application URL: ${{ steps.deploy.outputs.deployment_url }}"
    echo "Notification sent successfully."
```

* This step also consumes the deployment URL generated earlier.
* Multiple steps can access the same Step Output.
* The output remains available to all subsequent steps within the job.

Flow:

```text
Deploy Application Step
         ↓
Creates Deployment URL
         ↓
Step Output
         ↓
Display Deployment Details Step
         ↓
Consumes Deployment URL

Send Deployment Notification Step
         ↓
Consumes Deployment URL
```

> **Production Insight:** Step Outputs are commonly used to share deployment URLs, release versions, build metadata, commit information, API responses, security scan results, and other runtime-generated values between steps within the same job.

---

### Step 2: Commit and Push the Changes

```bash
# Add the workflow file to Git tracking
git add .

# Create a commit
git commit -m "feat: add step outputs demo"

# Push changes to GitHub
git push
```

---

### Step 3: Execute the Workflow

Navigate to:

```text
GitHub Repository
    → Actions
        → 01 - Step Outputs Demo
            → Run Workflow
```

Click:

```text
Run Workflow
```

and start the workflow.

---

### Step 4: Observe the Workflow Output

Expected output:

```text
Deploying application...

Application deployed successfully.
Deployment URL:
https://cwvj-demo.com

Sending notification...
Application URL: https://cwvj-demo.com
Notification sent successfully.
```

Notice that the deployment URL is generated once and then consumed by multiple downstream steps.

This demonstrates the primary purpose of **Step Outputs**:

```text
One Step Creates Value
          ↓
Multiple Steps Consume Value
```

> **Key Observation:** Step Outputs provide a simple mechanism for sharing runtime-generated information between steps without hardcoding values or generating the same information repeatedly. In the next demo, we will extend this concept and learn how to share information across multiple jobs using **Job Outputs**.

---

## Demo 2: Sharing Deployment Information Using Job Outputs

In this demo, we will learn how **Job Outputs** allow one job to share information with another job.

We will simulate a deployment workflow where:

```text
Deploy Application Job
         ↓
Creates Deployment URL

Send Notification Job
         ↓
Needs Deployment URL
```

The deployment job will generate a deployment URL and expose it as a **Job Output**.

The notification job will then consume the same value without hardcoding it or generating it again.

By the end of this demo, you will understand how to:

* Create Job Outputs
* Expose Step Outputs as Job Outputs
* Access Job Outputs using the **`needs`** context
* Share information between jobs

---

### Step 1: Create the Workflow

Create the following workflow:

**`.github/workflows/02-job-outputs-demo.yaml`**

```yaml
name: 02 - Job Outputs Demo

on:
  workflow_dispatch:

jobs:
  deploy-job:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "Deploying application..."
          sleep 3
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

    outputs:
      deployment_url: ${{ steps.deploy.outputs.deployment_url }}

  notification-job:
    runs-on: ubuntu-latest
    needs:
      - deploy-job
    steps:
      - name: Send Notification
        run: |
          echo "Sending notification..."
          echo "Application URL: ${{ needs.deploy-job.outputs.deployment_url }}"
          echo "Notification sent successfully."
```

#### Explanation

```yaml
name: 02 - Job Outputs Demo
```

* This block defines the workflow name displayed in the GitHub Actions UI.
* The name helps engineers identify workflow runs while monitoring execution history and troubleshooting workflow executions.

---

```yaml
on:
  workflow_dispatch:
```

* This block defines the workflow trigger.
* The workflow executes only when a **`workflow_dispatch`** event is generated. This can occur when a user manually starts the workflow from the **GitHub Actions UI**, invokes the **Workflow Dispatch API**, or triggers the workflow through tools such as the **GitHub CLI (`gh`)**.
* Using **`workflow_dispatch`** allows us to focus entirely on the Job Output functionality without requiring repository changes.

---

Before examining how the **`notification-job`** consumes the deployment URL, let's first understand how the URL is generated and exposed by **`deploy-job`**.

```yaml
jobs:
  deploy-job:
    runs-on: ubuntu-latest

    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "Deploying application..."
          sleep 3
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

    outputs:
      deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* This block defines the **`deploy-job`** job.

* The job executes on a GitHub-hosted Ubuntu runner using:

  ```yaml
  runs-on: ubuntu-latest
  ```

* Its responsibility is to simulate an application deployment and generate deployment metadata that downstream jobs may require.

The job contains the following step:

```yaml
- name: Deploy Application
  id: deploy

  run: |
    echo "Deploying application..."
    sleep 3

    echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

* The step is assigned the identifier **`deploy`** using:

  ```yaml
  id: deploy
  ```

* The **`id`** uniquely identifies the step within the current job and allows its outputs to be referenced later.

* Without a step identifier, GitHub Actions would have no mechanism to determine which step's outputs should be exposed or consumed.

The step executes:

```bash
echo "Deploying application..."
sleep 3

echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

* The first command simulates an application deployment.

* The **`sleep 3`** command introduces a short delay to make the deployment process easier to observe during the demo.

* After the simulated deployment completes, the step generates a deployment URL.

* As discussed in **Type 1**, writing a value to **`$GITHUB_OUTPUT`** creates a **Step Output**.

In this example, the step exposes:

* Output Name → **`deployment_url`**
* Output Value → **`https://cwvj-demo.com`**

By default, Step Outputs are only accessible to other steps within the same job.

To make the value available outside the job, GitHub Actions requires it to be explicitly exposed as a **Job Output** using:

```yaml
outputs:
  deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* This block defines a **Job Output** named **`deployment_url`**.

* The Job Output exposes information generated within the job so that downstream jobs can consume it.

* The value originates from the Step Output generated by the **`deploy`** step.

The expression:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

can be broken down as:

* **`steps`** refers to previously executed steps within the current job.
* **`deploy`** refers to the step identifier.
* **`outputs`** refers to values exposed by that step.
* **`deployment_url`** refers to the specific output name.

GitHub Actions resolves:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

and assigns the resulting value to the Job Output:

```yaml
outputs:
  deployment_url: ...
```

> **Important:** Job Outputs do not generate values themselves. They simply expose values generated inside the job so that downstream jobs can consume them.
>
> As discussed in **Type 1**, Step Outputs allow information sharing between steps within the same job. Job Outputs build upon this concept by allowing selected Step Outputs to cross **job boundaries** and become available to downstream jobs.
>
> In other words:
>
> ```text
> Step Output
>       ↓
> Job Output
> ```
>
> Think of a **Job Output** as a **Step Output that has been intentionally exported** so that other jobs can consume it.

---

Now that the deployment URL has been exposed as a **Job Output**, let's examine how a downstream job consumes it.

```yaml
notification-job:
  runs-on: ubuntu-latest

  needs:
    - deploy-job

  steps:
    - name: Send Notification
      run: |
        echo "Sending notification..."
        echo "Application URL: ${{ needs.deploy-job.outputs.deployment_url }}"
        echo "Notification sent successfully."
```

* This block defines the **`notification-job`** job.

* The job executes on a GitHub-hosted Ubuntu runner using:

  ```yaml
  runs-on: ubuntu-latest
  ```

* Its responsibility is to simulate sending a deployment notification after the application has been deployed.

The job contains the following dependency:

```yaml
needs:
  - deploy-job
```

* The **`needs`** keyword creates a dependency on **`deploy-job`**.

* GitHub Actions waits for the deployment job to complete successfully before starting the notification job.

* Because the notification job depends on the deployment job, it can access any Job Outputs exposed by that job.

> **Connection to Previous Lectures:** As we learned earlier, jobs execute in parallel by default. The **`needs`** keyword creates dependencies and controls execution order.

The notification step executes:

```yaml
- name: Send Notification
  run: |
    echo "Sending notification..."
    echo "Application URL: ${{ needs.deploy-job.outputs.deployment_url }}"
    echo "Notification sent successfully."
```

* The step simulates sending a deployment notification.

* The deployment URL is retrieved using:

  ```yaml
  ${{ needs.deploy-job.outputs.deployment_url }}
  ```

* This expression consumes the Job Output exposed by **`deploy-job`**.

The expression:

```yaml
${{ needs.deploy-job.outputs.deployment_url }}
```

can be broken down as:

* **`needs`** provides access to dependent jobs.
* **`deploy-job`** refers to the upstream job.
* **`outputs`** refers to Job Outputs exposed by that job.
* **`deployment_url`** refers to the specific output name.

During execution, GitHub Actions resolves the expression to:

```text
https://cwvj-demo.com
```

and makes the value available inside the notification job.

> **Key Observation:** A **Job Output** does not generate any value itself. Instead, it exposes information that was already generated by one or more steps within the upstream job.
>
> The deployment URL is generated inside **`deploy-job`**, exposed as a **Job Output**, and then consumed by **`notification-job`** through the **`needs`** context.
>
> ```text
> Deploy Application Job
>          ↓
> Creates Deployment URL
>          ↓
> Step Output
>          ↓
> Job Output
>          ↓
> Send Notification Job
>          ↓
> Consumes Deployment URL
> ```

> **Production Insight:** Job Outputs are commonly used whenever one job generates information that downstream jobs need to consume. Typical examples include deployment URLs, release versions, security scan results, approval metadata, generated resource identifiers, environment information, and deployment status details.


---

### Step 2: Commit and Push the Changes

```bash
# Add the workflow file to Git tracking
git add .

# Create a commit
git commit -m "feat: add job outputs demo"

# Push changes to GitHub
git push
```

---

### Step 3: Execute the Workflow

Navigate to:

```text
GitHub Repository
    → Actions
        → 02 - Job Outputs Demo
            → Run Workflow
```

Click:

```text
Run Workflow
```

and start the workflow.

---

### Step 4: Observe the Workflow Output

Expected output:

```text
Deploying application...

Sending notification...
Application URL: https://cwvj-demo.com
Notification sent successfully.
```

Notice that the deployment URL is generated inside one job and consumed by an entirely different job.

This demonstrates the primary purpose of **Job Outputs**:

```text
One Job Creates Value
         ↓
Another Job Consumes Value
```

> **Key Observation:** Step Outputs solve information sharing within a job, whereas Job Outputs solve information sharing across jobs. In the next section, we will extend this concept even further and learn how **Reusable Workflow Outputs** allow reusable workflows to return information back to the calling workflow.

---

## Demo 3: Returning Deployment Information Using Reusable Workflow Outputs

In this demo, we will learn how **Reusable Workflow Outputs** allow a reusable workflow to return information back to the workflow that invoked it.

We will simulate a centralized deployment framework where:

```text
Calling Workflow
         ↓
Invokes Reusable Deployment Workflow

Reusable Deployment Workflow
         ↓
Creates Deployment URL

Calling Workflow
         ↓
Needs Deployment URL
```

The reusable workflow will generate a deployment URL and return it as a **Reusable Workflow Output**.

The calling workflow will then consume the same value without needing to know how the deployment was performed internally.

By the end of this demo, you will understand how to:

* Create Reusable Workflow Outputs
* Return values from a reusable workflow
* Consume outputs inside the calling workflow
* Share information between workflows

> **Learning Observation:** Notice that we are intentionally continuing the same **Deployment URL** example used in the previous demos. The business scenario remains unchanged while only the scope of information sharing changes:
>
> * **Step Outputs** → Step to Step
> * **Job Outputs** → Job to Job
> * **Reusable Workflow Outputs** → Workflow to Workflow

---

### Step 1: Create the Reusable Workflow

Create the following reusable workflow:

**`.github/workflows/deploy-application.yaml`**

```yaml
name: Centralized Deployment Workflow

on:
  workflow_call:
    outputs:
      deployment_url:
        description: Deployment URL
        value: ${{ jobs.deploy-job.outputs.deployment_url }}

jobs:
  deploy-job:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "Deploying application..."
          sleep 3
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

    outputs:
      deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

#### Explanation

Before discussing the **Reusable Workflow Output**, it is important to understand where the value originates.

As discussed in **Type 1** and **Type 2**, outputs are built in layers.

A value is typically:

```text
Generated by a Step
         ↓
Exposed as a Step Output
         ↓
Exposed as a Job Output
         ↓
Exposed as a Reusable Workflow Output
```

Let's first examine how the deployment URL is generated and exposed within the reusable workflow.

---

```yaml
jobs:
  deploy-job:
    runs-on: ubuntu-latest

    steps:
      - name: Deploy Application
        id: deploy
        run: |
          echo "Deploying application..."
          sleep 3
          echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT

    outputs:
      deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* This block defines the **`deploy-job`** job.

* The job executes on a GitHub-hosted Ubuntu runner using:

  ```yaml
  runs-on: ubuntu-latest
  ```

* Its responsibility is to simulate an application deployment and generate deployment metadata that downstream consumers may require.

The job contains the following step:

```yaml
- name: Deploy Application
  id: deploy

  run: |
    echo "Deploying application..."
    sleep 3
    echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

* The step is assigned the identifier **`deploy`** using:

  ```yaml
  id: deploy
  ```

* The **`id`** uniquely identifies the step within the current job and allows its outputs to be referenced later.

* Without a step identifier, GitHub Actions would have no mechanism to determine which step's outputs should be exposed or consumed.

The step executes:

```bash
echo "Deploying application..."
sleep 3
echo "deployment_url=https://cwvj-demo.com" >> $GITHUB_OUTPUT
```

* The first command simulates an application deployment.

* The **`sleep 3`** command introduces a short delay to make the deployment process easier to observe during the demo.

* After the simulated deployment completes, the step generates a deployment URL.

* As discussed in **Type 1**, writing a value to **`$GITHUB_OUTPUT`** creates a **Step Output**.

In this example, the step exposes:

* Output Name → **`deployment_url`**
* Output Value → **`https://cwvj-demo.com`**

By default, Step Outputs are only accessible to other steps within the same job.

To make the value available outside the job, GitHub Actions requires it to be explicitly exposed as a **Job Output** using:

```yaml
outputs:
  deployment_url: ${{ steps.deploy.outputs.deployment_url }}
```

* This block defines a **Job Output** named **`deployment_url`**.

* The Job Output exposes information generated within the job so that consumers outside the step can access it.

* The value originates from the Step Output generated by the **`deploy`** step.

The expression:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

can be broken down as:

* **`steps`** refers to previously executed steps within the current job.
* **`deploy`** refers to the step identifier.
* **`outputs`** refers to values exposed by that step.
* **`deployment_url`** refers to the specific output name.

GitHub Actions resolves:

```yaml
${{ steps.deploy.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

and assigns the resulting value to the Job Output:

```yaml
outputs:
  deployment_url: ...
```

At this point, the deployment URL is available as a **Job Output**.

However, the value is still confined to the reusable workflow itself.

To make it available to the calling workflow, GitHub Actions requires the Job Output to be explicitly exposed as a **Reusable Workflow Output**.

> **Important:** Job Outputs do not generate values themselves. They simply expose values generated inside the job so that other consumers can access them.
>
> As discussed in **Type 2**, Job Outputs build upon the Step Output concept by allowing selected Step Outputs to cross **job boundaries**.
>
> ```text
> Step Output
>       ↓
> Job Output
> ```

---

```yaml
on:
  workflow_call:
    outputs:
      deployment_url:
        description: Deployment URL
        value: ${{ jobs.deploy-job.outputs.deployment_url }}
```

* This block defines a **Reusable Workflow Output**.

* The output is declared within the **`workflow_call`** section because it represents information that the reusable workflow will return to the calling workflow.

* The reusable workflow exposes an output named **`deployment_url`**.

* The **`description`** field provides documentation for the output and helps consumers understand the purpose of the value being returned.

* The output value originates from the **Job Output** generated by **`deploy-job`**.

* Once exposed, GitHub Actions automatically makes the value available to any workflow that invokes this reusable workflow.

The expression:

```yaml
${{ jobs.deploy-job.outputs.deployment_url }}
```

can be broken down as:

* **`jobs`** refers to jobs defined within the reusable workflow.
* **`deploy-job`** refers to the job that generated the output.
* **`outputs`** refers to outputs exposed by that job.
* **`deployment_url`** refers to the specific Job Output being returned.

In this example, GitHub Actions resolves:

```yaml
${{ jobs.deploy-job.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

and exposes the resulting value as a **Reusable Workflow Output** named **`deployment_url`**.

> **Important:** Reusable Workflow Outputs do not generate values themselves. They expose **Job Outputs** so that calling workflows can consume them.
>
> Notice that the deployment URL is generated only once inside the deployment step. Each subsequent output layer simply exposes the same value to a broader scope.
>
> ```text
> Step Output
>       ↓
> Job Output
>       ↓
> Reusable Workflow Output
> ```
>
> Each output type builds upon the previous one and allows information to cross a larger execution boundary.

> **Connection to Type 2:** Just as **Job Outputs** expose Step Outputs to downstream jobs, **Reusable Workflow Outputs** expose Job Outputs to calling workflows.


---

### Step 2: Create the Calling Workflow

Create the following workflow:

**`.github/workflows/03-reusable-workflow-outputs-demo.yaml`**

```yaml
name: 03 - Reusable Workflow Outputs Demo

on:
  workflow_dispatch:

jobs:
  deploy-job:
    uses: ./.github/workflows/deploy-application.yaml

  notification-job:
    runs-on: ubuntu-latest
    needs:
      - deploy-job
    steps:
      - name: Send Notification
        run: |
          echo "Sending notification..."
          echo "Application URL:"
          echo "${{ needs.deploy-job.outputs.deployment_url }}"
          echo "Notification sent successfully."
```

#### Explanation

Before examining how the deployment URL is consumed, let's first understand how the Calling Workflow invokes the reusable workflow.

```yaml
jobs:
  deploy-job:
    uses: ./.github/workflows/deploy-application.yaml
```

* This block defines the **`deploy-job`** job.

* Instead of defining deployment logic directly within the workflow, the job delegates deployment responsibilities to a reusable workflow using:

  ```yaml
  uses: ./.github/workflows/deploy-application.yaml
  ```

* The **`uses`** keyword instructs GitHub Actions to execute the reusable workflow located at the specified path.

* During execution, GitHub Actions executes the reusable workflow and waits for it to complete.

* As discussed in the previous step, the reusable workflow generates a deployment URL and exposes it as a **Reusable Workflow Output** named **`deployment_url`**.

* When the reusable workflow completes successfully, GitHub Actions automatically exposes any Reusable Workflow Outputs through the job that invoked it.

* In this example, the reusable workflow returns an output named **`deployment_url`**, which becomes available through the **`deploy-job`** job.

> **Important:** Notice that **`deploy-job`** does not define an **`outputs`** block within the Calling Workflow.
>
> GitHub Actions automatically maps **Reusable Workflow Outputs** onto the job that invoked the reusable workflow, making them accessible through:
>
> ```yaml
> needs.deploy-job.outputs.<output-name>
> ```
>
> This is why downstream jobs can access:
>
> ```yaml
> ${{ needs.deploy-job.outputs.deployment_url }}
> ```
>
> even though **`deploy-job`** does not explicitly define any outputs in the Calling Workflow itself.

> **Production Insight:** Large organizations commonly centralize deployment, compliance, security scanning, and platform engineering logic inside reusable workflows. Application teams invoke these workflows rather than implementing the same logic repeatedly across repositories.

---

Now that the reusable workflow has been invoked, let's examine how a downstream job consumes the output returned by that workflow.

```yaml
notification-job:
  runs-on: ubuntu-latest

  needs:
    - deploy-job

  steps:
    - name: Send Notification
      run: |
        echo "Sending notification..."
        echo "Application URL:"
        echo "${{ needs.deploy-job.outputs.deployment_url }}"
        echo "Notification sent successfully."
```

* This block defines the **`notification-job`** job.

* The job executes on a GitHub-hosted Ubuntu runner using:

  ```yaml
  runs-on: ubuntu-latest
  ```

* Its responsibility is to simulate sending a deployment notification after the deployment completes successfully.

The job contains the following dependency:

```yaml
needs:
  - deploy-job
```

* The **`needs`** keyword creates a dependency on **`deploy-job`**.

* GitHub Actions waits for the reusable workflow execution to complete successfully before starting the notification job.

* Because the notification job depends on **`deploy-job`**, it can access any outputs exposed by that job.

* This includes outputs returned by the reusable workflow.

The notification step executes:

```yaml
- name: Send Notification
  run: |
    echo "Sending notification..."
    echo "Application URL:"
    echo "${{ needs.deploy-job.outputs.deployment_url }}"
    echo "Notification sent successfully."
```

* The step simulates sending a deployment notification.

* The deployment URL is retrieved using:

  ```yaml
  ${{ needs.deploy-job.outputs.deployment_url }}
  ```

* This expression consumes the **Reusable Workflow Output** returned by the reusable workflow.

The expression can be broken down as:

* **`needs`** provides access to dependent jobs and reusable workflow executions.
* **`deploy-job`** refers to the job that invoked the reusable workflow.
* **`outputs`** refers to outputs returned by the reusable workflow.
* **`deployment_url`** refers to the specific output name being consumed.

During execution, GitHub Actions resolves:

```yaml
${{ needs.deploy-job.outputs.deployment_url }}
```

to:

```text
https://cwvj-demo.com
```

and makes the value available inside the notification job.

> **Key Observation:** The deployment URL is generated inside the reusable workflow, exposed as a **Reusable Workflow Output**, automatically mapped onto **`deploy-job`**, and then consumed by **`notification-job`** through the **`needs`** context.
>
> ```text
> Reusable Workflow
>          ↓
> Creates Deployment URL
>          ↓
> Reusable Workflow Output
>          ↓
> deploy-job
>          ↓
> notification-job
>          ↓
> Consumes Deployment URL
> ```

> **Connection to Previous Lectures:** As we learned earlier, the **`needs`** keyword controls execution order and creates dependencies between jobs. Reusable Workflow Outputs are commonly consumed through these dependencies.

---

### Step 3: Commit and Push the Changes

```bash
# Add the workflow files to Git tracking
git add .

# Create a commit
git commit -m "feat: add reusable workflow outputs demo"

# Push changes to GitHub
git push
```

---

### Step 4: Execute the Workflow

Navigate to:

```text
GitHub Repository
    → Actions
        → 03 - Reusable Workflow Outputs Demo
            → Run Workflow
```

Click:

```text
Run Workflow
```

and start the workflow.

---

### Step 5: Observe the Workflow Output

Expected output:

```text
Deploying application...

Sending notification...
Application URL:
https://cwvj-demo.com
Notification sent successfully.
```

Notice that the deployment URL is generated inside the reusable workflow and then returned to the calling workflow.

This demonstrates the primary purpose of **Reusable Workflow Outputs**:

```text
Reusable Workflow Creates Value
                ↓
Calling Workflow Consumes Value
```

> **Key Observation:** Step Outputs solve information sharing between steps, Job Outputs solve information sharing between jobs, and Reusable Workflow Outputs solve information sharing between workflows. The underlying concept remains the same: **one execution unit creates a value and another execution unit consumes it.**

---

## Conclusion

Outputs are one of the most important mechanisms for sharing information within GitHub Actions.

Throughout this lecture, we learned that Outputs allow runtime-generated values to move across different execution boundaries without hardcoding information or generating the same value multiple times.

We explored three different Output types:

* **Step Outputs** for communication between steps within the same job.
* **Job Outputs** for communication between jobs.
* **Reusable Workflow Outputs** for communication between workflows.

Although the implementation differs slightly for each type, the underlying concept remains the same:

```text
One Execution Unit Creates a Value
                 ↓
Another Execution Unit Consumes the Value
```

A useful mental model is to think of Outputs as layers of visibility:

```text
Step Output
      ↓
Available to Subsequent Steps

Job Output
      ↓
Available to Downstream Jobs

Reusable Workflow Output
      ↓
Available to Calling Workflows
```

As workflows become larger and more sophisticated, Outputs play a critical role in enabling modular workflow design, reducing duplication, improving maintainability, and ensuring that all stages of a pipeline operate on the same runtime-generated information.

> **Key Takeaway:** The primary difference between **Step Outputs**, **Job Outputs**, and **Reusable Workflow Outputs** is not the value being shared, but the **execution boundary that the value must cross**.
>
> ```text
> Step → Step              → Step Output
> Job → Job                → Job Output
> Workflow → Workflow      → Reusable Workflow Output
> ```

In the next lecture, we will learn about **Artifacts**, which complement Outputs by providing a mechanism for sharing files, reports, binaries, logs, and other deliverables generated during workflow execution.

---

## References

The following resources provide additional information about GitHub Actions Outputs:

* GitHub Actions Documentation – Passing Information Between Jobs  
  https://docs.github.com/actions/using-jobs/defining-outputs-for-jobs

* GitHub Actions Documentation – Workflow Syntax  
  https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions

* GitHub Actions Documentation – Reusing Workflows  
  https://docs.github.com/actions/using-workflows/reusing-workflows

* GitHub Actions Documentation – Workflow Commands for GitHub Actions  
  https://docs.github.com/actions/using-workflows/workflow-commands-for-github-actions

* GitHub Actions Documentation – Contexts Reference  
  https://docs.github.com/actions/learn-github-actions/contexts

* GitHub Actions Documentation – Expressions  
  https://docs.github.com/actions/learn-github-actions/expressions
