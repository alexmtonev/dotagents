---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. A question that hangs on another question still open this round belongs to a _later_ round.

Ask the whole frontier in one round through your harness's question tool (`AskUserQuestion` in Claude Code), with your recommended answer as each question's first option. Keep options to label and description; a `preview` hides the numbered free-text option. Spread a frontier too big for one call across back-to-back calls; with no question tool, ask it as a numbered list. Then wait for the user's answers.

Each answer reshapes the tree: settled decisions push the frontier outward and unblock the questions that hung on them. Recompute the frontier and ask the next round.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it. Keep the round moving: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for its report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
