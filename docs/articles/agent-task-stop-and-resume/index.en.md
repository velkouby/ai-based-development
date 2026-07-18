---
title: "When a Task Must Stop: Decisions, Boundaries, and Resumption"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  A missing decision, a scope violation, and a failing test do not call for the same response. Here is how to stop an agentic task cleanly, preserve the relevant facts, and resume without erasing its history.
---

# When a Task Must Stop: Decisions, Boundaries, and Resumption { .article-title }

A missing decision, a scope violation, and a failing test do not call for the same response. A reliable agentic workflow must know why it is stopping, who can unblock the situation, and which facts will allow the work to resume.
{ .article-lead }

<p class="article-meta">
  <span>By <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

In [the previous article](../agent-execution-package/index.md), the brief, the plan, the repository rules, and the decisions already made became a bounded execution brief. It told the agent where to write, what to consult, how to validate, and when not to continue.

Stop conditions are not a precautionary add-on to the execution package. They are an operational part of it. Without them, the agent is encouraged to turn every uncertainty into an implementation choice and every obstacle into a silent expansion of scope.

But “the task is blocked” is still insufficient information. An unresolved product question before coding, a change observed in a protected area, and a failing unit test do not have the same owner, remedy, or resumption point.

> A useful stop does more than say that the work is unfinished. It establishes what happened, what is missing, who must decide, and what will need to be checked again.

The mechanisms presented here—persistent state, write boundaries, attempt history, human decisions, and controlled resumption—form a protocol that a framework applying these principles can implement. The artifacts below show how to make that protocol actionable.

<figure class="article-diagram">
  <img src="task-stop-resume-paths.png" alt="Three branches distinguish a missing decision, a scope violation, and a repairable failure, each with the authority, action, and resumption point required before a new compiled attempt." loading="lazy" />
  <figcaption>The reason for stopping determines the authority required and the legitimate resumption point.</figcaption>
</figure>

## Three stops, three different authorities

A minimal taxonomy already prevents many incorrect attempts to resume work.

| Situation | Triggering fact | Who can act? | Legitimate resumption |
| --- | --- | --- | --- |
| **Missing decision** | A question changes the expected outcome or requires authority that is not present | Product owner, architect, security owner, or domain owner | Record the decision, update the relevant input, then recompile the work |
| **Scope violation** | The observed files touch an unauthorized, read-only, or forbidden area | Task lead and, when necessary, owner of the shared foundation | Isolate or remove the change, split or reclassify the work, then resume from a valid scope |
| **Repairable failure** | A validation or mechanical step fails without raising a new decision | Agent or developer, within a bounded repair policy | Fix the cause, rerun the affected checks, and record a new attempt |

The essential difference is authority. An agent can fix a formatting error when both the command and the remedy are deterministic. It cannot decide on its own that an API incompatibility is acceptable, that a shared primitive may change, or that a permission may be broadened.

We must also distinguish a **stop** from a **failure**. Waiting for a product decision is a normal workflow stop, not a malfunction. Detecting a scope violation means the guardrail worked, even if the attempt cannot be accepted. Conversely, mechanically repeating a failing validation without a diagnosis is not resumption; it is a loop.

## A missing decision must block before coding

The best time to stop a task is often before the agent runner is launched.

Suppose the brief asks for pagination in the customer directory but does not specify what should happen when a page above the new maximum is requested. Should the API return an empty page, clamp the request to the last valid page, or return an explicit error? This choice affects the user experience, the UI contract, and the tests.

The planner can propose options and describe their consequences. It must not present one of them as a mere technical convention. The workflow should then retain an intervention record containing at least:

- the problem stated without unnecessary jargon;
- the exact question that needs a decision;
- the known options and their effects;
- the role expected to make the decision;
- the tasks and criteria affected;
- the answer, its source, and any supporting rationale.

As long as this intervention remains open, no dependent task should be executable. Once the answer is given, it should not merely be injected into a new conversation. It becomes a persistent decision, linked to the intervention that prompted it, and is then included in the next execution package. If it changes the brief, the plan, or the scope, the relevant artifact must be updated and the work recompiled before resumption.

This sequence avoids two failure modes. The first is allowing the agent to code an assumption and then presenting the diff as a way to “ask for confirmation.” The second is receiving a human answer without updating the artifact that held authority. In that case, the next agent may inherit the old ambiguity.

> Answering a question is not enough. The answer must be incorporated into the source that governs the next execution.

If the question reveals that the entire brief is unstable, the task should not resume. The team must return to the problem definition. If it concerns only a local decision already anticipated by the plan, a targeted update may be enough. The resumption point therefore depends on where the uncertainty originated.

## A scope violation is an observed fact after writing

The second case is more uncomfortable: the agent has already written code, and the workflow then finds that a modified file violates the execution brief.

The useful check compares two sources: the declared scope of the executed tasks and the paths actually observed in the working tree. The file list reported by the agent can help with diagnosis, but it must not be the only source. An agent can omit a file, misinterpret a rename, or produce an incomplete summary.

For the customer directory, a conceptual contract could allow writes in the frontend and backend product areas, allow reads from shared routing, and forbid changes to it:

```text
writes allowed
  frontend/customers/**
  backend/customers/**

read-only
  shared/routing/**

stop if
  synchronizing with the URL requires a change to shared routing
```

These paths illustrate how responsibilities can be divided between product areas and shared routing.

If the observed diff contains a file under `shared/routing/`, the result is not “almost compliant.” The attempt crossed a boundary. Functional validations must not turn that crossing into retroactive authorization: a green test does not grant a product task the right to modify the shared foundation.

The workflow must then preserve the finding before any repair: affected paths, violated rule, detection phase, known starting state, and validations already run or not run. This chronology matters. It distinguishes a modification produced during the attempt from a change that existed before it started.

If the working tree was already modified, automatically removing the offending file could destroy someone else's work. The correct response is to suspend the repair and ask a human to determine which changes belong to the attempt and which predate it. Automatic restoration is reasonable only when the system knows exactly which reference state it is restoring and which changes belong to the attempt.

## Teaching variant: pagination and the URL

The following scenario is a teaching example for tracing a stop caused by a scope violation, the resulting decision, and the conditions for resumption.

In this variant, the team extends pagination with an additional requirement: the current page must appear in the URL so that a link can be shared. Because this synchronization was a non-goal of the initial brief, the request is first reclassified, the brief is revised, and a new execution package is compiled. Shared routing remains read-only, with an explicit stop condition. During implementation, the agent nevertheless concludes that the router's public interface is insufficient and modifies a shared primitive.

The post-execution check then observes two categories of changes: the expected product files and one file in shared routing. It classifies the attempt as a scope violation and stops the chain before marking the task complete.

Here is a compact stop record that the workflow could retain:

```markdown
# Stop record — teaching example

Request: synchronize the directory page with the URL
Phase: post-write check
Outcome: stopped at a write boundary

Facts recorded in this example:
- feature files were modified within the authorized scope;
- a shared-routing file was also modified;
- that area was declared read-only;
- the planned validations were not run after the scope check failed.

Options submitted for decision:
1. remove URL synchronization and revise the criteria;
2. find a local adaptation that uses the existing public interface;
3. open a separate Foundation Evolution effort, then resume the feature.

Human decision:
- retain the requirement for a shareable URL;
- revert the unauthorized change;
- handle the router extension as a separate unit of work;
- resume pagination after that extension has been integrated.
```

This record is deliberately compact: it does not describe the entire resumption mechanism. It preserves what a team needs to understand the stop and authorize what comes next.

The decision is not to add `shared/routing/**` to the authorized paths of the existing task. That would disguise the scope violation by widening the contract after the fact. The shared change becomes a **Foundation Evolution** effort with its own intent, impact analysis, consumers, validations, and review.

The pagination feature remains stopped until this dependency is available. After the shared extension is integrated, the pagination plan is reassessed: a new starting revision, a new public interface to reuse, an unchanged product scope, and updated validations. The task can then resume without erasing the first attempt.

## Reverting, retrying, and splitting the work are not synonyms

Once the stop has been classified, the verb used for resumption must be precise.

**Reverting an unauthorized change** means returning only the affected paths to a known reference state, then rerunning the scope check. This action does not validate the rest of the diff. It removes a fact that is incompatible with the contract.

**Retrying a task** means keeping the same objective and authority but producing a new attempt after a bounded correction. The earlier attempt remains visible: cause, actions taken, files touched, and validation results.

**Replanning** means that the input has changed. A human decision, a new contract, or an integrated dependency changes the execution brief. Rerunning exactly the same package would be inconsistent; a new one must be compiled.

**Splitting or reclassifying** means that the discovered change no longer belongs to the original unit of work. A Foundation Evolution effort must remain separate from the product task. Depending on its scope, a migration or security decision may also require a separate unit or reclassification with the corresponding authority.

This distinction protects traceability. If every action is called “resumption,” a team can no longer tell whether the agent fixed a mistake, received a new decision, or was granted a broader scope.

## Repairable failure: a bounded loop, not a blank check

The third case is a mechanical or validation failure. For example, a targeted test reveals that the “next page” button remains enabled on the last page. The objective, API contract, and scope do not change. The cause is localized in an authorized area, and the same test can verify the correction.

A repair attempt is reasonable when four conditions are met:

1. the failure is classified and the diagnosis is sufficiently precise;
2. the correction requires no new dependency, product decision, or path expansion;
3. the commands to rerun are known;
4. the number of attempts is limited.

After the correction, rerunning only the failing command is not enough if other checks may have been affected. At a minimum, the workflow must repeat the scope check and then the validations related to the corrected files. If the repair changed the backend contract, the tests for the UI that consumes it become relevant again, even if they were green before.

Each attempt should retain a compact history: initial reason, diagnosis, actions, paths touched, validations rerun, result, and next action. If the repair stops making progress or reaches the authorized limit, the loop stops. The system then hands the attempts to a human instead of continuing to consume time while allowing the diff to grow.

Some failures only appear mechanically repairable. A test fails because the expected behavior is undefined: that is a missing decision. A build fails because resolving it would require a new dependency: that requires authorization. A validation reveals a compatibility break: that may require an architecture or migration decision. The output of a tool therefore does not determine the category by itself; the change required to resolve it matters more.

## Resuming means reconstructing the task's authority

Reliable resumption does not mean sending “continue where you left off” in the same chat. It explicitly reconstructs the authorized state.

Before restarting the agent runner, the workflow should verify:

- that blocking interventions have been resolved;
- that the human answer has been recorded and linked to the affected tasks;
- that preceding dependencies have been completed;
- that unauthorized changes have been isolated or removed;
- that the brief, plan, and criteria remain coherent;
- that the new package contains the decision and the correct starting Git state;
- that the validations to rerun are explicit.

The new attempt then receives the useful context from the previous one, not its entire conversation. It knows what failed, what was decided, what must not be repeated, and which evidence is expected. Completed tasks can remain complete if their results are still valid; the stopped task becomes executable again only when its preconditions are satisfied.

In the URL teaching variant, resumption includes the architecture decision, the router's new public interface, and the unchanged prohibition on modifying the shared foundation. It does not grant the agent broader access. On the contrary, it makes a narrower product implementation possible.

> A good resumption does not discard the previous stop record. It turns that stop into a verifiable input for the next attempt.

## What the scope check does not guarantee

The check described here runs after writing in the normal flow. It can detect that an observed path is outside the scope and prevent the result from being accepted. A separate, explicitly authorized mechanism can then restore a known state or request a human decision. **This is not a sandbox.**

It does not prove that the process was technically unable to write elsewhere, access the network, read a secret, or run a dangerous command. Those guarantees belong to other mechanisms: system permissions, process isolation, secret management, network policy, and the execution environment.

Nor does it detect a semantic error in an authorized path. The agent can remain perfectly within the declared directories and still introduce a business defect. Finally, the scope of the Git check must be stated: tracked files, untracked files, the index, pre-existing changes, and renames are not always observed in the same way.

The guardrail provides a narrower benefit: it compares a write policy with a set of observed modifications, then exposes the discrepancy before review. That is already useful, provided it is not credited with a security guarantee it does not provide.

## The minimal stop record

A team can apply this method without a full orchestrator. For every interrupted task, retain a short record:

```markdown
# Stop and resumption

Category: missing decision / scope violation / repairable failure
Detection phase:
Affected attempt:

Observed facts:
-

What remains agent-declared:
-

Impact on the expected outcome:
Authority required:

Options:
1.
2.

Decision and source:
Actions before resumption:
Artifacts to update:
Checks to rerun:
Residual risk:
```

The record enforces three useful separations: facts from declarations, options from decisions, and correction from validation. Most importantly, it prevents resumption from depending on the memory of the person who watched the execution.

## Conclusion

Knowing when to stop is a positive capability in an agentic workflow. A missing decision must be escalated to the right authority. A scope violation must remain visible, even if the modification is later removed. A repairable failure can trigger a new attempt, but only within a bounded loop followed by renewed checks.

In all three cases, resumption must neither erase history nor silently expand the contract. It links a finding, decision, or repair to a new execution brief.

One question remains: what is the evidence produced by this workflow actually worth? A successful scope check and commands that completed successfully do not yet tell us which revision they apply to or what they actually covered. To study this without confusing the main scenario with the URL variant, the next article returns to the initial pagination execution: [**“The Tests Pass”: What Does the Workflow Prove?**](../local-proof-agent-workflow/index.md).

<div class="article-footer-contact">
  <p>To discuss this article or leave me a public message:</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message on GitHub</a>
</div>
