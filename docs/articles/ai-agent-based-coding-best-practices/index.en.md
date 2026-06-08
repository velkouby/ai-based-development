---
title: "AI Agent-Based Coding: Best Practices"
description: >-
  Vibe coding proved that natural-language intent can become a development interface. But to build maintainable software, whether alone or as a team, you need more than a conversation with an agent. You need four simple building blocks: an agent-ready repository that carries the rules, a workflow that enforces them, a plan that compiles the useful context, and execution evidence that makes the work reviewable.
---

# AI Agent-Based Coding: Best Practices { .article-title }

Vibe coding proved that natural-language intent can become a development interface. But to build maintainable software, whether alone or as a team, you need more than a conversation with an agent. You need four simple building blocks: an agent-ready repository that carries the rules, a workflow that enforces them, a plan that compiles the useful context, and execution evidence that makes the work reviewable.
{ .article-lead }

Software development with AI is often described as an individual story. A developer opens a coding agent, describes what they want, lets the agent modify the codebase, then corrects or approves the result. That loop is real. It is also powerful. It explains why vibe coding attracted so much attention: for the first time, intent expressed in natural language became a direct interface to a software system.

But that description is incomplete.

Even when you work alone, you are not developing only inside a conversation. You are developing inside a repository, with an architecture, conventions, dependencies, scripts, tests, commits, product decisions, and technical memory. And as soon as you work as a team, that reality becomes more demanding: the repository is shared, pull requests must be reviewed, review rules must be explicit, security constraints must be respected, and decisions must survive individual conversations.

When coding agents enter this system, the real question is not: “What prompt should I write?” The real question is: **what system should the agent work inside?**

> The challenge of AI agent-based coding is not to make the conversation with the agent longer. It is to design a better system that guides, constrains, and verifies it.

This article proposes a simple method for combining practices that are already emerging: agent-ready repositories, explicit workflows, selected context, reviewable tasks, and execution evidence. This combination makes agent-based work useful for solo developers and shareable across teams.

## Vibe coding is right about intuition, but wrong about industrialization

Vibe coding revealed something important: part of software is not discovered through exhaustive specifications. It is discovered through trying, observing, correcting, and conversing. This is especially true for prototypes, interface details, UX adjustments, workflow explorations, and quick fixes. Recent work describes vibe coding as a practice of conversational co-creation with AI, linked to flow, experimentation, and trust in the agent. It also identifies its weaknesses: difficulty expressing intent precisely, variable reliability, review burden, hard debugging, and context drift. ([arXiv][1])

So vibe coding should not be caricatured as an immature practice to abandon. That would miss its value. Vibe coding is fast because it lets humans stay close to intent and to the observable result. It reduces the initial friction between “I have an idea” and “I can see something working.”

But that speed has a cost. A literature review on vibe coding practices describes a speed-quality paradox: users are attracted by speed and accessibility, but often perceive the generated code as fast and imperfect, with QA practices frequently neglected. ([arXiv][2])

The problem is not that vibe coding is useless. The problem is that it becomes fragile as soon as it touches a real codebase. A conversation does not naturally carry architectural boundaries. It does not always distinguish a reusable component from a component that should not be touched. It does not enforce validations. It does not always produce a trace that is useful in review. It does not guarantee that two developers will use the agent in the same way.

> Vibe coding creates speed. Vibe coding without boundaries creates debt.

## The repository must become agent-ready

The first building block of industrializable AI-native development is not the prompt. It is the repository.

A coding agent should not enter a vague workspace. It should enter an environment that clearly states where to code, how to code, what to reuse, what not to modify, how to validate, how to prove completion, and when to stop.

An agent-ready repository is not just a well-documented repository. It is a repository where human conventions have become actionable for agents. It contains an executable template, a stack chosen by the team, standard scripts, identified extension points, protected zones, reusable patterns, testing rules, validation commands, and operational documentation for agents.

The nuance matters. Many teams already add instruction files for agents. That is useful, but insufficient. A rule written in a file is not the same as a rule being enforced. If the workflow depends on the agent’s memory, that rule will eventually be forgotten, bypassed, or misinterpreted.

The emergence of `AGENTS.md` points in this direction: a predictable place, close to a README for agents, where teams can put setup commands, conventions, testing rules, or PR expectations. Codex also documents how these files can be used to load project instructions before execution. But these files should not become encyclopedias. Recent work on context files shows that they can increase cost and sometimes reduce success rates when they add too many unnecessary requirements. The right direction is not “more instructions.” It is “shorter, more reliable instructions, enforced by the workflow.” ([AGENTS.md][11]) ([OpenAI Developers][12]) ([arXiv][13])

> Agent docs describe the rules. The workflow enforces them. The plan carries them into the execution context.

An agent should not reinvent the stack for every feature. It should not choose a new library because it seems convenient. It should not recreate an existing component because it failed to find it. It should not satisfy a product request by modifying the technical foundation. It should write product code inside the system the team has chosen.

In a monorepo, this requirement becomes even stronger. The agent can see several worlds at once: frontend, backend, mobile, SDKs, data, infrastructure, documentation, scripts, and shared libraries. That visibility is useful for understanding contracts between components, but it also increases the risk of out-of-scope modifications.

> In an agent-ready monorepo, the agent can see the whole system, but it cannot treat every part of it the same way.

## Separate the technical foundation from product code

The separation between the technical foundation and product code becomes a central principle of AI-native development.

In a traditional codebase, this separation is already useful. In a codebase worked on by agents, it becomes critical. If an agent can modify UI primitives, scripts, configuration, repository rules, base components, and business features indiscriminately, every product request can become platform debt and create platform drift across projects within the same team.

Two zones should therefore be distinguished.

The first is the foundation layer. It contains the project structure, conventions, base components, configuration, scripts, CLI workflows, agent rules, validation mechanisms, reusable capabilities, and technical documentation. This layer changes less often and under tighter control.

The second is the product layer. It contains business features, specific screens, application domains, product APIs, business models, business prompts, business rules, product documentation, and feature specifications. This is the main daily intervention area for agents.

The rule should be simple:

> If a change can be made in the product layer, it should not be made in the foundation layer.

This separation protects the architecture. It also makes the foundation upgradeable. A template or technical foundation can evolve cleanly only if the team still knows which files belong to the framework and which files belong to the product.

This is exactly the kind of boundary an AI-native development system should materialize: a clean, testable, documented, and upgradeable full-stack foundation, with a strict separation between Forge-owned and Project-owned paths, a machine-readable contract, validations, evidence, and a durable workflow that does not depend on chat memory.

## Not every change deserves the same ritual

The opposite mistake would be to respond to the chaos of vibe coding with generalized bureaucracy. If every micro-change requires a full specification, the team will kill the speed that makes agents useful.

An AI-native method should calibrate the level of structure to the real impact of the change. I see four development modes.

The first mode is **foundation evolution**. It covers foundation-level changes: a new template, a new shared capability, an evolution of the design system, a backend architecture change, changes to agent rules, the addition of a CLI workflow, or changes to validation scripts. This mode is risky because it changes the rules agents will use to code tomorrow. This foundation is usually shared across several projects; it is the team’s technical base, and it should generally be isolated.

> Changing the foundation means changing the rules under which agents will build the next features.

The second mode is **spec-driven feature**. It covers significant features: a new business workflow, a new API, a complete new page, integration across several components, AI processing inside a pipeline, or a new mobile, data, or infrastructure capability. Here, the specification is useful because it stabilizes intent before execution. The process becomes more structured, close to what a method like Spec Kit proposes. When the feature is complex, it is better to iterate on the specification than on the code.

The third mode is **guided coding**. It covers bounded but non-trivial needs: connecting backend data to an existing interface, adding an option to a process, fixing a reproducible bug with a regression test, or adjusting an existing AI flow. You do not launch a full specification machine, but you do produce a short plan, a tracker, clean context, and targeted validation.

> Guided coding is the mode for a short brief, a short plan, and controlled execution.

The fourth mode is **controlled vibe coding**. It remains appropriate for micro-adjustments: fixing a label, moving a button, improving an empty state, adjusting a color with existing tokens, testing a visible variant, or improving a business prompt. The conversation keeps its value, but the scope must remain local, reversible, and subject to the repository’s rules.

> Vibe coding keeps its value when it remains local, reversible, and governed by repository rules.

These modes are not opposed to each other. They form a scale. The more cross-cutting, durable, or risky a change is, the more it should move toward structured modes. The more local, observable, and reversible it is, the more it can stay in lightweight modes. And in practice, teams often use **controlled vibe coding** after a **guided coding** or **spec-driven feature** phase, inside the same context, to adjust and finalize a feature.

> An AI-native method does not impose the same ritual on every task. It imposes the right level of ritual for each type of change.

## Spec-driven development is necessary, but not universal

Specification-driven development is a major step forward for coding agents. GitHub introduced Spec Kit as an open source toolkit for bringing a structured process into coding-agent workflows, especially around specification, planning, task breakdown, and implementation. ([The GitHub Blog][3])

The Spec Kit documentation positions spec-driven development as a method that puts the specification at the center of AI-assisted development: you describe what needs to be built, refine it through structured phases, then let the agent implement it. ([GitHub Pages][4]) The Spec Kit repository also describes a workflow in which implementation checks that prerequisites are present — constitution, spec, plan, and tasks — before executing tasks in the planned order. ([GitHub][5])

This approach addresses an obvious weakness of vibe coding: intent changes, gets diluted, or remains implicit. The spec becomes a living artifact. It clarifies the user problem, the expected result, business rules, interactions, and success criteria. The plan then translates that intent into the project’s constraints: architecture, stack, security, performance, design system, authorized paths, tests, and validations.

But spec-driven development should not become a universal answer. A spec is not free. It consumes time, context, tokens, review effort, and attention. It can be disproportionate for a local fix or a quick iteration. It can also become unmanageable if the feature is too broad and the team tries to compensate with a giant checklist.

The operational rule should be simpler:

> An AI-native feature should map to a branch, a PR, a short spec, a plan, a linear task list, validations, and evidence.

In other words, the right unit of work remains **the reviewable feature**. This brings us back to the same lessons as classical software development. If the need does not fit into a branch and a readable PR, the answer is not to make the workflow more complex. The answer is to split the need.

## The plan becomes the context compiler

The repository imposes the project’s structure and rules. The specification and the plan stabilize intent. But one more operational question remains: how do we make agents respect all of this during execution?

The central topic in AI-native development is not prompt engineering. It is context engineering: selecting, compressing, and organizing what the agent sees instead of piling more and more information into the context window. Martin Fowler and Thoughtworks also describe this shift as a central topic for coding agents. ([Martin Fowler][15])

An agent should not reread the entire repository for every task. It should not receive a massive dump of documentation, files, conventions, and conversation fragments. It should receive the right context at the right time.

This is where the development plan, as it appears in spec-driven approaches, changes in nature. It should not be a simple checklist. It should also become a context compiler.

The plan compiles two kinds of context.

First, workflow context: the chosen development mode, mandatory steps, tracker to maintain, expected validations, evidence to produce, stop conditions, recovery rules, and execution-summary format.

Second, repository context: the relevant architecture, authorized paths, protected paths, reusable patterns, existing components, testing conventions, validation commands, and allowed or forbidden dependencies.

This logic matches a broader trend in coding-agent tooling. In its analysis of the Codex agent loop, OpenAI describes the role of the harness as orchestrating the user, the model, and the tools used to produce real software work, including context, instructions, and tool calls. ([OpenAI][6]) Codex Skills point in the same direction: they use progressive disclosure, where the agent loads the full instructions for a skill only when it decides they are necessary. ([OpenAI Developers][7])

The principle is fundamental: context should not be accumulated without limit. It should be selected, compressed, structured, and made operational.

> Good agentic context is not a summary of the repository. It is a mission order derived from the plan.

A task packet should contain only what the agent needs to execute a task: objective, scope, authorized paths, forbidden paths, files likely involved, patterns to reuse, validation commands, completion criteria, stop conditions, and expected evidence.

> The plan is where general project rules are transformed into task-specific context for agentic execution.

Work on Spec Kit Agents points to the same problem from another angle: in large repositories, agents easily become “context blind,” hallucinate APIs, or violate architectural constraints. Their response is to add grounding and validation hooks to each phase of the workflow, so decisions are anchored in repository evidence. ([arXiv][17])

## The workflow must belong to the system, not to the agent’s memory

We should not ask an agent to remember the entire method for several hours. The workflow must be encoded in an external system: a CLI, a local orchestrator, a pipeline, or scripts.

The agent executes. The system orchestrates and verifies.

This distinction is decisive. An agent can propose a plan, modify code, run commands, explain decisions, and produce a synthesis. But it should not be the sole judge of its own execution. It can forget a step, declare completion too early, skip tests, modify a forbidden zone, lose tracker consistency, or produce a summary that is more optimistic than reality.

A CLI workflow should therefore create the unit of work, select the development mode, record the brief, generate or validate the spec if needed, produce the plan, create the tracker, compile task packets, call the agentic runner, check modified files, verify forbidden paths, run or request validations, record evidence, update the machine state, and prepare the PR summary.

Codex CLI illustrates the possible role of a local runner: OpenAI’s documentation describes it as a coding agent executable from the terminal, capable of reading, modifying, and running code on the machine in the selected directory. ([OpenAI Developers][8]) But the runner should not carry the whole method. Codex, Claude Code, Copilot, Gemini CLI, or other agents may change. The repository and the workflow should remain.

That is also the point of harness engineering: treat the repository as a structured knowledge system, give the agent a map rather than a thousand-page manual, and place the rules in an environment that the workflow can use. ([OpenAI][14])

> The model may change. The repository and the workflow remain. The method must therefore belong to the development system, not to the model.

## Evidence becomes a development artifact

In AI-native development, evidence should not be reduced to test logs or command outputs. It becomes the set of artifacts that connect the initial intent, the execution plan, the completed tasks, the validations obtained, and the behavior actually delivered.

A feature may start with a complete specification, a short guided-coding plan, or a controlled conversational patch. But at merge time, it should close with a clear trace: what was requested, what was planned, what was done, what changed along the way, what was validated, and what was ultimately delivered.

In a spec-driven process, the initial specification is therefore not the final word. It is the starting hypothesis. During execution, the plan may evolve, guided corrections may be added, and local adjustments may finalize the branch. The PR should then produce or update a final specification: not the ideal spec from the beginning, but a faithful description of the system that is actually merged.

The initial specification expresses intent. The final specification describes the delivered product.

This logic does not replace Git. It strengthens it. GitHub describes pull requests as a central collaboration mechanism for proposing, discussing, and reviewing changes before merge, helping teams work together, detect issues, and maintain quality. ([GitHub Docs][9]) In an AI-native workflow, the branch becomes the execution space, and the PR becomes the convergence point for code, plan, evidence, decisions, validations, and final specification.

These artifacts have two audiences. For humans, they explain what was done without requiring anyone to reread the entire conversation with the agent: brief, plan, decisions, deviations, validations, PR summary, and final specification. For the CLI, they structure execution: tracking files, task state, plan phases, authorized paths, expected validations, and recorded evidence.

The plan carries the context. The tracker carries the state. The prompt triggers execution.

An agentic task should therefore not be launched with a simple “continue the feature.” It should be located inside a plan, a phase, a branch, a tracking file, a scope, and a set of expected validations. That trace is what makes the work auditable, resumable, and reviewable.

AI-native development should not only produce code. It should produce the verifiable memory of its own execution.

This idea aligns with recent work that formalizes the shift from vibe coding to verified engineering as a process-control problem: specify, constrain, orchestrate, prove, and verify, rather than merely improving prompts. ([arXiv][16])

## Granularity is also an economic problem

In spec-driven approaches, task size is not only a methodological issue. It is an economic issue.

A task that is too small is expensive in context, orchestration, validation, and recovery. A task that is too large increases the risk of drift, unreadable diffs, hidden debt, and impossible review.

The right batch should be broad enough to amortize context cost, coherent enough to stay within a single intent, bounded enough to fit in one PR, and verifiable enough to produce solid evidence.

Too large: “rebuild the whole application, add permissions, change the design system, and migrate the database.”

Too small: “create the empty file for the filter button component.”

Good granularity: “implement the customer list with API loading, empty/error/loading states, pagination, and rendering tests, using existing components.”

Granularity becomes the central economic parameter because it determines token cost, time cost, validation cost, human review cost, divergence risk, cognitive fatigue, recovery cost, and integration cost.

> Granularity is the central economic parameter of agent-based development.

## A simple method for AI agent-based coding

Moving toward industrial AI-native development does not mean declaring that agents will write all software tomorrow. It means something more concrete and more useful: defining a simple method for working with agents without losing control of the code.

That method rests on four building blocks. The repository carries the rules: architecture, conventions, authorized paths, protected paths, scripts, validations, reusable patterns, and operational documentation. The workflow enforces those rules instead of leaving them in chat memory. The plan transforms intent into execution context: chosen mode, scope, tasks, affected paths, validations, and stop conditions. Evidence makes the work reviewable: what was requested, what was done, what changed, what was validated, and what may still need to be handled.

This framework does not oppose vibe coding. It puts it in the right place. Teams should still be able to prototype quickly, fix locally, adjust an interface, or explore an idea without producing a complete spec. But as soon as a change becomes durable, cross-cutting, or difficult to review, it should move toward a more structured mode: guided coding, spec-driven feature, or foundation evolution.

This framework is not only for teams. A solo developer already benefits from it immediately: easier recovery after interruption, less drift, better technical memory, more systematic validation, and changes that are easier to review. In a team, the same principles become even more important because they make rules shareable across roles, allow several agents to work in the same repository, and preserve collective responsibility for delivered code.

At this point, the prompt remains useful, but it is no longer the center of the system. The prompt expresses the intent of the moment. The repository carries the rules. The plan compiles the useful context. The workflow orchestrates, controls, and traces. Evidence makes the work readable, recoverable, and maintainable.

That, ultimately, is what it means to industrialize AI agent-based coding: stop treating the agent as an isolated conversation partner, and start treating it as a powerful contributor embedded in a simple, verifiable, and shareable working method. A method lightweight enough to preserve speed, explicit enough to work alone or in a team, and robust enough to keep delivered code understandable, maintainable, and reviewable.

## References

<div class="article-references" markdown>

1. [Good Vibrations? A Qualitative Study of Co-Creation, Communication, Flow, and Trust in Vibe Coding][1]
2. [Vibe Coding in Practice: Motivations, Challenges, and a Future Outlook — a Grey Literature Review][2]
3. [Spec-driven development with AI: Get started with a new open source toolkit][3]
4. [Spec Kit Documentation][4]
5. [github/spec-kit][5]
6. [Unrolling the Codex agent loop][6]
7. [Agent Skills — Codex][7]
8. [Codex CLI][8]
9. [About pull requests][9]
10. [Manifesto for Agile Software Development][10]
11. [AGENTS.md][11]
12. [Custom instructions with AGENTS.md — Codex][12]
13. [Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?][13]
14. [Harness engineering: leveraging Codex in an agent-first world][14]
15. [Context Engineering for Coding Agents][15]
16. [Agentic Agile-V: From Vibe Coding to Verified Engineering in Software and Hardware Development][16]
17. [Spec Kit Agents: Context-Grounded Agentic Workflows][17]

</div>

[1]: https://arxiv.org/abs/2509.12491 "Good Vibrations? A Qualitative Study of Co-Creation, Communication, Flow, and Trust in Vibe Coding"
[2]: https://arxiv.org/abs/2510.00328 "Vibe Coding in Practice: Motivations, Challenges, and a Future Outlook — a Grey Literature Review"
[3]: https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/ "Spec-driven development with AI: Get started with a new open source toolkit"
[4]: https://github.github.com/spec-kit/ "Spec Kit Documentation"
[5]: https://github.com/github/spec-kit "github/spec-kit"
[6]: https://openai.com/index/unrolling-the-codex-agent-loop/ "Unrolling the Codex agent loop"
[7]: https://developers.openai.com/codex/skills "Agent Skills — Codex"
[8]: https://developers.openai.com/codex/cli "Codex CLI"
[9]: https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests "About pull requests"
[10]: https://agilemanifesto.org/ "Manifesto for Agile Software Development"
[11]: https://agents.md/ "AGENTS.md"
[12]: https://developers.openai.com/codex/guides/agents-md "Custom instructions with AGENTS.md — Codex"
[13]: https://arxiv.org/abs/2602.11988 "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?"
[14]: https://openai.com/index/harness-engineering/ "Harness engineering: leveraging Codex in an agent-first world"
[15]: https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html "Context Engineering for Coding Agents"
[16]: https://arxiv.org/abs/2605.20456 "Agentic Agile-V: From Vibe Coding to Verified Engineering in Software and Hardware Development"
[17]: https://arxiv.org/abs/2604.05278 "Spec Kit Agents: Context-Grounded Agentic Workflows"
