---
title: "Four Modes, Two Paths: Choosing the Right Level of Control"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  A local fix, an end-to-end feature, and a foundation change do not call for the same level of control. Here is how to choose a process that is proportionate to the risk of the change.
---

# Four Modes, Two Paths: Choosing the Right Level of Control { .article-title }

A local fix, an end-to-end feature, and a foundation change do not justify the same context, validations, or decision authority. The right level of control depends on the risk profile of the change, not on the number of lines or the tool that produces them.
{ .article-lead }

<p class="article-meta">
  <span>By <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

An [agent-ready repository](../agent-ready-repository/index.md) tells the agent where it may act, which rules it must follow, and when it must stop. It does not yet tell us how much structure each request deserves.

Changing the empty-state label, adding a local action, implementing end-to-end pagination for the customer directory, and modifying a shared primitive are four fundamentally different kinds of change. Sending all four through exactly the same path would be a mistake in both directions: too little control makes a change fragile; too much turns a local fix into a ceremony.

Line count is a poor guide. A change of a few characters in an authorization rule can affect every user. Conversely, a visual adjustment spread across several files may remain local, visible, and easy to reverse. The size of the Git diff tells us neither who should decide nor what the change commits us to.

The foundational article, [From Vibe Coding to Verifiable Agentic Development](../ai-agent-based-coding-best-practices/index.md), introduced four modes of agent-assisted development. Here, they become a practical decision model.

> The right level of control is neither the systematic maximum nor the default minimum. It is the lightest process that makes both risk and decision authority visible.

## Mode, path, and tool answer different questions

Before choosing, we need to separate three concepts.

- The **mode** characterizes the change and the level of governance it requires.
- The **path** organizes the work: inputs, steps, artifacts, controls, and review.
- The **tool** executes some or all of that path.

These distinctions keep a decision model from turning into software documentation. The four modes presented here are neither configuration values nor runtime states. A team can apply them with Markdown files, scripts, an internal platform, or a combination of existing tools.

> The mode characterizes the change. The path organizes the work. The tool remains an implementation detail.

The modes are not a maturity ladder, either. A Structured Feature is not “better” than a controlled local fix. It simply addresses a different profile. Foundation Evolution is different again because it also raises a question of ownership. As soon as a shared primitive, rule, or piece of tooling must change, that category takes precedence, even if the expected diff is tiny.

## Five dimensions for characterizing a change

The decision can begin with five questions. They are not a scoring system; they make the risk open to discussion.

| Dimension | Question to ask | Lightweight profile | Signal for additional control |
| --- | --- | --- | --- |
| Scope | Does the change remain within a known product area? | Local behavior, obvious paths | Multiple layers, domains, or shared areas |
| Ambiguity | Are the expected outcome and the defining choices already settled? | Observable outcome, solution constrained by existing conventions | Product, technical, or architectural decision still open |
| Reversibility | Would reverting the change in Git actually remove its effects? | No persistent data or users already depending on the change | Migration, external effect, or coordinated rollback required |
| Surfaces and contracts | How many interfaces must evolve together? | One module, with no shared contract change | UI, API, data, infrastructure, or multiple clients |
| Authority | Who can accept the decisions introduced by the change? | Implementer and module owner | Product, platform, security, architecture, or an external partner |

Scope and affected surfaces may look similar, but they describe different things. Scope measures how far the work extends across the repository. Surfaces and contracts measure coupling: a small change may stay within a single file while altering a contract consumed by several systems.

Reversibility must also be assessed against the real-world effect, not Git alone. Reverting a Git revision is straightforward. Restoring data after a migration, withdrawing an API response that consumers already rely on, or undoing a message sent to an external system may not be.

Authority does not measure technical difficulty. It answers a different question: does the person requesting or implementing the change have the authority to accept its consequences? If approval requires the security lead, an API owner, or the platform team, the path must make that decision visible.

## Triggers that set a minimum level of control

Even before comparing the five dimensions, certain triggers rule out a lightweight mode unless there is an explicit decision:

- security, authentication, or authorization;
- sensitive data or regulatory obligations;
- a migration, data deletion, or destructive operation;
- a new dependency or infrastructure service;
- a public, external, or difficult-to-evolve contract;
- shared foundation, tooling, or a common rule;
- an external effect that is difficult to reverse.

These triggers do not all prescribe the same mode. An authorization change within a product feature is not necessarily Foundation Evolution. It does require an explicit decision from someone with the appropriate authority and may justify an orchestrated path.

The answer is not to add points and calculate an average. Four low-risk indicators do not cancel out a data migration or a security decision. The most constraining factor sets the minimum level of control.

The decision process has four steps:

1. identify triggers that require stronger control;
2. characterize the five dimensions;
3. select the mode compatible with the dominant risk;
4. record the decision owner and the facts that would require the choice to be reassessed.

<figure class="article-diagram">
  <img src="control-level-decision-flow.png" alt="Decision flow connecting the request, escalation signals, five non-scored dimensions, the dominant risk, the mode and path, and the responsible decision authority." loading="lazy" />
  <figcaption>The dominant risk sets the minimum level of control; the other dimensions refine the decision.</figcaption>
</figure>

## The decision record

The decision should be reviewable without reopening the conversation. A short record is enough if it captures the reasoning and the decision authority.

The following example is a human-facing decision aid that is independent of any tool. It is neither a configuration file nor the execution brief sent to the agent.

```markdown
# Decision Record

Request:
Observable outcome:
Initial scope:

| Dimension | Observation | Level |
| --- | --- | --- |
| Scope | | low / moderate / high |
| Ambiguity | | low / moderate / high |
| Reversibility | | simple / coordinated / difficult |
| Surfaces and contracts | | one / several / shared or external |
| Required authority | | module / domain / product, platform, or security |

Escalation triggers:
- [ ] security, authorization, or sensitive data
- [ ] migration or destructive operation
- [ ] new dependency or infrastructure
- [ ] public or external contract
- [ ] foundation, tooling, or common rule
- [ ] external effect that is difficult to reverse

Decision:
- Initial mode:
- Path:
- Rationale:
- Minimum input:
- Minimum output:
- Decision owner(s) or approval role:
- Reassess if:
```

This record comes before the task contract introduced in the previous article. The record selects the level of governance; the contract then bounds execution. In the record, scope is still expressed in terms of surfaces and responsibilities. Exact paths belong in the task contract. Deciding how to work is not yet the same as specifying exactly where the agent may write.

## Four variations on the same customer directory

The four modes become clearer when they are applied to the same product. For the practical articles that follow, I use these public labels to standardize the taxonomy first outlined in the foundational article.

| Mode | Dominant profile | Minimum input | Minimum output |
| --- | --- | --- | --- |
| **Controlled Vibe Coding** | Local, visible, and reversible | Bounded request | Reviewed diff and targeted validation |
| **Guided Coding** | Nontrivial but contained within a known product area | Short brief and plan | Tracking, recorded validations, and review |
| **Structured Feature** | Cross-cutting or still ambiguous | Clarified brief, then a specification if needed | Bounded tasks, controls, and recorded results |
| **Foundation Evolution** | Change to a shared primitive, rule, or piece of tooling | Impact proposal and identified owner | Separate change, compatibility analysis, broader validations, and dedicated review |

### Controlled Vibe Coding: change the empty-state label

The change is visible, local, and easy to reverse. It affects no contract, dependency, or shared behavior. A precise request, a reviewed diff, and targeted validation may be enough.

The word “controlled” matters. This mode does not mean that conversation replaces repository rules. The agent remains bounded to the relevant area, reuses existing conventions, and exposes the actual result for review. If the change reveals a broader issue in the shared component, the task no longer fits this mode.

### Guided Coding: add a local action using existing contracts

Adding an action to the directory may touch several files, require finding an existing component, and call for a behavioral test. The result still remains within a known product area and does not modify the API contract.

A short brief and a plan are proportionate inputs: expected behavior, files likely to be affected, conventions to reuse, and targeted validations. Keeping the work log outside the conversation makes the task easier to resume and review without imposing the full machinery of a Structured Feature.

If the action ultimately requires a new API route, dependency, or permission, the profile changes. The initial plan does not give the agent authority to silently expand the task to accommodate that discovery.

### Structured Feature: add server-side pagination

Pagination connects the UI, the API, the response contract, loading states, and tests. Several decisions must be made consistently: contract shape, initial page, page size, boundary behavior, and compatibility with existing consumers.

The work therefore calls for a clarified brief, task breakdown, explicit boundaries, recorded validation results, and a review summary. A full specification is not required by default: it becomes useful when open decisions cannot be resolved cleanly in the brief and plan.

### Foundation Evolution: modify a shared primitive

Now suppose pagination requires a change to the common router or to a UI primitive used elsewhere. The diff may be short, but the decision and its impact are not.

This change must become a separate unit of work. Its starting point is no longer only the customer directory's need, but an impact proposal: affected consumers, compatibility, transition strategy, broader validations, and the decision owner. Foundation Evolution is not a blank check to modify shared files. On the contrary, it makes those modifications explicit and holds them to a higher standard.

## Two paths, not four execution pipelines

The four modes do not require four different systems. Two paths, with proportionate variants, are enough to put these decisions into practice.

```text
characterized request
├── lightweight path
│   ├── direct variant   → Controlled Vibe Coding
│   └── tracked variant  → Guided Coding
└── orchestrated path
    ├── product work     → Structured Feature
    └── shared work      → Foundation Evolution, handled separately
```

The **lightweight path** minimizes coordination cost. In its direct variant, the bounded request leads to the change, targeted validation, and then review of the diff. In its tracked variant, a short brief, a plan, and a persistent work log are added before review.

The retained context remains proportionate to the task. If the agent maintains the log itself, the log helps people understand and resume the work; it does not become independent evidence.

The **orchestrated path** separates responsibilities more clearly. The brief is clarified, the work is broken down, the scope is bounded, control and validation results are retained, and then a local review prepares the handoff to Git and CI. Foundation Evolution follows the same general sequence, but as a separate unit with a broader compatibility analysis.

The selected path describes the minimum process expected. It does not assume a particular model or the interface through which the agent is invoked.

## A completed decision record for pagination

| Dimension | Observation | Characterization |
| --- | --- | --- |
| Scope | One coherent, bounded feature | Moderate |
| Ambiguity | The outcome is clear; the exact contract shape still needs confirmation | Moderate |
| Reversibility | No migration is planned, but rollback must be coordinated across the UI and API | Coordinated |
| Surfaces and contracts | UI, internal API, tests, and documentation | Several surfaces and one internal API contract |
| Required authority | Feature owner and API owner | Domain-level |

The dominant factors are the work across multiple surfaces and the coordinated evolution of an internal contract. No trigger independently requires stronger control: the initial scope includes no migration, new dependency, public contract, sensitive data, or foundation change.

The decision is therefore:

- **initial mode:** Structured Feature;
- **path:** orchestrated;
- **minimum input:** clarified brief, acceptance criteria, and initial scope;
- **minimum output:** plan and bounded tasks, recorded control and validation results, a reviewable diff, and human review;
- **decision owners:** the feature owner together with the API owner;
- **reassess if:** the solution requires a shared routing primitive, an incompatible contract, a migration, or a new dependency.

The record does not prove that this decision is perfect. It makes the choice explicit, contestable, and changeable before the agent turns assumptions into code.

## The mode is a starting point, not authorization

An initial classification is a working hypothesis. Exploration may reveal a fact that changes the profile: a missing dependency, an external contract, a required migration, or an insufficient shared component.

In that case, execution must pause. The agent may recommend reclassification, but it must not expand its own scope. The person leading the task, potentially with support from the workflow, must then:

1. record the new fact and its impact;
2. confirm or change the mode and path;
3. identify the appropriate decision owner;
4. redefine the scope and validations before resuming.

For the customer directory, discovering that synchronizing the page number with the URL requires a change to the shared router does not retroactively make an out-of-scope change acceptable. Work on the product task stops; the team chooses a local solution or opens a separate Foundation Evolution effort.

The ability to reclassify matters more than getting the taxonomy perfect at the outset. A useful decision model does not try to predict the entire implementation. It makes the events that require a new decision visible.

## Conclusion

Choosing a mode means selecting the lightest process compatible with the dominant risk. Line count, model, and tool are not enough. Scope, ambiguity, reversibility, affected contracts, and required authority provide a stronger basis.

The repository contract defines the rules of the terrain. The mode sets the level of governance. The path sets the steps and the facts that must be retained.

For customer-directory pagination, the decision model leads to a Structured Feature and an orchestrated path. The next article will follow that path end to end, from a clarified brief to local review, showing what each step produces and what it actually allows us to claim.

<div class="article-footer-contact">
  <p>To discuss this article or leave me a public message:</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message on GitHub</a>
</div>
