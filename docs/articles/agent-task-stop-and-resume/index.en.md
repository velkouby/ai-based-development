---
title: "When a Task Must Stop: Decisions, Boundaries, and Resumption"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  A frontend test fails after an implementation that stayed within scope. By following two concrete attempts, we can see when to repair, when to ask for a decision, and when to stop at a write boundary.
---

# When a Task Must Stop: Decisions, Boundaries, and Resumption { .article-title }

The pagination package produced the five expected files, the backend tests pass, and the frontend builds. Yet one test reveals that the “Next” button remains enabled on the last page. Should we start over, ask for a human decision, or repair the code locally? Let us follow the facts to the exact resumption point.
{ .article-lead }

<p class="article-meta">
  <span>By <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

In [the previous article](../agent-execution-package/index.md), the brief, the plan, the repository rules, and human decisions were compiled into an execution brief. The runner received a coherent block of three tasks: evolve the API, adapt the directory, and then check their consistency.

It is time to let that package run. The first attempt ends neither in complete success nor in disaster. It stops on a precise defect, inside an authorized area, with a test that can verify the correction.

This is the ideal case for understanding resumption. A simple “continue” would be too vague. Replaying the entire feature would waste work that is already done. Ignoring the red test would plainly be wrong. The workflow must classify the stop, preserve the first attempt, and construct a narrower second brief.

> Resuming does not mean starting over. It means continuing from the last known state with the same authority, a precise diagnosis, and checks that must run again.

<figure class="article-diagram">
  <img src="task-stop-resume-paths.png" alt="Timeline of customer pagination: a clean start at revision 7a31c42, attempt 001 stopped by the frontend test, attempt 002 limited to one file, and then local review, with two contrast branches for a missing human decision and a shared-routing scope violation." loading="lazy" />
  <figcaption>Attempt 002 resumes from the validation failure; a missing decision or a crossed boundary would require a different path.</figcaption>
</figure>

## The package starts from a known state

The starting point is not “roughly yesterday's repository.” The workflow records a precise state before launching the runner:

```yaml
start:
  branch: feature/customer-pagination
  revision: 7a31c42
  working_tree: clean

package:
  tasks: [T-01, T-02, T-03]
  writes_allowed:
    - backend/customers/**
    - frontend/customers/**
  read_only:
    - shared/routing/**
  non_goals:
    - synchronize the page with the URL
    - modify a shared primitive
```

This snapshot provides three useful reference points. The branch and revision identify the local base. The clean working tree prevents an earlier change from being confused with the runner's work. Finally, the package states that `shared/routing/**` may be consulted but not modified.

That does not turn the package into a sandbox. The process may still write to the wrong directory if the environment technically allows it. The boundaries describe the mission's authority; the path check will later determine whether the observed changes respected it.

## Attempt 001: five expected files, one red test

The runner executes the `T-01 → T-02 → T-03` block in one session and reports all three tasks as completed. The workflow does not treat that declaration as validation. It inspects Git first.

Five paths have changed since the starting snapshot:

```text
backend/customers/api.py
backend/customers/tests/test_pagination.py
frontend/customers/customer-api.ts
frontend/customers/customer-list.tsx
frontend/customers/customer-list.test.tsx
```

All five belong to the two authorized product areas. The write-boundary check passes. The three targeted commands can now run:

| Check | Exit code | Fact established |
| --- | ---: | --- |
| `make test-back` | `0` | The selected backend tests detected no failure |
| `make test-front` | `1` | At least one frontend scenario failed |
| `make build-front` | `0` | The requested frontend build completed without error |
| Global quality | Not run | No conclusion can be drawn about this check |

The useful detail appears in the output from `make test-front`:

```text
FAIL CustomerList > disables Next on the last page

Expected: disabled
Received: enabled
```

Pagination can load data and the application builds, but the user can still request a page beyond the last one. The two green commands do not compensate for this divergence from the expected behavior.

The attempt result must therefore remain explicit:

```yaml
attempt: "001"
runner_declared_result: completed
boundaries: passed
validations:
  "make test-back": passed
  "make test-front": failed
  "make build-front": passed
global_quality: not_run
status: needs_retry
```

This distinction matters. The runner completed what it believed it had to do. The workflow observed that the execution brief is not yet satisfied.

## Why this failure is repairable without a human decision

Before authorizing another attempt, we must examine the required correction, not only the color of the test.

Here, four facts are already known:

1. the expected outcome is explicit: “Next” must be disabled on the last page;
2. the failure is localized in `CustomerList` behavior;
3. the correction can remain within `frontend/customers/**`;
4. it requires no new dependency, contract change, or product decision.

One plausible cause is that the component identifies the last page from the visible items rather than using the total returned by the API. The correction can remain very small:

```diff
- disabled={items.length === 0}
+ disabled={page * pageSize >= total}
```

This diff is an implementation example, not the diagnosis by itself. The more general reason a retry is authorized is that the objective and authority remain unchanged, the defect has a reproducible validation signal, and the repair stays within the original scope.

This is a **repairable failure**. The agent may act within a bounded recovery policy. If the fix ultimately required a new product rule, a backend contract change, or a shared primitive, the category would have to change and the attempt would stop.

## The exact resumption point

The workflow does not tell the runner, “pagination is broken; try again.” It prepares resumption context from attempt 001:

```yaml
resumption:
  from_attempt: "001"
  from_gate: targeted_validation
  failed_check: "make test-front"

  diagnosis:
    test: "CustomerList > disables Next on the last page"
    expected: disabled
    observed: enabled

  repair_writes_allowed:
    - frontend/customers/customer-list.tsx

  preserved_state:
    - the diff produced by attempt 001
    - the existing brief and decisions
    - the original write boundaries
    - the outputs from validations that already ran

  validations_to_rerun:
    - "make test-back"
    - "make test-front"
    - "make build-front"
```

The resumption point is therefore the repair of the frontend outcome before the validation gate. The backend is not implemented again. The product plan is not recomputed. The working tree is not arbitrarily restored to `7a31c42`: it still contains the five files from attempt 001, one of which the next attempt will change again.

The three commands do run again. `make test-front` must verify the repaired defect. `make build-front` must establish that the change still builds. `make test-back` confirms that the targeted set selected for this package remains green. A team could choose a different set, but it must be written down before the resumption is presented as validated.

## Attempt 002: one repaired file, three green checks

The second attempt changes only:

```text
frontend/customers/customer-list.tsx
```

This list describes the **delta of attempt 002**. It does not replace the feature's overall diff, which still contains all five files observed after the first execution.

The write-boundary check runs again, and all three targeted commands then return `0`:

```yaml
attempt: "002"
derived_from: "001"
files_changed_during_repair:
  - frontend/customers/customer-list.tsx

boundaries: passed
validations:
  "make test-back": passed
  "make test-front": passed
  "make build-front": passed
global_quality: not_run
status: completed
```

The package can now proceed to local review. That status must not be translated as “the feature is correct” or “it is ready to merge.” We know that the five paths remain inside the authorized envelope and that the three targeted commands passed against the local state of attempt 002. We also know that the global quality check did not run.

Most importantly, the green attempt does not erase the red one:

| Attempt | Observed state | Change specific to the attempt | Outcome |
| --- | --- | --- | --- |
| `001` | Clean start at `7a31c42`, then five product files | Package implementation | `make test-front` failed, `needs_retry` |
| `002` | Diff from `001` preserved | `customer-list.tsx` | Three targeted validations passed |

This history explains why a correction was necessary and what was actually checked again.

## The same red test, but with a missing decision

The previous retry was legitimate because the word **disabled** already appeared in the expected behavior. Now imagine a less precise brief: “prevent the user from going beyond the last page.”

Two interfaces satisfy that sentence: hide the “Next” button, or keep it visible but disabled. The choice affects layout stability, the clarity of navigation, and accessibility behavior. An agent should not turn that silence into a design preference.

The workflow retains an intervention instead:

```markdown
# Intervention UI-01

Problem: the behavior of “Next” on the last page is undefined.

Options:
1. keep the button visible and disable it;
2. hide the button.

Required authority: product and design.
Affected elements: navigation criterion, T-02, and frontend test.
Resumption point: update the criterion and test, then recompile the repair.
```

Until an answer exists, another coding attempt would be premature. When the authorized person chooses “visible and disabled,” the decision is recorded, the affected criterion is updated, and the next execution brief receives that answer.

This is not a retry under an unchanged contract. An input that governs execution has changed. The affected work must therefore be **recompiled** before it resumes. In our main scenario, this intervention does not exist: the test from attempt 001 demonstrates that the decision had already been made.

## The same package, but with a crossed boundary

Consider another variant. While trying to fix navigation, the agent also decides to persist the page in the URL and creates:

```text
shared/routing/customer-page.ts
```

The choice may look technically coherent. It nevertheless violates two explicit parts of the execution brief: `shared/routing/**` is read-only, and URL synchronization is a non-goal.

The path check now observes six files instead of the five expected product paths:

```yaml
boundaries:
  status: failed
  violation:
    path: shared/routing/customer-page.ts
    rule: read_only

validations:
  "make test-back": skipped_due_to_boundary
  "make test-front": skipped_due_to_boundary
  "make build-front": skipped_due_to_boundary
```

The validations planned by the workflow do not run after this gate fails. Even if the runner claims that it tested the code, a functional green result would not retroactively give the product task authority to change shared routing.

This variant does not automatically open an architecture question. The existing decision is enough: URL synchronization remains out of scope. The normal resumption path is to record the violation, remove or isolate the change attributable to the attempt, and then prepare a repair within the product areas.

If the product requirement genuinely changed, the team could open a separate **Foundation Evolution** effort with its own consumers, validations, and review authority. It should not widen the package that crossed its boundary after the fact.

## Retrying, recompiling, and reclassifying are three different resumptions

The three branches of the same example now yield a concrete rule:

| Situation | What changes | Required authority | Resumption point |
| --- | --- | --- | --- |
| Repairable frontend test | Code, within the existing contract | Agent or developer, within a bounded budget | Repair from the red validation, then rerun the affected checks |
| Undefined “Next” behavior | An acceptance criterion | Product and design | Record the decision, update the input, then recompile |
| `shared/routing/customer-page.ts` observed | The diff crossed a boundary | Task lead; foundation owner only if separate work is considered | Isolate or remove the change, restore a valid scope, then compile a new attempt |

A **retry** preserves the objective, decisions, and authority. **Recompilation** incorporates a changed input. **Reclassification** creates a different kind of work because the scope or required authority has changed.

Using the same word, “resumption,” for all three operations conceals what actually happened.

## A repair loop must remain bounded

A red validation does not authorize an unlimited sequence of corrections. Every attempt should retain at least:

- the signature of the initial failure;
- the proposed diagnosis;
- the actions taken;
- the paths touched during the repair;
- the checks rerun and their results;
- the remaining attempt budget;
- the next action if the problem persists.

If `make test-front` fails a second time with the same symptom and no observable progress, the workflow must stop the loop at the configured threshold. It hands both diagnoses and both diffs to a human. It must neither keep expanding the change nor broaden paths to “try something else.”

The category can also change during diagnosis. If fixing the button ultimately requires changing the API contract, the resumption is no longer the small repair compiled above. If it reveals undefined product behavior, it becomes an intervention. If it requires shared routing, it falls outside the package's authority.

## A Git boundary is not a security boundary

In this flow, the check compares the write policy with the paths observed after the runner finishes. It can prevent an out-of-scope result from proceeding to validations and review. **It is not a sandbox.**

It does not prove that the process was technically unable to access the network, read a secret, or execute a dangerous command. Those guarantees belong to system permissions, process isolation, secret management, and network policy.

The Git coverage must also be stated. A reliable check for this case must see tracked files, staged and unstaged modifications, and the new untracked file `shared/routing/customer-page.ts`. Renames and pre-existing changes further complicate attribution.

Our clean start at `7a31c42` keeps the variant simple: the new path did not exist before the attempt. In an already modified working tree, deleting it automatically could destroy someone else's work. Restoration is reasonable only when the reference state and ownership of the changes are known, and only after the scope violation has been recorded.

Finally, staying inside the allowed directories does not guarantee business correctness. The defect in the “Next” button lived in a perfectly authorized area. Boundaries answer “where did the task write?”, not “is the behavior correct?”

## The minimal stop-and-resumption record

A team can apply this protocol with a short record, even without a full orchestrator:

```markdown
# Stop and resumption

Attempt:
Starting Git state:
Detection phase:
Category: missing decision / crossed boundary / repairable failure

Observed facts:
-

Runner declarations:
-

Required authority:
Decision or diagnosis:
Exact resumption point:
Paths writable during resumption:
Checks to rerun:
Previous attempts to preserve:
Checks not run:
Residual risk:
```

The record separates observations, declarations, authority, and checks. Most importantly, it lets a new session resume without depending on the memory of the previous chat.

## Conclusion

The first pagination attempt required neither a new feature nor a product decision. It required a bounded correction: the expected behavior was explicit, the defect was local, the boundaries had held, and a test could verify the outcome.

Attempt 002 therefore resumed from the failed `make test-front`, changed one file, and reran `make test-back`, `make test-front`, and `make build-front`. It erased neither attempt 001 nor the global check that remained unexecuted.

The variants show why this precision matters. Without a decided behavior, the workflow must wait for human authority and recompile. With `shared/routing/customer-page.ts` in the diff, it must stop at the boundary before validations. In neither case does a simple “continue” describe the next step correctly.

We now have two local attempts: one red, then one green. What do their commands actually allow us to claim, and which state of the code do they apply to? That is the subject of the next article: [**“The Tests Pass”: What Does the Workflow Prove?**](../local-proof-agent-workflow/index.md).

<div class="article-footer-contact">
  <p>To discuss this article or leave me a public message:</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message on GitHub</a>
</div>
