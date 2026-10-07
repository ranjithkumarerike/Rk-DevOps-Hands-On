# GitHub Actions Workflow Logic Explained | Filters, Contexts, Variables & Expressions

## Video reference for this lecture is the following:

[![Watch the video](https://img.youtube.com/vi/KIH79Y3xJ8c/maxresdefault.jpg)](https://www.youtube.com/watch?v=KIH79Y3xJ8c&ab_channel=CloudWithVarJosh)

---
## ⭐ Support the Project  
If this **repository** helps you, give it a ⭐ to show your support and help others discover it! 

---

## Table of Contents
* [Introduction](#introduction)  
* [1. Event Filters](#1-event-filters)  
  * [Example 1: Using `branches` and `paths`](#example-1-using-branches-and-paths)  
  * [Example 2: Using Ignore Filters](#example-2-using-ignore-filters)  
* [2. Activity Types](#2-activity-types)  
  * [Additional Activity Type Examples](#additional-activity-type-examples)  
  * [Key Production Insights](#key-production-insights)  
* [**Demo:** Understanding Event Filters and Activity Types](#demo-understanding-event-filters-and-activity-types)  
  * [Step 1: Repository Setup and Authentication](#step-1-repository-setup-and-authentication)  
  * [Step 2: Creating the Workflow File](#step-2-creating-the-workflow-file)  
  * [Step 3: Creating Application Directories](#step-3-creating-application-directories)  
  * [Step 4: Initializing Git and Configuring the Main Branch](#step-4-initializing-git-and-configuring-the-main-branch)  
  * [Step 5: Demonstrating Non-Triggering Behavior on Main](#step-5-demonstrating-non-triggering-behavior-on-main)  
  * [Step 6: Creating the Feature Branch and Triggering the Workflow](#step-6-creating-the-feature-branch-and-triggering-the-workflow)  
  * [Step 7: Creating a Pull Request and Observing Workflow Execution](#step-7-creating-a-pull-request-and-observing-workflow-execution)  
  * [Step 8: Demonstrating the Synchronize Activity Type](#step-8-demonstrating-the-synchronize-activity-type)  
* [Variables, Contexts, and Expressions in GitHub Actions](#variables-contexts-and-expressions-in-github-actions)  
  * [1. Variables ](#1-variables-variable-syntax)  
    * [A. Default Variables Provided by GitHub](#a-default-variables-provided-by-github)  
    * [B. Custom Variables Created by Users](#b-custom-variables-created-by-users)  
  * [2. Contexts](#2-contexts--syntax)  
  * [3. Expressions ](#3-expressions--) 
  * [Determining When to Use Variables, Contexts, and Expressions](#determining-when-to-use-variables-contexts-and-expressions)  
* [**Demo:** Understanding Variables, Contexts, and Expressions in GitHub Actions](#demo-understanding-variables-contexts-and-expressions-in-github-actions)  
  * [Step 1: Creating the Project Structure and Initializing Git](#step-1-creating-the-project-structure-and-initializing-git)  
  * [Step 2: Create the Workflow File](#step-2-create-the-workflow-file)  
  * [Step 3: Adding Remote Repository, Committing, and Pushing Changes](#step-3-adding-remote-repository-committing-and-pushing-changes)  
  * [Step 4: Observe Workflow Execution](#step-4-observe-workflow-execution)  
* [Conclusion](#conclusion)  
* [References](#references)  


---

## Introduction

In real-world engineering environments, organizations rarely allow workflows to execute for every possible GitHub event. Instead, workflows are carefully refined using **event filters**, **activity types**, **variables**, **contexts**, and **expressions** so CI/CD pipelines execute only when meaningful operational changes occur.

Without proper execution control, organizations may experience **unnecessary workflow executions**, **increased CI/CD costs**, **wasted runner resources**, **longer workflow queues**, and **reduced operational efficiency**.

In this lecture, we will deeply understand how GitHub Actions evaluates workflow execution conditions using:

* event filters and activity types
* branch and path filters
* pull request activity types
* logical AND vs OR trigger behavior
* variables, contexts, and expressions
* workflow engine vs runner execution behavior
* conditional workflow orchestration

We will also perform multiple hands-on demos to validate real-world workflow execution scenarios commonly seen in production CI/CD environments.

---

## Refining Workflow Triggers Behavior

![Alt text](/images/4a.png)

GitHub Actions provides multiple ways to customize when workflows should execute. Two important mechanisms used for refining workflow trigger behavior are:

1. **Event Filters**
   Event filters help control **under what conditions** workflows should execute.

2. **Activity Types**
   Activity types help control **which operation within an event** should trigger workflows.

These mechanisms become extremely important in production environments because organizations rarely want workflows to execute for every possible event occurrence. Instead, workflows are configured to execute only when meaningful operational changes occur.

Without proper trigger customization, organizations may experience:

* **unnecessary workflow executions** → workflows run even when no meaningful application changes exist
* **increased CI/CD costs** → excessive workflow runs increase GitHub Actions usage and infrastructure costs
* **wasted runner resources** → runners spend time executing irrelevant jobs and pipelines
* **longer workflow queues** → important workflows wait longer because unnecessary jobs occupy runners
* **reduced operational efficiency** → engineering teams receive slower CI/CD feedback and reduced productivity


---

## 1. Event Filters

Event filters allow us to define **additional conditions** that must be satisfied before a workflow executes.

Up until now, we have mostly used blanket event triggers such as:

```yaml id="x8q2pw"
on:
  push:
```

This tells GitHub Actions:

* trigger the workflow whenever a push occurs
* no additional filtering is applied
* every push can potentially trigger workflow execution

While this works well for learning environments and small repositories, **production workflows** usually require much more granular control.

For example, organizations may want to:

* trigger workflows only for **specific branches**
* ignore **documentation-only changes**
* execute workflows only when **application code changes**
* trigger deployments only for **release branches**
* avoid unnecessary CI executions for **non-operational changes**

This is where **event filters** become important.

GitHub Actions supports multiple commonly used event filters such as:

* **`branches`**
* **`branches-ignore`**
* **`tags`**
* **`tags-ignore`**
* **`paths`**
* **`paths-ignore`**

---

### Example 1: Using `branches` and `paths`

The following production-style example demonstrates commonly used inclusion-based filters:

```yaml id="m7q2pk"
on:
  push:
    branches:
      - "develop"
      - "release/*"

    paths:
      - "app/**"
      - "docker/**"
      - ".github/workflows/**"
```

In the above example:

* workflows execute only for pushes to:

  * **`develop`**
  * **`release/*`**

* workflows execute only when changes occur inside:

  * **`app/`**
  * **`docker/`**
  * **`.github/workflows/`**

The following wildcard pattern becomes important:

```yaml id="f4m8ks"
app/**
```

The `**` wildcard represents **recursive matching**.

This means:

* match all files and directories recursively inside `app/`
* match nested files regardless of directory depth

For example:

```text id="t6m2qp"
app/main.py
app/api/routes.py
app/services/auth/login.py
```

would all match:

```yaml id="n4p8qx"
app/**
```

This becomes extremely useful in production repositories because applications commonly contain **deeply nested directory structures**.

---

### Example 2: Using Ignore Filters

The following production-style example demonstrates exclusion-based filters:

```yaml id="r8n4dj"
on:
  push:
    branches-ignore:
      - "experimental/*"
      - "temp/*"

    paths-ignore:
      - "**/*.md"
      - "docs/**"
```

In the above example:

* workflows do not execute for pushes to:

  * **`experimental/*`**
  * **`temp/*`**

* workflows do not execute when changes occur only inside:

  * **Markdown files**
  * **documentation directories**

This type of configuration is commonly used to:

* avoid unnecessary CI executions
* reduce workflow costs
* prevent temporary branches from consuming runner resources


> **Important:** For a single event, GitHub Actions does not allow combining:
>
> * `branches` with `branches-ignore`
> * `paths` with `paths-ignore`
>
> You must choose either inclusion-based filters or exclusion-based filters for a given event configuration.

> **Production Insight:** Large repositories and monorepos heavily rely on event filters so workflows execute only for relevant application or infrastructure changes instead of triggering across the entire repository.

> **Production Insight:** Event filters help reduce unnecessary workflow executions, optimize CI/CD costs, improve runner utilization, and reduce workflow queue congestion in large engineering environments.


---

## 2. Activity Types

While **event filters** control **under what conditions** workflows execute, **activity types** control **which operation within an event** triggers workflow execution.

Many GitHub events contain multiple possible activities.

For example, a pull request can be **opened, updated, reopened, closed, marked ready for review, assigned reviewers**, and many more. Each of these represents a different activity type within the same `pull_request` event.

All of these belong to the same:

```yaml id="j2r7mk"
pull_request
```

event.

Activity types allow us to specify which of these activities should trigger workflow execution.

The following production-style example demonstrates activity types:

```yaml id="v7m5qa"
on:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened
      - closed
      - ready_for_review

    branches:
      - main
```

In the above example:

* workflow executes when a pull request is **opened**
* workflow executes when **new commits are pushed** to the pull request
* workflow executes when a previously closed pull request is **reopened**
* workflow executes when a pull request is **closed**
* workflow executes when a draft pull request becomes **ready for review**
* workflow executes only for pull requests targeting the **`main`** branch

> **Important:** By default, `pull_request` workflows already execute for:
>
> * `opened`
> * `synchronize`
> * `reopened`
>
> activity types.
>
> Additional activity types such as:
>
> * `closed`
> * `ready_for_review`
>
> must be explicitly defined using the `types` keyword.

The following activity type becomes extremely important:

```yaml id="r8n4dj"
synchronize
```

Many beginners initially assume this refers to repository synchronization. However, in GitHub Actions, `synchronize` specifically means:

* **new commits were pushed to an existing pull request branch**

For example:

1. Developer creates a pull request
2. CI validation executes
3. Review feedback is received
4. Developer pushes additional commits
5. GitHub generates a **`synchronize`** activity
6. Workflow executes again automatically

This behavior becomes extremely important in production environments because organizations typically want CI validation to rerun whenever pull request contents change.

The following configuration:

```yaml id="c8v1tr"
branches:
  - main
```

acts as an additional **event filter**.

This means the workflow executes only when:

* the pull request targets the **`main`** branch
* and one of the specified activity types occurs

Both conditions must be satisfied before workflow execution occurs.


---

### Additional Activity Type Examples

The concept of activity types is not limited only to pull requests. Multiple GitHub events support activity types.

For example, issue-related workflows may use the following configuration:

```yaml id="m7q2pk"
on:
  issues:
    types:
      - opened
      - closed
      - labeled
```

In this example, workflows execute when:

* an issue is created
* an issue is closed
* a label is added to an issue

Similarly, release workflows may use activity types such as:

```yaml id="x8q2pw"
on:
  release:
    types:
      - published
      - prereleased
```

In this example, workflows execute when:

* a production release is published
* a pre-release version is published

---

#### Key Production Insights

* **Activity types and filters** help prevent **unnecessary workflow executions**, reducing CI/CD costs, runner consumption, and workflow queue congestion.

* **Pull request workflows** are commonly configured to rerun automatically whenever new commits are pushed so CI validation always reflects the **latest application state**.

* **Release activity types** are heavily used for **deployment automation**, **artifact publishing**, **release notifications**, and **production release orchestration** workflows.

* Understanding the logical **AND relationship** between **activity types** and **event filters** is extremely important because incorrect trigger conditions are one of the most common reasons behind **unexpected workflow executions** and **skipped CI validations** in production environments.

---

## Demo: Understanding Event Filters and Activity Types

In this demo, we will validate how:

* **event filters**
* **activity types**

control workflow execution behavior in GitHub Actions.

We will specifically observe:

* push-based workflow execution
* branch-based filtering
* path-based filtering
* pull request activity types
* workflow execution conditions
* non-triggering scenarios

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

---

### Step 2: Creating the Workflow File

Go inside the `project-files` directory and create the following directory structure:

```bash id="2a948l"
mkdir -p .github/workflows
```

Now create the following workflow file:

```text id="m7q2pk"
.github/workflows/01-filter-type-demo.yaml
```



Add the following workflow definition:

```yaml id="x8q2pw"
name: 01 - Production Workflow Trigger Demo

on:
  push:
    branches:
      - "develop"
      - "feature/*"

    paths:
      - "app/**"
      - "docker/**"
      - ".github/workflows/**"

  pull_request:
    types:
      - opened
      - synchronize
      - reopened
      - closed
      - ready_for_review

    branches:
      - "main"

jobs:
  validation-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print Workflow Context
        run: |
          echo "Workflow triggered successfully"
          echo "Event Type: $GITHUB_EVENT_NAME"
          echo "Branch: $GITHUB_REF_NAME"
```

This workflow demonstrates:

* branch-based event filters
* path-based event filters
* pull request activity types
* multiple workflow trigger conditions

---

#### When Will This Workflow Trigger?

This workflow can trigger from **either** of the following top-level events:

* a matching **`push`** event
* OR a matching **`pull_request`** event

Both events do **not** need to occur together.

For the **`push`** event, the workflow triggers only when:

* the push targets:

  * `develop`
  * or `feature/*`
* and changes occur inside:

  * `app/**`
  * `docker/**`
  * `.github/workflows/**`

For the **`pull_request`** event, the workflow triggers only when:

* the pull request targets:

  * `main`
* and the activity type is:

  * `opened`
  * `synchronize`
  * `reopened`
  * `closed`
  * or `ready_for_review`

> **Important:** The logical **AND** behavior discussed earlier applies to filters and activity types configured within an individual event such as `push` or `pull_request`.
>
> Different top-level events themselves behave more like a logical **OR** operation. This means:
>
> * a matching `push` event can trigger the workflow
> * a matching `pull_request` event can also trigger the workflow
>
> GitHub Actions evaluates each top-level event independently, and a workflow run can be triggered whenever any configured event matches.
>
> If multiple events occur and independently satisfy workflow conditions, GitHub Actions can create multiple workflow runs.
>
> Official documentation:
> [GitHub Actions Multiple Events Documentation](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions?utm_source=chatgpt.com#using-activity-types-and-filters-with-multiple-events)


---

### Step 3: Creating Application Directories

Inside the `project-files` directory, create the following application directories:

```bash id="f4m8ks"
mkdir app
mkdir docker
```

Now create a sample application file:

```bash id="t6m2qp"
touch app/app.py
```

> **Note:** The `app.py` file does not need to contain anything for this demo because we are primarily validating workflow trigger behavior and event execution conditions.

These directories become important because our workflow contains the following path filter:

```yaml id="n4p8qx"
paths:
  - "app/**"
  - "docker/**"
  - ".github/workflows/**"
```

Meaning:

* workflow executes only when changes occur inside these paths

---

### Step 4: Initializing Git and Configuring the Main Branch

Inside the `project-files` directory, initialize a local Git repository:

```bash id="p3k7zm"
git init
```

This creates the **`.git/`** directory and enables local Git tracking, commits, and branch operations.

Now ensure the local primary branch is named **`main`**:

```bash id="m8x2qp"
git branch -M main
```

This step becomes important because:

* Git installations may still use **`master`** as the default branch name
* modern GitHub repositories primarily use **`main`**
* aligning local and remote primary branch names avoids confusion during pushes and pull requests

Now connect the local repository to your GitHub repository:

```bash id="t4n7zk"
git remote add origin git@github.com:<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>.git
```

> **Important:** Ensure your GitHub repository already exists and authentication with GitHub is configured properly. These concepts were covered extensively in **Lecture 01**.

---

### Step 5: Demonstrating Non-Triggering Behavior on Main

Now add sample content inside the application file:

```python id="r8n4dj"
print("GitHub Actions Trigger Demo")
```

Commit and push the changes directly to the **`main`** branch:

```bash id="c8v1tr"
git add .
git commit -m "feat: add trigger demo application"
git push -u origin main
```

The `-u` flag sets the upstream tracking relationship between the local and remote branch, allowing future pushes and pulls without repeatedly specifying the branch name.

Even though:

* a valid **`push`** event occurred
* modified files matched:

  * **`app/**`**

the workflow does **NOT** execute.

Why?

Because the workflow allows push-based execution only for:

```yaml id="v7m5qa"
branches:
  - "develop"
  - "feature/*"
```

This means direct pushes to:

```text id="m2v7qa"
main
```

do not satisfy the configured branch filter condition.

This demonstrates an extremely important GitHub Actions behavior:

* workflows execute only when **all configured conditions** match successfully
* even a valid event gets skipped if branch filters do not match

> **Production Insight:** In real-world engineering environments, direct pushes to **`main`** or other primary branches are usually restricted using **branch protection rules**. Developers are typically required to create pull requests, complete CI validation checks, and receive approvals before changes can be merged into protected branches.


---

### Step 6: Creating the Feature Branch and Triggering the Workflow

Now create and switch to a feature branch:

```bash id="j2r7mk"
git switch -c feature/trigger-demo
```

The following wildcard pattern:

```yaml id="x7n4pk"
feature/*
```

matches branches such as:

```text id="q9w2ls"
feature/login
feature/payment-api
feature/trigger-demo
```

Now make an additional change inside:

```text id="w3n8pl"
app/app.py
```

Add another sample line:

```python id="f5m2qp"
print("Triggering workflow from feature branch")
```

Commit and push the changes:

```bash id="k5x9zb"
git add .
git commit -m "feat: trigger workflow from feature branch"
git push -u origin feature/trigger-demo
```

This time the workflow executes successfully because:

* a valid **`push`** event occurred
* the target branch matched **`feature/*`**
* modified files matched **`app/**`**

All configured workflow trigger conditions are now satisfied successfully.

Now navigate to the **Actions** tab in the **GitHub UI** and observe:

* workflow execution triggered automatically
* event type displayed as:

  ```text id="a8v2pk"
  push
  ```
* branch displayed as:

  ```text id="b4n7qx"
  feature/trigger-demo
  ```

> **Production Insight:** Feature branches are heavily used in real-world engineering workflows because they allow teams to isolate changes, validate CI/CD pipelines safely, and create pull requests before merging into stable branches such as **`main`** or **`develop`**.



---

### Step 7: Creating a Pull Request and Observing Workflow Execution

Now create the following pull request:

```text id="t6m2qp"
feature/trigger-demo → main
```

Once the pull request is created:

* GitHub generates a **`pull_request`** event and the workflow executes automatically again
* target branch becomes **`main`** and activity type becomes **`opened`**
* workflow execution succeeds because:

  * branch filter allows **`main`**
  * activity types allow **`opened`**

Configured conditions:

```yaml id="x8q2pw"
branches:
  - main
```

```yaml id="f4m8ks"
types:
  - opened
```

Now navigate to the workflow logs and observe:

```text id="u7n2pk"
Event Type: pull_request
```

This confirms the workflow executed because of a valid pull request event and the configured activity type conditions matched successfully.


---

### Step 8: Demonstrating the Synchronize Activity Type

Now make an additional change inside:

```text id="n4p8qx"
app/app.py
```

Add another sample line inside the file:

```python id="m8q2zk"
print("Testing synchronize activity type")
```

Commit and push the changes again:

```bash id="j2r7mk"
git add .
git commit -m "feat: validate synchronize workflow trigger"
git push origin feature/trigger-demo
```

Since the pull request is already open:

* GitHub automatically generates the **`synchronize`** activity type
* the existing pull request gets updated with new commits
* workflow execution gets triggered again automatically

Now navigate to the **GitHub Actions** tab.

This time you will observe **two separate workflow executions**:

* one execution triggered because of the:

  * **`push`** event on:

    * **`feature/trigger-demo`**
* another execution triggered because of the:

  * **`pull_request`** event with activity type:

    * **`synchronize`**

This demonstrates an extremely important production behavior:

* whenever new commits are pushed to an existing pull request
* CI validation workflows rerun automatically
* validation always reflects the latest application state
* developers receive updated CI feedback after every change

---

## Variables, Contexts, and Expressions in GitHub Actions

GitHub Actions allows workflow-related information and execution logic to be handled in three primary ways:

1. **Variables (`$VARIABLE` syntax)**
   Used mainly inside **runner shell commands**, **scripts**, and **runtime command execution** after the job starts running on the runner.

2. **Contexts (`github.*`, `runner.*`, etc.)**
   Used mainly for accessing **workflow-related metadata and information** such as repository details, events, jobs, steps, runners, secrets, variables, and matrix values.

3. **Expressions (`${{ }}` syntax)**
   Used mainly inside **workflow YAML** at the **workflow, job, and step level** for **conditions**, **dynamic evaluation**, **workflow orchestration**, and **execution control**.

These three concepts are heavily used together in **production GitHub Actions workflows**. You will also often notice that many **context values** are also available as **variables**, which creates some overlap between the different approaches.

For example:

* **`github`** → context
* **`github.ref`** → context property access
* **`${{ github.ref }}`** → expression syntax evaluating a context value
* **`${{ github.ref == 'refs/heads/main' }}`** → conditional expression
* **`$GITHUB_REF`** → variable available inside the runner

> **Note:** GitHub documentation commonly uses the term **variables**, while many engineers also casually refer to them as **environment variables** because they become available inside the runner shell environment during job execution.

Because of this overlap, understanding **what variables are**, **how contexts work**, and **how expressions are evaluated** becomes extremely important while building real-world GitHub Actions workflows.

> **Practical Note:** You will often notice that contexts are also used inside runner commands because GitHub automatically exposes many context values as variables as well. Due to this overlap, both approaches may sometimes appear interchangeable.
>
> As a general rule of thumb:
>
> * use **variables (`$VARIABLE`)** inside shell commands and scripts whenever possible
> * use **contexts and expressions (`${{ }}`)** for workflow logic, conditions, orchestration, and dynamic evaluation
>
> If a value is only available through a context, then expressions must be used.


---

### 1. Variables (`$VARIABLE` Syntax)

**Concepts:** [GitHub Actions Variables Concepts](https://docs.github.com/en/actions/concepts/workflows-and-actions/variables)

**Reference:** [GitHub Actions Variables Documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/variables)

Environment variables are mainly used inside **runner shell commands**, **scripts**, and **runtime command execution**.

Variables help store and reuse **non-sensitive configuration information** such as **compiler flags**, **usernames**, **server names**, **environment-specific configuration**, and **application-specific values**.

GitHub Actions variables can be defined at multiple levels:

* **Repository-level variables** can be accessed by all workflows within that repository.
* Variables defined using **`env:`** can be scoped at the **workflow**, **job**, or **step** level and are available only within the scope where they are declared.
* **Organization-level variables** can be shared across multiple repositories within a GitHub organization, allowing workflows across those repositories to access common configuration values.

The level at which you define a variable depends on its intended **scope** and **reuse requirements**.

As a general guideline:

* use variables defined with **`env:`** for **workflow-specific configuration**
* use **repository-level variables** for values shared across multiple workflows in the same repository
* use **organization-level variables** for values shared across multiple repositories within an organization

> **Note:** **Repository-level** and **organization-level variables** are configured through the **GitHub UI**, whereas variables defined using **`env:`** are declared directly inside the **workflow YAML file**.

In GitHub Actions, variables are primarily of **two types**:

* **A. Default Variables provided by GitHub**
* **B. Custom Variables created by users**


---

#### A. Default Variables Provided by GitHub

GitHub automatically provides multiple built-in environment variables inside every workflow run. These variables are automatically available to every step running on the runner machine.

Common examples:

```bash id="f4m8ks"
$GITHUB_EVENT_NAME
$GITHUB_REF
$GITHUB_SHA
$GITHUB_ACTOR
$RUNNER_OS
```

These variables provide information about workflow events, branch information, commit details, repository details, and runner environment details.

Example usage:

```yaml id="t6m2qp"
run: |
  echo "Event Type: $GITHUB_EVENT_NAME"
  echo "Branch Name: $GITHUB_REF_NAME"
  echo "Runner OS: $RUNNER_OS"
```

> **Important:** Default environment variables exist only on the **runner machine** executing the job and are mainly used during **actual command execution**.

---

#### B. Custom Variables Created by Users

Apart from GitHub-provided variables, users can also define their own custom variables.

Custom variables can be created using **`env:`**, repository variables, organization variables, and environment-level variables.

Example:

```yaml id="m7q2pk"
env:
  APPLICATION_NAME: payment-service
  OWNER: CloudWithVarJosh
```

Usage:

```yaml id="x8q2pw"
run: |
  echo "Application: $APPLICATION_NAME"
  echo "Owner: $OWNER"
```

These variables are commonly used for reusable configuration values, environment-specific settings, application names, deployment configuration, and build configuration.

---

> **Security Warning:** Variables are not masked automatically in workflow logs. For sensitive information such as passwords, API keys, or tokens, always use **GitHub Secrets** instead of variables.

---

### 2. Contexts (`${{ }}` Syntax)

Concepts:
[GitHub Actions Contexts Concepts](https://docs.github.com/en/actions/concepts/workflows-and-actions/contexts)

Reference:
[GitHub Actions Contexts Documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts)


Contexts are evaluated by the **GitHub Actions workflow engine** and provide access to workflow-related information such as:

* **`github`** → workflow and repository information
* **`env`** → custom environment variables
* **`vars`** → repository/organization variables
* **`secrets`** → GitHub secrets
* **`runner`**, **`job`**, **`steps`**, and **`matrix`** → runner, job, step, and matrix strategy information

Contexts are commonly used for:

* `if:` conditions
* workflow orchestration
* matrix strategies
* reusable workflow configuration
* dynamic workflow execution logic

In this lecture, we are primarily using values from the **`github`** context.

Common examples:

```yaml id="x8q2pw"
${{ github.event_name }}
${{ github.ref }}
${{ github.sha }}
${{ github.actor }}
```

Example usage:

```yaml id="m7q2pk"
if: ${{ github.event_name == 'push' }}
```

> **Important:** Contexts can often be evaluated **before the job is even sent to the runner**, which is why they are heavily used for workflow execution control and orchestration logic.

> **Practical Note:** You will often notice that contexts are also used inside runner commands because GitHub automatically exposes many context values as variables as well. Due to this overlap, both approaches may sometimes appear interchangeable.
>
> As a general rule of thumb:
>
> * use **variables (`$VARIABLE`)** inside shell commands and scripts whenever possible
> * use **contexts and expressions (`${{ }}`)** for workflow logic, conditions, orchestration, and dynamic evaluation
>
> If a value is only available through a context, then expressions must be used.


---

### 3. Expressions (`${{ }}`)

Official Documentation:
[GitHub Actions Expressions Documentation](https://docs.github.com/en/actions/learn-github-actions/expressions?utm_source=chatgpt.com)

Expressions allow GitHub Actions to perform **dynamic evaluation**, **conditional logic**, and **runtime decision-making** inside workflows.

Expressions use the following syntax:

```yaml id="m8q2zk"
${{ <expression> }}
```

Expressions are commonly used for:

* `if:` conditions
* branch-based execution
* dynamic variable evaluation
* matrix logic
* workflow orchestration
* function evaluation

Examples:

```yaml id="x4n7pl"
${{ github.event_name }}
${{ github.ref == 'refs/heads/main' }}
${{ startsWith(github.ref_name, 'feature/') }}
${{ runner.os }}
```

Example usage:

```yaml id="f5m2qp"
if: ${{ github.event_name == 'push' }}
```

In the above example:

* `github.event_name` is a **context value**
* `== 'push'` is the **conditional logic**
* `${{ }}` represents the **expression syntax**

GitHub Actions also provides multiple built-in expression functions such as:

* `startsWith()`
* `contains()`
* `endsWith()`
* `success()`
* `failure()`
* `always()`

Example:

```yaml id="u7n2pk"
if: ${{ startsWith(github.ref_name, 'feature/') }}
```

This condition executes the job only if the branch name starts with:

```text id="h8m2pl"
feature/
```

> **Important:** Expressions are evaluated by the **GitHub Actions workflow engine**, often before the job is even sent to the runner. This makes them extremely important for workflow orchestration and conditional execution logic.

---

### Determining When to Use Variables, Contexts, and Expressions

GitHub Actions provides **variables**, **contexts**, and **expressions**, but they are intended to be used at different stages of workflow execution.

* **Variables (`$VARIABLE`)** are mainly used inside the **runner during actual command execution**
* **Contexts (`github.*`, `runner.*`, etc.)** are mainly used for accessing workflow-related metadata and information
* **Expressions (`${{ }}`)** are mainly used for workflow logic, conditions, orchestration, and execution control

The most important difference is:

* **Contexts and expressions** can often be evaluated even before the job reaches the runner
* **Variables** become available only after the runner starts executing the job

This distinction becomes extremely important while working with:

* `if:` conditions
* workflow orchestration
* dynamic job execution
* runtime shell commands

Example:

```yaml id="j2r7mk"
name: Contexts vs Variables Demo

on:
  push:

jobs:
  prod-check:
    if: ${{ github.ref == 'refs/heads/main' }}

    runs-on: ubuntu-latest

    steps:
      - name: Print Workflow Information
        run: |
          echo "Event Name: $GITHUB_EVENT_NAME"
          echo "Branch Name: $GITHUB_REF_NAME"
```

In the above workflow:

* `github.ref` is a **context property**
* `${{ github.ref == 'refs/heads/main' }}` is an **expression** that checks whether the workflow was triggered from the **`main`** branch
* this expression is evaluated first by the **GitHub Actions workflow engine**
* the job is sent to the runner only if the condition evaluates to `true`
* once the runner starts executing the job, variables such as `$GITHUB_EVENT_NAME` and `$GITHUB_REF_NAME` become available inside the shell environment
* if the workflow runs from **`main`**, the job executes successfully
* if the workflow runs from **`feature/login`**, the job gets skipped completely before reaching the runner

This demonstrates one of the most common real-world GitHub Actions patterns where:

* **contexts** provide workflow-related information
* **expressions** control workflow execution logic
* **variables** are used during runtime command execution and scripting

> **Production Recommendation:** A simple way to think about this is:
>
> * **Variables (`$VARIABLE`)** → mainly used during runtime command execution inside the runner
> * **Contexts (`github.*`)** → mainly used for accessing workflow-related metadata
> * **Expressions (`${{ }}`)** → mainly used for conditions, orchestration, and execution control
>
> In real-world GitHub Actions workflows, all three approaches are commonly used together.


---

## Demo: Understanding Variables, Contexts, and Expressions in GitHub Actions

In this demo, we will understand how **variables**, **contexts**, and **expressions** work together inside GitHub Actions workflows.

We will specifically learn:

* default variables provided by GitHub
* custom variables defined using `env:`
* context values such as `github.*` and `runner.*`
* expression evaluation using `${{ }}`
* conditional execution using `if:`
* difference between variables and contexts
* workflow behavior on `main` vs `feature/*` branches

---

### Step 1: Creating the Project Structure and Initializing Git

Run the following commands:

```bash id="m8q2zk"
# create the project directory
mkdir project-files

# move inside the project directory
cd project-files

# initialize a local git repository
git init

# ensure the primary branch is named main
git branch -M main

# create the github actions workflow directory structure
mkdir -p .github/workflows
```

At this stage:

* a local Git repository gets initialized
* the primary branch becomes:

  * `main`
* the GitHub Actions workflow directory structure gets created successfully


---

### Step 2: Create the Workflow File

Create the following workflow file:

```text id="h8m2pl"
.github/workflows/02-expressions-variables-contexts-demo.yaml
```

Add the following workflow configuration:

```yaml id="p7m2qa"
name: 02 - Expressions Variables Contexts Demo

on:
  push:
    branches:
      - main
      - feature/*

env:
  APPLICATION_NAME: payment-service
  DEPLOYMENT_ENVIRONMENT: production
  AWS_REGION: ap-south-1

jobs:
  demo-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print Variables Contexts and Expressions
        run: |
          echo "========== DEFAULT VARIABLES =========="
          echo "Event Name: $GITHUB_EVENT_NAME"
          echo "Branch Name: $GITHUB_REF_NAME"
          echo "Commit SHA: $GITHUB_SHA"
          echo "Runner OS: $RUNNER_OS"

          echo ""

          echo "========== CUSTOM VARIABLES =========="
          echo "Application Name: $APPLICATION_NAME"
          echo "Deployment Environment: $DEPLOYMENT_ENVIRONMENT"
          echo "AWS Region: $AWS_REGION"

          echo ""

          echo "========== CONTEXT VALUES =========="
          echo "Repository: ${{ github.repository }}"
          echo "Actor: ${{ github.actor }}"
          echo "Workflow: ${{ github.workflow }}"
          echo "Runner OS Context: ${{ runner.os }}"

          echo ""

          echo "========== CONTEXT VS VARIABLES =========="
          echo "Context Ref: ${{ github.ref }}"
          echo "Variable Ref: $GITHUB_REF"

          echo ""

          echo "========== EXPRESSION EVALUATION =========="
          echo "Is Main Branch: ${{ github.ref == 'refs/heads/main' }}"
          echo "Is Feature Branch: ${{ startsWith(github.ref_name, 'feature/') }}"

      - name: Demonstrate Feature Branch Condition
        if: ${{ startsWith(github.ref_name, 'feature/') }}
        run: |
          echo "Feature branch detected successfully"

      - name: Demonstrate Main Branch Condition
        if: ${{ github.ref == 'refs/heads/main' }}
        run: |
          echo "Main branch deployment logic triggered"
```

#### Explanation

This workflow demonstrates several extremely important GitHub Actions concepts working together.

* the workflow uses multiple **default variables provided by GitHub** such as:

  * `$GITHUB_EVENT_NAME`
  * `$GITHUB_REF_NAME`
  * `$GITHUB_SHA`
  * `$RUNNER_OS`

  These variables become automatically available inside the runner during workflow execution and provide information about workflow events, branches, commits, and runner details.

* the workflow also defines multiple **custom variables** using:

  ```yaml id="m7q2pk"
  env:
  ```

  Example:

  ```yaml id="x8q2pw"
  env:
    APPLICATION_NAME: payment-service
    DEPLOYMENT_ENVIRONMENT: production
    AWS_REGION: ap-south-1
  ```

  These variables help centralize reusable configuration values that can later be accessed inside runner commands using:

  ```bash id="j2r7mk"
  $APPLICATION_NAME
  $DEPLOYMENT_ENVIRONMENT
  $AWS_REGION
  ```

* the workflow uses multiple **GitHub contexts** such as:

  ```yaml id="v7m5qa"
  ${{ github.repository }}
  ${{ github.actor }}
  ${{ github.workflow }}
  ${{ runner.os }}
  ```

  These contexts provide workflow-related metadata such as repository details, workflow details, actor information, and runner information.

* the workflow uses **expressions** for dynamic evaluation and conditional logic.

  Example:

  ```yaml id="q9w2ls"
  ${{ github.ref == 'refs/heads/main' }}
  ```

  This expression checks whether the workflow is currently running from the `main` branch.

  Another example:

  ```yaml id="w3n8pl"
  ${{ startsWith(github.ref_name, 'feature/') }}
  ```

  This expression checks whether the branch name starts with:

  ```text id="f5m2qp"
  feature/
  ```

* the workflow uses:

  ```yaml id="k5x9zb"
  if:
  ```

  for **conditional workflow execution**.

  Example:

  ```yaml id="a8v2pk"
  if: ${{ github.ref == 'refs/heads/main' }}
  ```

  This step executes only if the workflow runs from the `main` branch.

  Similarly:

  ```yaml id="b4n7qx"
  if: ${{ startsWith(github.ref_name, 'feature/') }}
  ```

  executes only for feature branches.

* this demonstrates one of the most important real-world GitHub Actions capabilities where workflows dynamically change behavior based on:

  * branch
  * event
  * environment
  * runtime conditions

* this type of conditional execution is heavily used in production CI/CD pipelines for:

  * production deployments
  * feature validation
  * branch-specific testing
  * release orchestration
  * environment-based automation


---

### Step 3: Adding Remote Repository, Committing, and Pushing Changes

Run the following commands:

```bash id="w24w6y"
# connect the local repository to the remote github repository
git remote add origin git@github.com:<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>.git

# add all changes to the staging area
git add .

# create a commit for the workflow changes
git commit -m "feat: add variables contexts expressions demo"

# push the local main branch to github
git push -u origin main
```

Ensure:

* the GitHub repository already exists
* authentication with GitHub is configured properly

The `-u` flag creates an upstream tracking relationship between the local and remote branch so future pushes and pulls can work without repeatedly specifying the branch name.

Since the workflow contains:

```yaml id="q8m2pk"
on:
  push:
    branches:
      - main
      - feature/*
```

the workflow executes automatically because:

* a valid `push` event occurred
* the push targeted the:

  * `main`
    branch
* all configured workflow trigger conditions were satisfied successfully


---

### Step 4: Observe Workflow Execution

Navigate to the **GitHub Actions** tab and open the workflow logs.

Observe the following sections:

```text id="49zkmn"
========== DEFAULT VARIABLES ==========
========== CUSTOM VARIABLES ==========
========== CONTEXT VALUES ==========
========== CONTEXT VS VARIABLES ==========
========== EXPRESSION EVALUATION ==========
```

This demonstrates:

* default variables provided by GitHub
* custom variables created using `env:`
* context values accessed using `${{ }}`
* overlap between contexts and variables
* expression evaluation results

You should also observe:

```text id="ghxb2c"
Is Main Branch: true
```

and:

```text id="oklmys"
Is Feature Branch: false
```

because the workflow currently runs from the `main` branch.

You will also observe:

```text id="h8eddo"
Main branch deployment logic triggered
```

because this step contains:

```yaml id="s7m2pk"
if: ${{ github.ref == 'refs/heads/main' }}
```

The following step will be skipped:

```text id="u4v5sq"
Demonstrate Feature Branch Condition
```

because the workflow is not running from a `feature/*` branch.

---

## Conclusion

In this lecture, we deeply explored how GitHub Actions controls workflow execution using **event filters**, **activity types**, **variables**, **contexts**, **expressions**, and **conditional execution logic**.

We validated multiple real-world workflow execution scenarios including:

* branch-based and path-based filtering
* pull request activity types
* synchronize behavior
* multiple workflow executions
* workflow engine vs runner evaluation
* context vs variable behavior
* expression-based execution control

These concepts become extremely important in production environments because modern CI/CD pipelines rely heavily on precise workflow execution control to optimize costs, reduce unnecessary workflow executions, improve runner utilization, accelerate feedback cycles, and build scalable automation systems.

The concepts covered in this lecture form the foundation for advanced GitHub Actions topics such as:

* reusable workflows
* matrix strategies
* deployment pipelines
* release automation
* environment-based orchestration
* production-grade CI/CD architectures

---

## References

### GitHub Official Documentation

* [GitHub Actions Workflow Syntax Documentation](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions?utm_source=chatgpt.com)
* [GitHub Actions Events Documentation](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows?utm_source=chatgpt.com)
* [GitHub Actions Variables Concepts](https://docs.github.com/en/actions/concepts/workflows-and-actions/variables?utm_source=chatgpt.com)
* [GitHub Actions Variables Documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/variables?utm_source=chatgpt.com)
* [GitHub Actions Contexts Concepts](https://docs.github.com/en/actions/concepts/workflows-and-actions/contexts?utm_source=chatgpt.com)
* [GitHub Actions Contexts Documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts?utm_source=chatgpt.com)
* [GitHub Actions Expressions Documentation](https://docs.github.com/en/actions/learn-github-actions/expressions?utm_source=chatgpt.com)
* [GitHub Actions Multiple Events Documentation](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions?utm_source=chatgpt.com#using-activity-types-and-filters-with-multiple-events)
