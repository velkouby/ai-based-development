---
title: "From Brief to Local Review: An Agentic Feature, End to End"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Between a natural-language request and a pull request, a useful agentic path produces a chain of artifacts, checks, and local evidence. Let us follow a full-stack feature end to end.
---

# From Brief to Local Review: An Agentic Feature, End to End { .article-title }

Between "add pagination to the customer directory" and a pull request, there should not be a black box called "the agent coded it." A useful agentic path turns the request into bounded tasks, observes the execution, runs checks, and prepares a review that separates facts from claims.
{ .article-lead }

<p class="article-meta">
  <span>By <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

In the [previous article](../agent-coding-modes/index.md), the example of server-side pagination for the customer directory was classified as a **Structured Feature**. It affects the API, the interface, a response contract, and several interface states. The chosen path is therefore orchestrated.

That decision does not yet explain what happens between the brief and the review. In many workflows, this part remains confined to a conversation. By the end, the diff exists, but the chain of decisions that produced it has evaporated.

A durable workflow must produce more than a chat history. It must make it possible to reconstruct the execution without asking the agent to describe, after the fact, what it thinks it did.

> The agent produces a proposal. The workflow establishes observable facts. A human decides whether those facts are sufficient.

A framework that implements this method must make planning, context preparation, task tracking, path checks, validations, attempts, and the review summary explicit. The artifacts presented here show how such a framework can make the path inspectable.

## Step 1: turn the request into a brief

The raw request fits in one sentence:

> Add server-side pagination to the customer directory.

It expresses an intention, but not yet an execution contract. It specifies neither the shape of the API response, nor the initial page, nor the interface states, nor what must remain out of scope. Leaving the agent to resolve these questions alone would turn silence into product and technical decisions.

Here is a teaching example of a clarified brief. It defines the outcome without imposing the entire implementation:

```markdown
## Objective

Paginate the customer directory on the server and allow users
to navigate between pages from the interface.

## Included

- evolve the API response to include the current page and the total result count;
- load the first page when the directory opens;
- preserve the loading, empty, and error states;
- test boundary cases and page changes.

## Non-goals

- synchronize the page with the URL;
- modify a shared primitive;
- add a dependency;
- migrate or restructure existing data.

## Stop if

- the contract would become incompatible with an existing consumer;
- a product decision remains open;
- the solution requires a change to the shared foundation.
```

The brief does not try to predict every file. It stabilizes the intention, the observable criteria, and the decision authority. The non-goals matter as much as the objective: they prevent the most direct technical solution from silently redefining the request.

At this stage, we know **what is expected**. We do not yet know **how to implement it within the repository**, or which tasks can be entrusted to the agent separately.

## Step 2: compile an executable plan

An agentic plan is not a list of vague verbs such as "do the backend," "do the frontend," and "add the tests." It must produce units that can be selected, executed, checked, and resumed.

For our example, the breakdown might look like this:

| Task | Expected outcome | Depends on | Writable paths | Targeted validation |
| --- | --- | --- | --- | --- |
| T-01 | Paginate the API response and test its pagination edge cases | — | `backend/customers/**` | Customer API tests |
| T-02 | Adapt the client and interface while preserving the existing states | T-01 | `frontend/customers/**` | Directory tests |
| T-03 | Review the consistency of the contract and its integration before the workflow's independent checks | T-01, T-02 | No additional product-code changes expected | Project tests and build |


The plan adds what the brief should not carry: dependencies, writable paths, read-only references, validations, stop conditions, and evidence requirements. To become executable, it must contain a write-boundary matrix. The framework must also assign stable identifiers to tasks, check their dependencies, and validate their path policy before any execution.

An open question blocks the next step. It becomes an intervention to resolve; the answer is persisted and then passed to the next execution package. If it changes the breakdown, the scope, or another structural element, the plan must be recomputed before work resumes. The decision therefore does not disappear between planning and execution.

At the end of this step, we know one possible execution path. We still have no code, and that is a good thing: a scope inconsistency costs less to correct in a plan than in a full-stack diff.

## The end-to-end trace

The path can now be represented as a chain. Each link receives an input, produces an artifact, and adds a limited amount of knowledge.

<figure class="article-diagram">
  <img src="agentic-feature-evidence-chain.png" alt="End-to-end chain across Human, Workflow, and Agent lanes, from a raw request to reviewable evidence." loading="lazy" />
  <figcaption>Each link adds a limited fact; no single one proves that the feature is acceptable.</figcaption>
</figure>

| Link | Input | Persisted output | What we can then claim |
| --- | --- | --- | --- |
| Qualification | Raw request | Decision record | The selected level of control is explicit |
| Clarification | Request and human decisions | Brief | The intention, criteria, and non-goals are written down |
| Planning | Brief and repository rules | Plan and bounded tasks | The work is broken down and the boundaries are declared |
| Preparation | Brief, plan, contract, answers, and local state | Execution package | The runner receives a reconstructible execution brief |
| Implementation | Execution package | Structured runner result and diff | The agent reports what it attempted; the code has changed |
| Checks | Initial state, final state, and policies | Scope-check results | The observed paths comply with or violate the declared boundaries |
| Validations | Planned commands and working tree | Exit codes and outputs | These commands produced these results locally |
| Local evidence | Runner results, Git state, and check results | Attempt artifact | The execution becomes inspectable and resumable |
| Local review | Brief, plan, tasks, and evidence | Review summary | The useful facts are assembled before Git and CI |

This table is the heart of the path. No single step "proves the feature." Each one only changes the nature of the information available.

## Step 3: prepare what the runner receives

The plan has just broken the feature down into precise tasks. Each task describes an expected outcome, its dependencies, its relevant context, its write boundaries, and its validations. These tasks are units of planning, control, and review; they do not necessarily map to the same number of separate runner sessions.

When no blocking decision remains open, the workflow selects a **coherent block of tasks** whose dependencies can be honored during the same execution. It compiles this block into an execution package. For pagination, T-01, T-02, and T-03 form a coherent chain: evolve the backend contract, adapt the interface that consumes it, and then review their consistency before the workflow's independent checks.

```text
feature plan
  T-01 backend contract
    -> T-02 frontend integration
      -> T-03 consistency review

coherent block: [T-01, T-02, T-03]
  -> execution package loaded once
  -> one runner session
  -> one structured result for each task
```

The package brings together two levels of context:

- context shared across the block — brief, plan, human decisions, repository contract, and initial Git state;
- task-specific context — expected outcome, dependencies, writable paths, read-only references, validations, and stop conditions.

The runner loads this package once and executes the block as a whole. It can therefore reason about the continuity of the change, move from the backend contract to its frontend consumer, and retain the same technical decisions throughout the execution. The workflow avoids reloading the brief, the rules, and the same references for every micro-task.

This grouping reduces the number of separate runner sessions, amortizes the cost of preparing context, and allows the coding agent to use its planning capabilities on a coherent change spanning several files. Coding agents already know how to explore a codebase, sequence changes, and coordinate several surfaces when they receive a high-quality objective and context. The workflow therefore does not try to dictate every edit: it prepares a problem that is precise and bounded enough for the agent to organize the detailed implementation effectively.

> The workflow plans the work at the task level. The agent plans the implementation inside the package.

A package is therefore neither a single task nor necessarily the entire feature. A broader plan may produce several packages. The right package groups tasks that share an intention, dependencies, and context, without combining independent work into a diff that is difficult to control.

A framework that adopts this model must compile the package and require a distinct result for each task. But structure must not be confused with relevance: a well-formed package can still contain too much context, omit a decisive reference, or compile insufficiently clarified human intent.

We will open this package in the next article. For this end-to-end view, the key point is this: the runner does not receive only a prompt. It receives an ordered task block, its shared context, its task-specific constraints, and a starting state.

## Step 4: separate the agent's result from the workflow's facts

At the end of the package, the runner returns a structured result: overall status, summary, a result for each task, files it says it modified, questions, blockers, and warnings. The format is controlled. An incomplete response, or one that cannot be matched to the expected tasks, may cause the execution to fail before validations begin.

In this teaching example, suppose the runner reports:

```text
package status: completed
T-01: completed
T-02: completed
T-03: completed
changed files: five files in customer-related code areas
blockers: none
open questions: none
```

This result is useful for tracking, but it remains an **agent declaration**. The workflow must not use the reported list as its sole source of truth. After the package has run, it separately inspects the state of the working tree and compares the observed files with the authorized envelope for the package as a whole.

Without intermediate snapshots between T-01, T-02, and T-03, Git can establish which files changed during execution of the package, but not which task produced each modification. The attribution to individual tasks comes from the runner's structured result and therefore remains declarative. If that attribution must be established independently, the workflow needs to add checkpoints between tasks or execute them in separate packages.

The distinction is essential: "the agent says it modified five files" and "the workflow observed five modified paths" are two different statements. If the lists diverge, the divergence itself must become a fact for review.

## Steps 5 and 6: check before validating

In this model, the order of the gates is decisive: planned validations must be run only if the runner has finished, its execution trace exists, all expected results are present and complete, and the boundary and path-policy checks pass.

The order matters. Running tests before inspecting the scope can produce a misleading green result: the code may work because the agent modified a primitive it was not allowed to touch.

The attempt log might then record:

| Check | Result | Legitimate interpretation |
| --- | --- | --- |
| Expected runner results | Present for all three tasks | The package's output contract is complete |
| Files changed during execution | Five product-code paths | These five paths differ between the selected initial and final snapshots |
| Package boundaries | Passed | No observed path falls outside the package's authorized envelope |
| Customer API tests | Exit code 0 | This command succeeded in the local environment |
| Directory tests | Exit code 0 | This command succeeded in the local environment |
| Project build | Exit code 0 | The requested build completed successfully |
| Global quality check | Not run in this execution | No conclusion can be drawn about this check |

The final result must be reported just as prominently as the green results. In this model, the validations declared for the tasks are orchestrated after the scope checks, while the global quality profile remains a separate step that must be started explicitly. Until it has been run, presenting it as implicitly successful would be false.

Path checks run after changes have been written and do not constitute a sandbox: they characterize a scope violation, not the general security of the process. The article about stopping will examine this limitation in detail.

## Step 7: write local evidence

After execution and checks, the workflow must retain an artifact for the package attempt. Here is a teaching example of a manifest:

```yaml
attempt:
  id: "illustrative-run-01"
  agent_result: "completed"
  expected_tasks: [T-01, T-02, T-03]
  received_results: [T-01, T-02, T-03]

local_git:
  initial_state: "snapshot"
  final_state: "snapshot"
  files_changed_during_execution: 5

checks:
  boundaries: "passed"
  path_policy: "compliant"
  targeted_validations: "3 of 3 passed"
  global_quality: "not_run"

limitations:
  - "local evidence, not immutably bound to a commit"
  - "test coverage not evaluated automatically"
  - "business acceptance still requires a human"
```

This manifest shows the information a framework should retain: the runner result, tracking information, local Git state, files changed during execution, boundary checks, validation results, failures, and a few basic metrics.

This evidence makes the attempt inspectable. It does not automatically make it attributable to a specific revision. Initial and final states help distinguish what changed during execution, but they do not replace commit identifiers for the base and head commits, a comprehensive snapshot of the index, or full environment identification. An already modified working tree remains a source of ambiguity that must be reported.

## Step 8: prepare the review without making the decision

The local review should bring together the brief, the executed plan, the tasks and their status, the observed files, the attempts, the validations, the risks, and the remaining questions. The framework must refuse to finalize if a task remains incomplete or if required checks fail.

The summary must not flatten provenance, however. A statement such as "the tests pass" is too vague if it does not name the commands, where they ran, and the missing validations. Likewise, an agent-written summary can improve readability, but it must not replace the structured results from which it was derived.

At this stage, a person can answer the following questions without reopening the chat:

- what intention was clarified;
- which tasks were planned, made executable, and then executed;
- which areas were writable;
- which paths were observed;
- which commands were actually run;
- which limitations and questions remain open.

They must still review the diff, assess whether the choices are appropriate, compare the behavior with the acceptance criteria, and decide whether the residual risk is acceptable. Automation prepares the decision; it is not given the authority to make it.

## The local review is not yet the PR

The path described here deliberately stops before the commit, CI, and pull request. Local evidence concerns a working tree and an attempt. CI concerns a revision sent to a defined environment. The PR adds a discussion space, branch checks, and a merge decision.

These layers must be linked, not conflated:

```text
local evidence
  -> reviewed diff
  -> identified commit
  -> CI validations on that revision
  -> pull request
  -> human merge decision
```

The strongest **target** would explicitly link the attempt identity, base commit, head commit, index state, tool versions, local validations, CI results, and acceptance criteria. Until this information is actually produced and linked, that target must not be presented as achieved.

## Reproduce the protocol with your own tools

You do not need to adopt a particular framework to implement the essentials of this chain. A team can start with versioned files and a few stable scripts:

1. retain the raw request and write a brief with non-goals;
2. break the work down into tasks with dependencies, path boundaries, and validations;
3. record the Git state before handing the task to the agent;
4. require a structured result without treating it as independent evidence;
5. inspect the complete Git state: staged changes, unstaged changes, and untracked files;
6. refuse to run or accept validations if the scope has been violated;
7. record every command, its exit code, and what was not run;
8. produce a summary that retains risks and questions;
9. then link this trace to the commit and CI results.

The first benefit is the ability to resume work, explain a stop, and challenge a conclusion using persistent artifacts.

## Conclusion

An end-to-end agentic feature is not a longer conversation. It is a sequence of transformations: the request becomes a brief, the brief becomes a plan, the plan becomes an execution brief, the runner produces a proposal, the workflow observes the scope and validations, and then local evidence feeds the review.

For customer-directory pagination, this path makes the proposal reconstructible before Git and CI. It does not yet prove sufficient coverage, business correctness, or whether the change should be merged. Those decisions remain human.

The next step is to open the black box immediately before the runner: [**what the agent actually receives, and how to build a useful execution brief**](../agent-execution-package/index.md).

<div class="article-footer-contact">
  <p>To discuss this article or leave me a public message:</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message on GitHub</a>
</div>
