# Vibe Coding Workshop

**Practical AI Workflows for Developers**

---

## 1. Workshop Overview

### Objective

This workshop teaches developers how to collaborate effectively with agentic coding systems in order to:

* Scaffold projects faster
* Explore architectural ideas rapidly
* Refactor and debug systematically
* Iterate toward cleaner architectures
* Maintain control over quality, security, and technical decisions

The goal is not automation without oversight — it is accelerated engineering with retained architectural sovereignty.

---

## 2. What Is Vibe Coding?

**Vibe Coding** is a paradigm shift in software development:

Instead of manually implementing every detail, the developer orchestrates multiple AI-powered tools inside a unified coding interface (e.g., TUI/IDE integration).

The developer remains:

* Architect
* Reviewer
* Decision-maker
* Quality gate

The agent becomes:

* Analyst
* Draft writer
* Refactoring assistant
* Simulation engine
* Code generator

Vibe coding is not “AI writes code.”
It is **structured collaboration within an agentic loop**.

---

## 3. The Agentic Loop

Understanding the loop is essential.

### The Iterative Cycle

1. **Define intent** (goal, constraints, context)
2. **Agent proposes change / analysis**
3. **Evaluate output**
4. **Refine or redirect**
5. **Validate (tests, linting, review)**
6. **Commit or iterate**

This loop can be short (fix a bug) or long (full feature implementation).

### Key Principle

> Never skip evaluation.
> AI acceleration without validation increases technical debt.

---

## 4. Assessment of Agentic Coding Tools

Before using any tool in production, evaluate it along these dimensions:

### Technical Capabilities

* Tool calling support
* Context window size
* Codebase awareness
* Multi-file reasoning
* Structured output reliability

### Governance

* On-prem vs cloud
* Data retention policies
* Auditability
* Deterministic replay capability

### Engineering Fit

* Integration with CI/CD
* Diff-awareness
* Git integration
* Test generation quality

---

## 5. Local Inference vs Cloud Services

### Local Inference Engines

Advantages:

* Full data sovereignty
* Offline operation
* Custom fine-tuning
* Predictable cost

Challenges:

* Hardware requirements
* Setup complexity
* Model management

### Cloud Services

Advantages:

* High-quality frontier models
* Zero infrastructure setup
* Elastic scaling

Challenges:

* Cost unpredictability
* Data compliance
* Latency
* Vendor dependency

Workshop includes:

* Comparative evaluation
* Decision criteria for enterprise contexts

---

## 6. Configuring a Local Workflow (Example: OpenCode + Local Inference)

Practical segment:

* Connecting opencode to a local inference engine
* Configuring context limits
* Tool activation and chaining
* Git integration
* Structured output enforcement
* Logging and replay configuration

Participants will:

* Connect to a local model
* Execute analysis prompts
* Trigger tool calls
* Run iterative coding loops

---

# Practical Application Modules

The following sections define structured use cases for vibe coding.

---

# Module 1 — Analytical Tools: Understand Before Changing

The first rule of vibe coding:

> Analyze first. Modify second.

---

### 1. Debugging

**Goal:** Identify root causes and produce structured corrective proposals.

```
Identify the root cause of the performance degradation under high load.
Create a detailed error analysis including corrective suggestions.
```

---

### 2. Intelligent Search

**Goal:** Extract architectural knowledge from the codebase.

```
Find all implementations of user authentication in the project
and show their interaction with other components.
```

---

### 3. Code Analysis & Architecture Sketching

**Goal:** Understand system structure and weaknesses.

```
Analyze the codebase and create a system architecture sketch with components and their relationships
using a mermaid diagram. Identify potential security vulnerabilities and code quality issues.
```

---

### 4. CI/CD & Pre-Commit Integration

**Goal:** Use the agent as a quality pre-filter.

```
Perform a git diff and determine whether the changes introduce errors.
```

---

### 5. Design Pattern Recommendations

**Goal:** Improve structural quality based on context.

```
Provide best practices and suitable libraries for implementing the database integration.
```

---

### 6. Technology Evaluation

**Goal:** Make evidence-based technical decisions.

```
Conduct an assessment of time-series visualization libraries in Python
for the existing test data in the test/ directory.
```

---

# Module 2 — Quality and Governance Support

AI is not only a productivity accelerator — it is a governance amplifier.

---

### 1. Policy Enforcement

```
Review the entire codebase for violations of our coding guidelines and GDPR requirements.
Create a compliance report.
```

---

### 2. Security Threat Modeling

```
Create a threat model for the new payment system and identify potential attack vectors in the design.
```

---

### 3. Technical Debt Analysis

```
Assess the technical debt of the legacy module and prioritize refactoring measures
based on business impact.
```

---

# Module 3 — Code Generation & Structured Implementation

Generation without structure leads to chaos.
Generation inside a loop leads to acceleration.

---

### 1. Bug Fixing via Prompt

```
Fix the null pointer exception in the user loading workflow and document the solution for the ticketing system.
```

---

### 2. Documentation & Knowledge Generation

```
Automatically generate API documentation in Swagger format, code comments,
and an installation guide for the authentication module.
```

---

### 3. Test Case Generation

```
Generate comprehensive unit and integration tests for the existing order processing logic,
including edge cases.
```

---

### 4. Feature & User Story Implementation

```
Read the feature list from the ticketing system and identify three with the highest impact
on processing speed. Then implement these features.
```

---

### 5. Boilerplate Code Generation

```
Generate boilerplate for a new REST API module including database schema and
Docker deployment configuration.
```

---

# Module 4 — Innovation Acceleration

Vibe coding drastically reduces time-to-feedback.

---

### 1. Prototyping & Spike Development

```
Create a proof of concept for integrating AI-driven product recommendations into the shopping cart.
```

---

### 2. Feature Evolution

```
Extend the user profile page with social media integration
based on the attached protocol of potential features.
```

---

### 3. Rapid Performance Optimization

```
Identify suggestions for improving load times on the product page
and implement the most promising ones in a spike.
```

---

### 4. Entry Barrier Reduction

```
Explain how the existing database integration works
and generate an example implementation in Python.
```

---

### 5. Simulation & Scenario Modeling

```
Write a program to generate 10,000 test orders with different load profiles.
These should be executed in a script to evaluate the scalability of the order processing logic.
```

---

# Practical Workshop Flow (Suggested Agenda)

### Part 1 — Foundations (Theory + Discussion)

* What is vibe coding?
* The agentic loop
* Tool assessment framework
* Local vs cloud strategy

### Part 2 — Environment Setup (Hands-On)

* Configure local inference
* Connect opencode
* Run analytical prompts
* Validate structured outputs

### Part 3 — Guided Exercises

* Debugging session
* Architecture sketching
* Threat modeling
* Feature implementation loop

### Part 4 — Advanced Workflows

* Governance integration
* CI/CD automation
* Multi-step tool chaining
* Spike-driven innovation

---

# Final Principles

1. AI is an amplifier — not a replacement.
2. Analysis precedes modification.
3. Every generation step requires validation.
4. Governance is not optional.
5. The developer remains architect and final authority.

---

# Outcome of the Workshop

Participants will:

* Understand the agentic coding loop
* Evaluate AI tooling strategically
* Configure local inference setups
* Execute structured AI workflows
* Accelerate implementation without sacrificing quality

