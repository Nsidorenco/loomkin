# Loomkin Community Growth Playbook

War plan for getting Loomkin from "cool side project" to "the Elixir AI framework people actually use."

---

## 1. Nerd-Sniping Elixir Devs

The pitch is simple: **every AI agent is a GenServer, and it turns out the BEAM was designed for this 30 years ago.**

### Key Talking Points (What Makes Elixir Devs Lean Forward)

1. **Each agent is a GenServer under a DynamicSupervisor.** Spawn in <500ms. If an agent crashes, the supervisor restarts it. No orchestration framework needed — OTP *is* the orchestration framework.
2. **Inter-agent communication is PubSub, not JSON files on disk.** Microsecond latency. No polling. Agents subscribe to topics like `"team:#{team_id}"` and receive messages instantly.
3. **LiveView for real-time agent monitoring — zero JavaScript.** 13 components including streaming chat, interactive SVG decision graph, team dashboard. All server-rendered, all real-time.
4. **GenServer state IS agent memory.** No external vector DB for short-term context. The process *is* the agent. Context offloads to Keeper processes (also GenServers) instead of being summarized away.
5. **10 cheap agents for ~$0.25 vs one Opus call for ~$4.50.** The BEAM's lightweight process model makes agent swarms economically viable. You can run 100+ agents per node.
6. **Hot code reloading works on running agents.** Update tools, swap providers, tweak prompts — agents keep running, sessions keep their state.
7. **Region-level file locking for concurrent edits.** Multiple agents editing the same file, claiming line ranges. This is a concurrency problem, and Elixir eats concurrency problems for breakfast.

### Draft Forum Posts

#### Elixir Forum (forum.elixirforum.com)

**Title options (pick one):**
- "We built an AI agent system where each agent is a GenServer — turns out OTP was designed for this"
- "Loomkin: AI coding agents on the BEAM — GenServers, PubSub, LiveView, zero JS"
- "What if each AI agent was a GenServer under a supervision tree?"

**Post structure:**

> We've been building Loomkin, an open-source AI agent orchestration platform in Elixir/Phoenix. The core insight: an AI agent is just a long-running stateful process that receives messages and produces side effects. That's literally what GenServer was built for.
>
> Each agent is a GenServer under a DynamicSupervisor. They communicate via PubSub (microseconds, not the seconds-scale polling you see in Python/JS agent frameworks). If an agent crashes mid-task, the supervisor restarts it and it picks up from its persisted decision graph.
>
> Some numbers:
> - Agent spawn: <500ms (GenServer.start_link)
> - Inter-agent latency: microseconds (PubSub)
> - Context preserved: 228K+ tokens (vs 128K with lossy summarization)
> - Cost: 10 cheap agents ~$0.25 vs single expensive model ~$4.50
> - 925+ tests, ~20K LOC, 16 LLM providers, 665+ models
>
> The web UI is pure LiveView — 13 components, zero JavaScript. Streaming chat, interactive SVG decision graph, real-time team dashboard.
>
> Built on top of [Jido](https://github.com/agentjido/jido) for the action/tool system and [req_llm](https://github.com/agentjido/req_llm) for the LLM layer.
>
> GitHub: https://github.com/bleuropa/loomkin
> Site: https://loomkin.dev
>
> Would love feedback from the community. We're actively looking for contributors — there are good-first-issue labels if you want to dive in.

**Where to post:** "Showcase" or "Your Libraries" category. Cross-post a shorter version to "General Discussion" with a question angle: *"Has anyone else explored using OTP primitives for AI agent orchestration?"*

#### Reddit r/elixir

**Title options:**
- "We built an AI agent platform where each agent is a GenServer — OTP was made for this"
- "Loomkin: open-source AI coding agents in Elixir. GenServers for agents, PubSub for comms, LiveView for UI. Zero JS."

**Post:** Shorter version of the forum post. Lead with the GenServer angle. Include a screenshot of the LiveView UI. End with "looking for contributors."

**Also post to:** r/programming (broader audience, lead with the "supervision trees for fault-tolerant AI" angle), r/LocalLLaMA (if/when local model support is solid).

#### Hacker News (news.ycombinator.com)

**Title:** "Show HN: Loomkin - AI agent teams built on Erlang/OTP (each agent is a GenServer)"

HN loves:
- Technical depth over marketing
- Novel architectural choices with clear reasoning
- Open source with real code to read
- Contrarian takes backed by evidence

**Comment to post immediately after submission (prevents the "what is this" void):**

> Author here. The key insight: AI agents are long-running stateful processes that receive messages and produce side effects. Erlang/OTP has solved this exact problem for 30 years with GenServers, supervision trees, and message passing.
>
> Compared to Python/JS agent frameworks:
> - Agent spawn: <500ms vs 20-30s
> - Inter-agent messaging: microsecond PubSub vs JSON files polled from disk
> - Fault tolerance: OTP supervisors auto-restart crashed agents vs lost sessions
> - Concurrency: 100+ lightweight processes vs 3-5 practical limit
>
> The decision graph (a PostgreSQL-backed DAG) gives agents persistent memory across sessions — not just chat history, but structured reasoning about goals, tradeoffs, and rejected approaches.
>
> ~20K LOC Elixir, 925+ tests, MIT licensed.

**Timing:** Post Tuesday-Thursday, 8-10am EST. Avoid weekends and Mondays.

### Secondary Posts (Drip Over Weeks)

After the initial launch post, follow up with focused technical posts:

1. **"How we use OTP supervision trees for fault-tolerant AI agents"** — deep dive into the supervision structure, restart strategies, what happens when an agent crashes mid-edit
2. **"Decision graphs: giving AI agents persistent memory that isn't just chat history"** — the DAG structure, confidence cascades, pulse reports
3. **"LiveView for AI: building a real-time agent dashboard with zero JavaScript"** — 13 components, streaming, interactive SVG
4. **"Why cheap model swarms beat expensive single models (with numbers)"** — cost analysis, the model escalation chain, per-agent model selection

---

## 2. Good First Issues

### Trivial (Docs / Formatting / Config) — "I want to contribute but I've never touched this codebase"

1. **Add typespecs to public functions in `lib/loomkin/decisions/graph.ex`** — the decision graph module has public functions without `@spec`. Add them. Learn the codebase by reading function signatures.

2. **Add `@moduledoc` to modules that are missing them** — grep for `@moduledoc false` or missing moduledocs. Write clear one-liners. Forces reading code to understand what modules do.

3. **Improve `.loomkin.toml` configuration docs** — the README mentions it but `docs/configuration.md` could use more examples: custom roles, permission patterns, model escalation chains.

4. **Add mix task descriptions** — ensure all custom mix tasks have proper `@shortdoc` and `@moduledoc` for `mix help` output.

### Easy (Small Features / Bug Fixes) — "I know some Elixir"

5. **Add a `--json` flag to the cost dashboard** — the `/dashboard` shows cost analytics in LiveView. Add a JSON API endpoint that returns the same data. Useful for CI integration.

6. **Add session duration tracking** — sessions track token costs but not wall-clock duration. Add a `started_at`/`ended_at` to the session schema and display it in the UI.

7. **Add a "copy to clipboard" button for agent responses** — small LiveView/JS hook. The workspace shows agent output; let users copy it.

8. **Configurable PubSub topic prefix** — currently hardcoded as `"team:#{team_id}"`. Make configurable for multi-tenant deployments.

9. **Add ExDoc for HexDocs publication** — set up `ex_doc` in `mix.exs` with proper grouping, extras, and logo. Prepare for Hex publication.

10. **File watcher ignore patterns from `.loomkin.toml`** — the file watcher respects `.gitignore` but not project-specific ignore patterns. Read additional patterns from the config file.

### Medium (Meaningful but Scoped) — "I want to build something real"

11. **Implement a `/health` endpoint** — return JSON with: app version, connected LLM providers, database status, active sessions count, agent count. Useful for deployment monitoring.

12. **Add Prometheus/Telemetry.Metrics export** — Loomkin already has telemetry events. Wire them to `telemetry_metrics_prometheus` so users can scrape metrics.

13. **Session export to Markdown** — export a session's full conversation (messages, tool calls, decisions) as a structured Markdown file. Good for post-mortems and documentation.

14. **Dark mode toggle for the LiveView UI** — the UI currently has one theme. Add a toggle that persists to localStorage via a JS hook and applies Tailwind dark classes.

15. **Rate limit visualization** — the token bucket rate limiter exists but has no UI. Show a simple progress bar per agent showing their remaining budget vs consumed.

---

## 3. Social Game Plan

### Initial Burst (Week 1-2)

The goal is to hit critical mass on the Elixir Forum post so it stays on the front page for multiple days. Elixir is a small community — 50 stars and 10 forum replies is a successful launch.

**Day 1: Launch day**
- Post to Elixir Forum (showcase category)
- Post to r/elixir
- Submit to HN (Show HN)
- Tweet thread from project account
- Post in Elixir Slack #general and #showcase
- Post in relevant Discord servers (Jido, if they have one; Elixir-related Discords)

**Day 2-3: Engage**
- Respond to every comment on every platform. Depth matters more than speed.
- If HN gets traction, post the follow-up technical comment

**Day 7: Follow-up post**
- "Week 1 building in public: what we learned from launching Loomkin" — share metrics, feedback received, what changed

**Day 14: Technical deep-dive**
- Post the first focused technical article (supervision trees for AI agents)

### Sustained Cadence (Ongoing)

- **Weekly:** One technical post or update on Elixir Forum / blog / Twitter
- **Bi-weekly:** Release notes with contributor shoutouts
- **Monthly:** Architecture decision record (ADR) post — share *why* you made choices, not just what you built
- **Every PR merged from a contributor:** Public thank-you on Twitter/Discord with their handle

### Discord Community Structure

Server: Already exists (badge in README links to https://discord.gg/WUVneqArVD)

**Channels:**
```
#announcements        — releases, breaking changes, blog posts (read-only for non-admins)
#general              — anything goes
#help                 — setup issues, usage questions
#contributing         — coordinating on issues, PR reviews, architecture discussions
#show-and-tell        — users sharing what they built with Loomkin
#ideas                — feature requests, brainstorming
#decision-graph       — specifically for the decision graph system (it's complex enough to warrant its own channel)
#llm-providers        — model recommendations, provider issues, cost tips
```

**Welcome flow:**
- Bot posts a welcome message with:
  1. Link to README
  2. Link to good-first-issues
  3. "What are you interested in?" role picker (user / contributor / just watching)
- Pin a "start here" message in #general with setup instructions and the architecture diagram

### Twitter/X Strategy

**Account:** @loomkin_dev (or similar)

**Content mix:**
- 40% Technical insights ("TIL: GenServer.handle_continue is perfect for post-spawn agent initialization because...")
- 30% Progress updates ("Just merged: region-level file locking for concurrent agent edits. 3 agents editing the same file, zero conflicts.")
- 20% Community (retweets of contributors, responses to Elixir community posts)
- 10% Comparisons/hot takes ("Agent spawn time: Python framework: 25 seconds. Loomkin: 480ms. The BEAM doesn't care how many agents you want.")

**Do NOT:**
- Post generic "AI is the future" content
- Engage in framework wars (be respectful of LangChain, CrewAI, etc.)
- Post more than 2x/day

**DO:**
- Quote-tweet Elixir community members who post about AI/LLM topics
- Respond to every mention
- Share code snippets with syntax highlighting (Elixir code is visually distinctive and beautiful)

### Conference Talk Pitches

#### ElixirConf (US and EU)

**Title:** "AI Agents on the BEAM: Why GenServers Are the Best Agent Runtime Nobody's Using"

**Abstract:**
> Every AI agent framework reinvents the wheel: process management, message passing, fault tolerance, state management. Erlang/OTP solved all of these in 1986. This talk shows how Loomkin uses GenServers as agents, supervision trees for fault tolerance, PubSub for microsecond inter-agent communication, and LiveView for real-time monitoring — turning the BEAM into the most capable AI agent runtime available. We'll cover real production patterns: decision graphs for persistent agent memory, context mesh for zero-loss context management, and why 10 cheap model agents outperform one expensive model. Live demo included.

**Format:** 40-minute talk with live demo

#### Code BEAM (EU, America, Lite)

**Title:** "OTP Design Patterns for AI Agent Orchestration"

**Abstract:** Focus more on the OTP patterns and less on the AI hype. Code BEAM audiences are deep BEAM enthusiasts. Emphasize: how GenServer state maps to agent memory, how supervision strategies map to agent fault tolerance, how Registry + PubSub creates a zero-config service mesh for agents.

#### FOSDEM (Erlang/Elixir devroom)

**Title:** "The BEAM as an AI Agent Runtime: A Case Study"

**Abstract:** Short (25 min). Focus on benchmarks: spawn time, message latency, memory per agent, max concurrent agents. Compare to Python/JS frameworks with real numbers.

#### Nerves Conf / Embedded Elixir

**Pitch angle:** "AI agents on embedded devices" — Loomkin's lightweight process model could run local agents on Nerves devices. This is aspirational but plants a seed.

---

## 4. README Badges to Add

Current badges: Discord only.

Add these (in order of importance):

```markdown
[![CI](https://github.com/bleuropa/loomkin/actions/workflows/ci.yml/badge.svg)](https://github.com/bleuropa/loomkin/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Discord](https://img.shields.io/discord/1465498806698119317?color=5865F2&logo=discord&logoColor=white&label=Discord)](https://discord.gg/WUVneqArVD)
[![Elixir](https://img.shields.io/badge/Elixir-1.18+-4B275F?logo=elixir&logoColor=white)](https://elixir-lang.org)
[![Phoenix](https://img.shields.io/badge/Phoenix-1.7+-FD4F00?logo=phoenix-framework&logoColor=white)](https://www.phoenixframework.org)
[![GitHub stars](https://img.shields.io/github/stars/bleuropa/loomkin?style=social)](https://github.com/bleuropa/loomkin)
[![Contributors](https://img.shields.io/github/contributors/bleuropa/loomkin)](https://github.com/bleuropa/loomkin/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/bleuropa/loomkin)](https://github.com/bleuropa/loomkin/commits/main)
```

**Why these specific badges:**
- **CI badge:** Signals "this project has tests and they pass." Non-negotiable for credibility.
- **License badge:** MIT is visible at a glance. Reduces friction for corporate contributors.
- **Elixir/Phoenix version badges:** Signals modernity (1.18+, 1.7+). Tells devs immediately if their setup is compatible.
- **Stars badge (social style):** Social proof. The `?style=social` variant is less garish.
- **Contributors badge:** Signals "other people work on this too" (even if it's currently 1-2 people, it grows).
- **Last commit badge:** Proves the project is actively maintained. A stale "last commit: 6 months ago" kills interest immediately.

**Skip for now:**
- Hex badge (not published yet)
- Coverage badge (add once you have Coveralls/Codecov set up)
- Downloads badge (not on Hex yet)

---

## 5. Elixir Ecosystem Integration

### Getting Listed on awesome-elixir

**Repository:** https://github.com/h4cc/awesome-elixir

**Category:** "Artificial Intelligence" (exists but is sparse — perfect opportunity)

**Requirements before submitting:**
1. Stable README with clear description
2. At least 25+ GitHub stars (submit PR after initial launch wave)
3. Working installation instructions
4. License file in repo root

**PR format:**
```markdown
* [Loomkin](https://github.com/bleuropa/loomkin) - AI agent orchestration platform built on OTP. GenServer agents, PubSub communication, LiveView monitoring, decision graphs, 16 LLM providers.
```

**Also submit to:**
- [awesome-phoenix](https://github.com/jonathansick/awesome-phoenix) — under a "AI/ML" or "Tools" category
- [awesome-livebook](https://github.com/lubien/awesome-livebook) — only if you build a Livebook integration (see below)

### Collaboration with Jido

Loomkin already depends on Jido. This is the highest-leverage collaboration.

**Actions:**
1. **Co-announce.** When launching, coordinate with the Jido team. "Loomkin is the first production app built on Jido" is a great story for both projects.
2. **Contribute upstream.** If you've built extensions or found bugs in Jido, contribute them back. Being a visible contributor to your dependency builds credibility.
3. **Joint blog post.** "How Jido's action system powers Loomkin's 28 tools" — publish on both projects' channels.
4. **Link in both READMEs.** Jido's README should mention Loomkin as a "built with Jido" example. Loomkin's already does (Acknowledgments section).

### Collaboration with Livebook

**Opportunity:** Build a Livebook Smart Cell or integration that lets users:
- Connect to a running Loomkin instance
- Visualize decision graphs in Livebook (Kino + VegaLite)
- Inspect agent state interactively
- Run one-off agent tasks from notebook cells

This is a medium-effort, high-visibility integration. Livebook users are exactly the Elixir devs who'd be interested in Loomkin.

### Collaboration with Nerves

Lower priority but interesting angle: "AI agents on embedded devices." The BEAM's small per-process footprint means you could theoretically run lightweight agents on a Raspberry Pi. Even if this is aspirational, mentioning Nerves compatibility in talks and posts gets the Nerves community's attention.

### HexDocs Publication Strategy

**Prerequisites:**
1. Add `ex_doc` to `mix.exs` dependencies
2. Write `@moduledoc` for all public modules (good first issue material)
3. Add typespecs to public functions (also good first issue material)
4. Set up module groups in the ExDoc config:
   ```elixir
   groups_for_modules: [
     "Core": [Loomkin, Loomkin.Session, Loomkin.AgentLoop],
     "Agent Teams": [Loomkin.Teams.Agent, Loomkin.Teams.Manager, ...],
     "Decision Graph": [Loomkin.Decisions.Graph, Loomkin.Decisions.Cascade, ...],
     "Tools": [Loomkin.Tools.FileRead, Loomkin.Tools.Shell, ...],
     "LLM": [Loomkin.LLMRetry, ...],
     "Web UI": [LoomkinWeb.Live.WorkspaceLive, ...]
   ]
   ```
5. Add a logo and custom CSS for branding
6. Publish: `mix hex.publish` (requires Hex account and package ownership)

**Timing:** Publish to Hex after the initial launch wave settles and docs are solid. A half-documented Hex package does more harm than good. Target 2-4 weeks after launch.

**Hex package name:** `loomkin` (check availability first with `mix hex.search loomkin`)

### Additional Ecosystem Touchpoints

- **ElixirWeekly newsletter** (elixirweekly.net) — submit your launch post. They curate Elixir content weekly.
- **Thinking Elixir podcast** — pitch an episode about AI agents on the BEAM. They cover novel Elixir projects.
- **Elixir Radar newsletter** — another submission target.
- **BEAM Radio podcast** — similar pitch, broader BEAM audience.
- **Underjord (Lars Wikman)** — he covers interesting Elixir projects. Reach out directly.

---

## Execution Priority

| Priority | Action | Timeline | Expected Impact |
|----------|--------|----------|----------------|
| P0 | Set up CI + add badges to README | Before launch | Table stakes |
| P0 | Write and post Elixir Forum showcase post | Launch day | Primary community channel |
| P0 | Create 10 good-first-issues on GitHub | Before launch | Contributor funnel |
| P1 | Submit to HN (Show HN) | Launch day | Broad visibility |
| P1 | Post to r/elixir | Launch day | Reddit traffic |
| P1 | Set up Discord channels + welcome flow | Before launch | Community home base |
| P1 | Coordinate announcement with Jido team | Before launch | Mutual amplification |
| P2 | Submit to awesome-elixir | After 25+ stars | Evergreen discoverability |
| P2 | Submit to ElixirWeekly/Elixir Radar | Launch week | Newsletter reach |
| P2 | Pitch Thinking Elixir podcast | Week 2-3 | Deep audience |
| P2 | Submit ElixirConf talk proposal | Next CFP window | Conference credibility |
| P3 | Publish to Hex with HexDocs | Week 3-4 | Ecosystem integration |
| P3 | Build Livebook Smart Cell | Month 2+ | Cross-community reach |
| P3 | Write technical deep-dive series (4 posts) | Weeks 2-8 | Sustained interest |
