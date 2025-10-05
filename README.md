# WTFB SAFe-Agentic-Workflow Template

This repository provides a comprehensive template for establishing a sophisticated human-AI collaborative development workflow, inspired by the Words To Film By (WTFB) project. It embodies principles of Evidence-Based Delivery, Pattern-Driven Development, and a Spec-Driven Workflow, all structured around a SAFe Agile Release Train (ART) model.

## 🚀 Quick Start

To integrate this workflow into your new or existing project, follow these steps:

1. **Navigate to your project's root directory.**

    ```bash
    cd /path/to/your/project
    ```

2. **Run the `apply-workflow.sh` script.**

    ```bash
    # First, clone this template repository to a temporary location
    git clone https://github.com/ByBren-LLC/WTFB-SAFe-Agentic-Workflow.git /tmp/wtfb-workflow-template

    # Then, run the script from your project's root
    bash /tmp/wtfb-workflow-template/apply-workflow.sh
    ```

3. **Follow the interactive prompts.** The script will ask you to choose your AI agent provider (Claude Code or Augment) and provide project-specific details (e.g., ticket prefix, primary development branch).

4. **Complete Post-Setup Steps.** The script will guide you through any final manual steps, such as configuring GitHub secrets or reviewing provider-specific guides.

## ✨ Core Philosophy

This template enables a highly-structured, quality-focused, and efficient development process for a hybrid team of human and AI agents, built on:

* **Evidence-Based Delivery:** All work produces verifiable evidence (test results, session IDs) attached to project management tickets.
* **Pattern-Driven Development:** Mandatory reuse of pre-approved patterns for common tasks, enforcing consistency and accelerating development.
* **Spec-Driven Workflow:** Detailed, version-controlled `spec.md` files serve as the unambiguous source of truth for all implementation.
* **SAFe ART Model:** A team of 11 specialized AI agents, each with a distinct role, toolset, and recommended AI model, mimicking a real-world Agile Release Train.

## 🤖 AI Agent Provider Support

This template is designed to support multiple AI agent providers:

### 1. Claude Code (Primary, Automated Path)

* **Experience:** Fully automated, out-of-the-box setup.
* **Features:** Includes 11 pre-configured agent prompts, automated runtime hooks (for pattern reminders, RLS validation, Linear updates), and a master security policy.
* **Ideal for:** Teams using the Claude Code VS Code extension who want maximum automation.

### 2. Augment (Guided Starter Kit)

* **Experience:** A well-supported starting point with clear guidance for manual integration.
* **Features:** Includes pre-translated agent prompts (`instructions.md`, `rules/`) adapted from the Claude Code format, providing a functional base for Augment agents.
* **Guidance:** A detailed `AUGMENT_WORKFLOW_GUIDE.md` explains the automation gaps (e.g., no automated hooks) and provides manual alternatives, ensuring compliance with the workflow principles.
* **Ideal for:** Teams using the Augment CLI who want to integrate their agents into this structured workflow.

## 📂 Template Structure Overview

```
/your-project/
├── 📄 README.md                 # This file.
├── 📄 apply-workflow.sh         # Script to install the workflow.
│
├── 📂 .claude/                   # OR .augment/ (depending on choice)
│   ├── 📂 agents/                 # Agent prompts/instructions.
│   ├── 📂 hooks/                   # Automated scripts for Claude Code.
│   └── 📂 permissions/             # Tool access policies.
│
├── 📂 project_workflow/          # Core Git, CI/CD, and contribution guidelines.
│   ├── 📄 CONTRIBUTING.md
│   ├── 📂 .github/
│   └── 📂 scripts/
│
├── 📂 patterns_library/         # Reusable code patterns and solutions.
│   ├── 📄 README.md
│   └── ...
│
├── 📂 specs_templates/          # Templates for planning and specification documents.
│   ├── 📄 README.md
│   └── ...
│
└── 📂 linting_configs/          # Code quality and formatting configurations.
    └── ...
```

## 📚 Further Documentation

For a deeper dive into the philosophy, architecture, and implementation details of this workflow, please refer to the comprehensive documentation in our Confluence space:

* **[Blueprint for the WTFB SAFe-Agentic-Workflow Template](https://cheddarfox.atlassian.net/wiki/spaces/WA/pages/366444595/Blueprint+for+the+WTFB+SAFe-Agentic-Workflow+Template)** (Parent Page)
  * [Core Philosophy & Workflow](https://cheddarfox.atlassian.net/wiki/spaces/WA/pages/366411879/Core+Philosophy+Workflow)
  * [The Agent System](https://cheddarfox.atlassian.net/wiki/spaces/WA/pages/366510166/The+Agent+System)
  * [The Pattern Library](https://cheddarfox.atlassian.net/wiki/spaces/WA/pages/366510186/The+Pattern+Library)
  * [The Spec-Driven Workflow](https://cheddarfox.atlassian.net/wiki/spaces/WA/pages/366411898/The+Spec-Driven+Workflow)
  * [Template Repository Architecture](https://cheddarfox.atlassian.net/wiki/spaces/WA/pages/366411918/Template+Repository+Architecture)
  * [Implementation & Rollout Plan](https://cheddarfox.atlassian.net/wiki/spaces/WA/pages/366444615/Implementation+Rollout+Plan)

---

_Co-authored by Gemini (Google) and Auggie (ARCHitect-in-the-IDE)_
