---
title: "My Agent-Ready Repository: What the Agent Needs to Know Before Coding"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Before coding, an agent needs to know where to work, which rules have authority, how to validate the change, and when to stop. This is the minimum contract for an agent-ready repository.
---

# My Agent-Ready Repository: What the Agent Needs to Know Before Coding { .article-title }

Before coding, an agent needs to know where to work, what to reuse, which boundaries to respect, how to validate the change, and when to stop. An agent-ready repository makes those answers visible to humans, actionable by the agent, and verifiable by the workflow.
{ .article-lead }

<p class="article-meta">
  <span>By <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

A coding agent should not work inside an isolated conversation. It should work within a system that guides it, constrains it, and makes its work reviewable. That was the argument of the [previous article](../ai-agent-based-coding-best-practices/index.md). Here, the question is more concrete: **what must the repository contain before the agent changes a single line of code?**

Consider a seemingly local request: improve the empty state in a customer directory. The agent finds a shared UI primitive, modifies it, adds the requested button, and gets the tests to pass. Functionally, the result looks correct. Yet a product request has just caused a change to the foundation shared by the entire application.

The problem is not that the agent failed to understand the code. It failed to understand the authority attached to different parts of the codebase.

An experienced developer often knows these boundaries without having to read them. They know which directories contain product code, which primitives are shared, which files are generated, which commands are authoritative, and which changes require an architecture discussion. An agent does not have that implicit memory.

> An agent-ready repository does more than give the agent context. It gives the agent operating boundaries that the workflow can compare against the changes actually produced.

These principles can be implemented in a framework that prepares the agent's context and controls parts of its execution. The examples below show one way to make that contract observable.

## The repository should answer before the agent has to

Exploring the code is part of the job. The agent should look for existing components, read local conventions, and understand the area it is about to change. But that exploration should not turn every task into an investigation of the project's fundamental rules.

Before acting, the agent should be able to answer seven questions quickly:

1. What observable outcome is required?
2. Where is the relevant product code?
3. Which existing components, contracts, or patterns should be reused?
4. Which paths may it modify for this task?
5. Which paths may it inspect but not modify?
6. Which validations must be run?
7. Under which conditions should it stop and request a decision?

These answers should not depend on one person's memory or remain buried in an old code review. They should live in the repository and be stable enough for a human, an agent, and a workflow to find them.

That does not mean putting everything into one enormous instruction file. An architecture rule, an instruction for the agent, a path policy, and a validation result serve different purposes. Conflating them produces either bloated documentation or opaque automation.

## One rule, four forms

A critical rule is more effective when it is expressed through four complementary forms.

| Form | Purpose | Limitation |
| --- | --- | --- |
| Human documentation | Explains the architecture, ownership, and rationale behind a decision | It informs, but does not prevent changes |
| Agent instructions | Guide the agent while it explores, plans, and codes | They are still interpreted by the model |
| Task contract | Declares the scope, validations, and stop conditions precisely | Without enforcement, it is only structured intent |
| Workflow checks | Compare observed facts with the contract and record the results | They prove only what they actually observed |

Consider the rule: "a product task must not modify the shared foundation."

The documentation explains why this separation exists. The instruction file tells the agent to prefer a local extension. The task contract identifies writable paths and read-only areas. Finally, the workflow inspects the diff and reports whether a protected area was touched.

If the rule exists only in a developer's head, it is invisible. If it exists only in documentation, it remains a recommendation. If it is declared in a contract but never checked, it remains a theoretical policy.

> A useful rule must be understandable by humans, actionable by the agent, and verifiable by the workflow.

This distinction also prevents a common misunderstanding: an instruction is not a system-level permission. Telling the agent "do not modify this directory" does not remove its write access. A technical guarantee requires a clear account of which mechanism prevents or detects the modification.

## Make ownership visible

An agent that can see the entire repository should not necessarily have the same freedom to act everywhere. The project structure should make areas with different ownership visible.

| Conceptual area | What it contains | Default policy for a product task |
| --- | --- | --- |
| Product code | Business features, screens, APIs, and functional documentation | Writes allowed within the task's precise scope |
| Shared foundation | UI primitives, architecture, shared configuration, and cross-cutting contracts | Reads allowed; modifications handled as a separate change |
| Project tooling | Scripts, validation commands, generation, and development configuration | Out of scope by default; changes require an explicit request |
| Generated and control artifacts | Results, logs, evidence, and files produced by the workflow | Produced by the control mechanism; any alteration by the agent must be detected |

Directory names matter less than the policy they embody. Two projects can have very different trees while expressing the same separation.

The product area is not entirely open either. A task involving the customer directory does not automatically authorize changes to the checkout flow. Repository-level ownership defines the broad areas; the task contract then narrows the agent's authority to the scope it needs.

The shared foundation is not immutable. It must be able to evolve. But a foundation change affects rules and primitives that other features depend on. It therefore deserves explicit intent, an impact analysis, and broader validation. It should not appear as a quiet side effect of a product request.

The practical rule is simple:

> If the requirement can be satisfied in the product layer, it should not be solved by modifying the shared foundation.

This separation also protects control artifacts. The agent can explain what it believes it did, but it should not be the sole author of the files intended to attest that boundaries were respected or validations passed. Otherwise, it becomes both the executor and the record keeper for its own execution.

## An execution contract for a concrete task

The repository contract contains stable rules: ownership areas, protected paths, standard commands, and the validation policy. For each task, the plan or workflow derives a more narrowly scoped execution brief.

Here is a teaching example for adding server-side pagination to a customer directory. It shows the categories of information a framework can assemble before execution.

```yaml
# Conceptual example, independent of any tool.
objective: >-
  Add server-side pagination to the customer directory without modifying
  the application's shared primitives.

scope:
  writable:
    - "app/customers/**"
    - "api/customers/**"
  read_only:
    - "shared/ui/**"
    - "platform/routing/**"
  out_of_scope:
    - "tooling/**"
    - "generated/**"

acceptance_criteria:
  - "The API response exposes the current page and the total result count."
  - "The interface handles loading, empty, and error states."
  - "Changing pages loads the corresponding data."

validations:
  - "make test"
  - "make build"

post_execution_checks:
  - "Compare the paths actually modified with the declared scope."

stop_if:
  - "A new dependency is required."
  - "The solution introduces a breaking change to the public API contract."
  - "The solution requires a change to the shared foundation."
```

The objective prevents the request from being confused with one particular solution. The acceptance criteria make the outcome observable. The `writable` paths define write authority. The `read_only` paths provide necessary context without authorizing modifications. The `out_of_scope` paths are not needed for the task and must not be touched.

The validations state which commands must be run. The post-execution check separately compares the files actually modified with the declared scope. Finally, the stop conditions make explicit which decisions the agent is not authorized to make on its own.

An execution brief like this should not be written entirely by hand for every micro-task. Stable rules come from the repository; the execution brief contextualizes them for the task at hand. What matters is that the agent receives an objective, a scope, references, validations, and boundaries appropriate to the task.

## An instruction file is an entry point

A file such as `AGENTS.md` remains useful, provided it is not expected to carry the entire method.

Its first purpose is navigation: which documents to read, where the architecture rules live, which commands are stable, and which changes require a stop. It can also repeat a few critical rules, such as not modifying generated files or not introducing a dependency without approval.

It should not duplicate the entire architecture, every edge case, and every policy for every subsystem. The more content it accumulates, the more important rules are diluted and the more likely duplicated guidance is to drift.

The entry point links to stable documentation, the repository contract, and the execution brief; the checks remain separate. The repository does not ask the agent to memorize everything. It allows the agent to retrieve the right information at the right time.

## What the workflow can actually verify

After execution, the workflow can compare the contract with several observable facts.

| Contract element | Possible observation | Legitimate conclusion |
| --- | --- | --- |
| Path scope | Files included in the declared observation scope | The observed files are or are not within the declared scope |
| Validations | Command run, exit code, and recorded output | This command returned this result in this local environment |
| Expected validations | Presence or absence of a result | A validation ran, failed, or was not run |

Wording matters. A zero exit code does not mean "the software is correct." It means the recorded command completed successfully. A successful path check does not mean the agent was technically unable to write elsewhere. It means that no file included in the declared observation fell outside the scope.

The report must therefore state what the observation covers, including whether the Git index and untracked files are included. In a typical local workflow, path checks happen after the write. They can block acceptance of the result or trigger another attempt, but they do not provide process isolation. Likewise, if the Git working tree already contained changes, the workflow must identify them or acknowledge that it cannot attribute every line to the current execution.

> The workflow establishes facts about an execution. It does not, by itself, establish that the software is correct.

This restraint makes the evidence more useful, not less. A human reviewer can make a better-supported decision when they know exactly what was observed, what was not, and which validations are still missing.

## When the agent should stop

Return to the customer directory's empty state. Suppose the shared component does not provide the extension point required for the requested action. The task allows changes to the feature but treats the shared primitives as read-only.

The agent should neither expand its scope silently nor work around the rule by duplicating the entire primitive without considering the consequences. It should produce a useful stop report:

> - **Finding:** the shared component does not provide the required extension point.
> - **Boundary:** modifying it falls outside the authorized scope.
> - **Options:** create a local variant in product code, or open a separate shared-foundation change.
> - **Decision required:** choose between the local solution and the cross-cutting change.

This stop is not an agent failure. It shows that the repository has made a governance choice visible. The original request does not automatically grant authority to modify every layer needed for the most direct solution.

Typical stop conditions include:

- an unresolved product decision;
- a migration or contract incompatibility;
- a new dependency;
- a security or authorization change;
- a change to the shared foundation or tooling;
- a required validation that cannot run without changing the environment or expanding the scope.

In these situations, the agent's best contribution is not always more code. Sometimes it is a precise finding, understandable options, and a clear point from which to resume.

## What this setup does not guarantee

An agent-ready repository reduces ambiguity and makes certain kinds of drift visible. It does not make an agent's execution inherently safe.

In particular:

- instructions do not replace system-level permissions;
- a post-hoc diff check is not process isolation;
- staying within the allowed paths does not rule out a semantic error in an authorized area;
- passing tests do not prove that coverage is sufficient;
- local evidence does not automatically bind the result to a commit or a CI run;
- in this setup, automation alone does not establish that the residual risk is acceptable.

The term "agent-ready" therefore does not mean "autonomous agent." It means that the repository provides an explicit working environment, the workflow can observe compliance with some of its rules, and humans retain a factual basis for deciding.

## Checklist: make your repository agent-ready

There is no need to build a complete orchestrator immediately. A team can prepare its repository incrementally.

- ☐ Create a short entry point for agents.
- ☐ Document the architecture and the patterns to reuse.
- ☐ Clearly distinguish product code, the shared foundation, and tooling.
- ☐ Identify generated files and artifacts the agent must not modify.
- ☐ Standardize test, build, and architecture-check commands.
- ☐ Define writable and read-only paths for each task.
- ☐ Write down the conditions that should trigger a stop and a human decision.
- ☐ Inspect the actual diff instead of trusting the agent's declared file list.
- ☐ Record which validations ran, their results, and which validations are missing.
- ☐ Name the person responsible for the final decision.

The first objective is not to automate all ten items. It is to make the rules visible and remove the most expensive ambiguities. Automation comes next, starting where a rule can be compared with an observable fact.

## Conclusion

Before coding, an agent needs to know more than the request. It needs to know which part of the system it is working in, which rules have authority, which context it may inspect, which validations will be expected, and which decisions are not for it to make.

An agent-ready repository makes this operating model durable. The documentation explains. The instructions guide. The contract bounds the task. The workflow observes the result. Humans decide whether the resulting facts are sufficient.

Once that foundation is in place, another question arises: should a copy change, an end-to-end feature, and a shared-foundation change all receive the same level of control?

That is the subject of the next article: [**four modes and two paths for choosing the right level of control**](../agent-coding-modes/index.md).

<div class="article-footer-contact">
  <p>To discuss this article or leave me a public message:</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message on GitHub</a>
</div>
