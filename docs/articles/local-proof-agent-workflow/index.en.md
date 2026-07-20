---
title: "“The Tests Pass”: What Does the Workflow Prove?"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Three green commands do not validate a feature by themselves. Let us inspect two concrete attempts, their Git state, and their manifest to see what local evidence really allows us to claim.
---

# “The Tests Pass”: What Does the Workflow Prove? { .article-title }

Three commands return `0` on the second attempt. Five files have changed, all within scope. Yet the precise conclusion is not “the feature is validated”: an identified local state passed specific checks after a first failing attempt that the workflow preserved.
{ .article-lead }

<p class="article-meta">
  <span>By <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

In the [previous article](../agent-task-stop-and-resume/index.md), we followed attempt 001's frontend failure to the bounded repair in attempt 002. We also saw why a URL-synchronization change under `shared/routing/**` would require a different stop. We now stay with the successful local-repair path, whose package only writes under `backend/customers/**` and `frontend/customers/**`.

The runner has just completed a second attempt. Before summarizing the outcome as “the tests pass,” let us inspect the Git state, commands, and evidence manifest that the reviewer will actually receive.

The point to establish is simple: a green result becomes useful when we can answer five questions.

1. Which state of the code did the command run against?
2. What did it actually execute?
3. Which observable result did it produce?
4. Which part of the change does that result cover?
5. What remains unrun, unknown, or subject to human judgment?

> Green summarizes the outcome of a command. Evidence preserves the state, scope, history, and gaps required to interpret it.

## Start with an identifiable state

Before the first attempt, the workflow records the branch, starting revision, and working-tree state:

```console
$ git branch --show-current
feature/customer-pagination

$ git rev-parse --short HEAD
7a31c42

$ git status --short --untracked-files=all
```

The final command prints no lines. In this observation, the working tree, Git index, and list of untracked files are empty. The package therefore starts on `feature/customer-pagination`, from commit `7a31c42`, with no detected local changes.

This snapshot does not guarantee that the repository will remain clean. It only establishes the comparison point before the runner executes T-01, T-02, and T-03: evolve the backend contract, adapt the frontend directory, and then review their consistency.

The runner loads the package, modifies the five expected files, and reports all three tasks as complete. That declaration triggers the checks; it does not replace them.

## Attempt 001: two green commands, one failing behavior

The path check passes: every observed file belongs to an authorized product area. The workflow then runs the three targeted validations declared in the execution brief.

```text
Attempt 001

Path check
  status: passed

$ make test-back
  exit code: 0

$ make test-front
  FAIL CustomerList > disables Next on the last page
  expected: disabled
  received: enabled
  exit code: 1

$ make build-front
  exit code: 0

Global quality
  status: not_run

Attempt status
  needs_retry
```

This combination is informative. The backend passes. The frontend builds. Yet an observable behavior remains wrong: on the last page, the “Next” button is still enabled.

The green build does not cancel the red test. These commands ask different questions. `make build-front` establishes that the requested frontend can be built in this environment; it does not verify that navigation respects pagination boundaries.

The attempt therefore moves to `needs_retry`. The workflow keeps the test name, expected result, received result, and the other two green commands. It neither replaces the evidence with a vague “the tests fail” nor marks the feature complete because two out of three checks succeeded.

## Attempt 002: repair one behavior, then revalidate the whole state

The diagnosis requires no new product decision, dependency, or scope extension. The repair can remain in the component that owns the behavior:

```text
file changed during attempt 002
  frontend/customers/customer-list.tsx
```

Attempt 002 receives the previous failure, the same write authority, and the same validations. After the repair, the workflow checks the paths again and reruns the three commands declared for the package:

```text
Attempt 002

Path check
  status: passed

$ make test-back
  exit code: 0

$ make test-front
  exit code: 0

$ make build-front
  exit code: 0

Global quality
  status: not_run

Attempt status
  completed
```

Rerunning all three commands produces coherent evidence for the package's final state. Another policy could select a justified subset based on the repair's impact; in this path, the contract requires all three validations, so all three run again.

The latest green result does not rewrite history. Attempt 001 remains visible with its failure, while attempt 002 shows the bounded repair that produced the new result.

<figure class="article-diagram">
  <img src="local-proof-context.png" alt="Two customer-pagination attempts are connected: the first preserves a failing frontend test, and the second passes three targeted commands after a bounded repair. The current HEAD, five observed paths, unrun global quality check, and missing result commit remain visible." loading="lazy" />
  <figcaption>Attempt 002's green result can only be interpreted with its Git state, scope, previous failing attempt, and missing checks.</figcaption>
</figure>

## What Git actually observes

At the end of attempt 001, the workflow retained the same Git observations it will now collect again. At the end of attempt 002, the working tree still contains the feature's complete diff. The runner changed only one file during this second attempt, but the other four modifications produced during the first remain present.

```console
$ git branch --show-current
feature/customer-pagination

$ git rev-parse --short HEAD
7a31c42

$ git diff --name-only
backend/customers/api.py
backend/customers/tests/test_pagination.py
frontend/customers/customer-api.ts
frontend/customers/customer-list.tsx
frontend/customers/customer-list.test.tsx

$ git diff --cached --name-only

$ git ls-files --others --exclude-standard
```

The first two commands confirm that the runner remained on the starting branch and that `HEAD` is still `7a31c42`. `git diff --name-only` compares the working tree with the index; because the index is empty of changes and still points to that same `HEAD`, its five paths also form the diff from the starting commit. The last command finds no untracked files.

Comparing the snapshots supports two distinct claims:

- between the clean start and final state, five files appeared in the feature diff;
- between the start and end of attempt 002, only `frontend/customers/customer-list.tsx` changed.

This distinction prevents the repair attempt from receiving credit for the entire feature. It also prevents the agent-reported file list from being confused with the list observed by Git. Without intermediate checkpoints between T-01, T-02, and T-03, Git still cannot establish which task produced each line.

## Check the paths file by file

The execution brief allows writes under `backend/customers/**` and `frontend/customers/**`. Shared layers remain read-only; tooling, generated files, and workflow state are forbidden.

| Observed path | Matching rule | Conclusion |
| --- | --- | --- |
| `backend/customers/api.py` | `backend/customers/**` | Writable |
| `backend/customers/tests/test_pagination.py` | `backend/customers/**` | Writable |
| `frontend/customers/customer-api.ts` | `frontend/customers/**` | Writable |
| `frontend/customers/customer-list.tsx` | `frontend/customers/**` | Writable |
| `frontend/customers/customer-list.test.tsx` | `frontend/customers/**` | Writable |

No observed path touches `shared/ui/**`, `shared/state/**`, `shared/routing/**`, `tooling/**`, `generated/**`, or `workflow-state/**`. The `passed` status therefore means: **every path included in this observation matches a writable area in the package**.

It does not mean that the process was technically unable to write elsewhere. The check happens after writing; it is not a sandbox. Nor does it detect a business error inside an authorized path—exactly the kind of error the frontend test found in attempt 001.

## Open the attempt 002 manifest

The manifest gathers the facts required to reconstruct the latest result without erasing the previous attempt:

```yaml
evidence:
  attempt:
    id: "002"
    previous_attempt: "001"
    status: completed
    source: local

  revision:
    branch: feature/customer-pagination
    base_commit: 7a31c42
    current_head: 7a31c42
    result_commit: null
    feature_started_clean: true
    mutable_working_tree: true

  git:
    carried_from_attempt_001:
      - backend/customers/api.py
      - backend/customers/tests/test_pagination.py
      - frontend/customers/customer-api.ts
      - frontend/customers/customer-list.tsx
      - frontend/customers/customer-list.test.tsx
    changed_during_attempt_002:
      - frontend/customers/customer-list.tsx
    final_modified_files:
      - backend/customers/api.py
      - backend/customers/tests/test_pagination.py
      - frontend/customers/customer-api.ts
      - frontend/customers/customer-list.tsx
      - frontend/customers/customer-list.test.tsx
    staged_files: []
    untracked_files: []

  path_policy:
    status: passed
    violations: []

  validations:
    - command: make test-back
      exit_code: 0
      status: passed
      criteria: [AC-1]
    - command: make test-front
      exit_code: 0
      status: passed
      criteria: [AC-2, AC-3, AC-4]
    - command: make build-front
      exit_code: 0
      status: passed
      criteria: []

  global_quality:
    status: not_run

  previous_attempt:
    id: "001"
    status: needs_retry
    failed_command: make test-front
    failure: "Next remained enabled on the last page"

  agent_declaration:
    status: completed
    open_questions: []

  human_review:
    status: pending
```

Several separations are deliberate. `agent_declaration` reports what the runner says it completed; `git`, `path_policy`, and `validations` contain workflow observations. `previous_attempt` preserves the failure that explains the retry. `human_review` remains `pending`, even when every targeted validation is green.

Two values are particularly effective at preventing an overbroad conclusion. `global_quality: not_run` says that the global quality profile did not run. `result_commit: null` says that the manifest still describes a mutable working tree, not a commit containing exactly the reviewed change. `current_head: 7a31c42` records the real Git `HEAD`; it is the base below the uncommitted diff, not an identity for that diff.

## Map each criterion to a check

A command does not cover a feature “in general.” The plan must say which question it is meant to exercise, and review must then confirm that the tests present actually match that intention.

| Acceptance criterion | Planned check | Observed in attempt 002 | What remains to review |
| --- | --- | --- | --- |
| **AC-1.** The API returns items, current page, and total count; an invalid page returns HTTP 404 with code `pagination_page_invalide` | `make test-back` | Exit code `0` | The cases in the suite and compatibility with known consumers |
| **AC-2.** Users can move forward and backward without crossing the first or last page | `make test-front` | Exit code `0`; the upper bound failed in attempt 001 | Whether the test scenario faithfully represents the intended interaction |
| **AC-3.** The `loading`, `empty`, and `error` states remain distinct | `make test-front` | Exit code `0` | Visual rendering, keyboard behavior, and accessibility |
| **AC-4.** The directory loads the first page when opened | `make test-front` | Exit code `0` | Whether the default still matches the brief |
| The frontend must remain buildable | `make build-front` | Exit code `0` | This structural gate does not judge product behavior |

The “planned check” column comes from the plan. The “observed result” column comes from execution. Confusing them would make a command name look like a guarantee of coverage. The manifest can strengthen the connection by retaining relevant test identifiers or inspectable outputs; review is still responsible for judging whether the mapping is credible.

## What we can claim—and nothing more

| Evidence | Legitimate claim | Unsupported claim |
| --- | --- | --- |
| Clean start and final Git inspection | These five paths make up the local diff observed since `7a31c42` | Every line can be independently attributed to a precise task |
| Path policy `passed` | Every observed path matches a write rule | The process could not write anywhere else |
| `make test-back` returns `0` | That backend command passed against the final local state | The API is correct in every environment |
| `make test-front` returns `0` in attempt 002 | The existing frontend scenarios passed after the repair | Every browser, visual state, and accessible interaction is correct |
| `make build-front` returns `0` | The requested build completed successfully | The feature is usable or acceptable |
| `global_quality: not_run` | No global quality result exists for this attempt | Global quality implicitly passed |
| `result_commit: null` | No commit contains exactly the locally validated diff yet | The same results already apply to a pull request revision |

Gaps must remain data. **Not run** means an identified check did not execute. **Unknown** means required information—such as an uncaptured tool version—is missing. **Truncated** must appear when only part of an output is retained. **Unstable** must remain visible when a check passes after a failure whose cause is not understood.

Our frontend test is not classified as unstable: a precise cause was observed, one file was repaired, and a new attempt was recorded. That does not prove that the diagnosis was exhaustive; it at least makes the sequence open to challenge.

## The final review record

The manifest is designed for tools. The reviewer needs a more direct summary that does not lose provenance:

```markdown
# Local review — customer directory pagination

Starting point:
- branch: feature/customer-pagination
- base commit: 7a31c42
- clean working tree before attempt 001

Execution:
- attempt 001: needs_retry
- attempt 002: completed
- bounded repair: frontend/customers/customer-list.tsx

Observed change:
- 5 modified files
- 0 staged files
- 0 untracked files
- path policy: passed

Targeted validations on attempt 002:
- make test-back: passed
- make test-front: passed
- make build-front: passed

Not run:
- global quality profile
- CI
- human visual and accessibility review

Decision:
- ready for local diff review
- not yet bound to a result commit
- not yet approved for merge
```

This summary does not say “pagination is validated.” It says why the diff can now be reviewed, which targeted validations passed, which failure preceded that result, and which gates remain closed.

## From working tree to commit and CI

Local evidence ends with `current_head: 7a31c42` and `result_commit: null`. As long as the change remains in a working tree, a file can still be edited after the green commands. Attempt 002's results do not automatically apply to that new state.

The expected handoff is therefore explicit:

```text
attempt 002 on a mutable working tree
  -> human review of the local diff
  -> a commit containing exactly that diff
  -> CI validations on that head commit
  -> a pull request gathering the diff, results, gaps, and decisions
  -> human acceptance, request for another attempt, or rejection
```

Git then provides a content identity. CI runs checks against that identity in an environment described by the pipeline. Neither decides that the commands are sufficient, that the criteria are covered correctly, or that the residual risk is acceptable.

If another fix is added after the validated commit, the link must be rebuilt: new head commit, new results. A reliable review interface makes a stale green result visible instead of leaving it attached to the pull request as though it still applied to the latest state.

## Conclusion

In this example, “the tests pass” can be replaced with a verifiable sentence: on attempt 002, from base commit `7a31c42`, all five observed files remain within the authorized scope, and `make test-back`, `make test-front`, and `make build-front` return `0`. Global quality did not run, no result commit contains the diff yet, and human review remains pending.

This wording is less triumphant. It is also far more actionable.

It closes the path opened at the start of this series: [the overview establishes the full workflow](../ai-agent-based-coding-best-practices/index.md), [the repository makes rules visible](../agent-ready-repository/index.md), [the mode determines the level of control](../agent-coding-modes/index.md), [the feature follows an end-to-end path](../agentic-feature-end-to-end/index.md), the plan becomes [an execution brief](../agent-execution-package/index.md), the runner proposes a change, [stops remain traceable](../agent-task-stop-and-resume/index.md), and local evidence finally prepares Git, CI, and human judgment without replacing them.

A reliable agentic workflow does not promise that the agent will always be right. It makes a better question possible: **which precise facts support our acceptance of this change, and which risks are we still choosing to carry?**

<div class="article-footer-contact">
  <p>To discuss this article or leave me a public message:</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message on GitHub</a>
</div>
