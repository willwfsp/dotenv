---
name: grill
description: Interview the user one question at a time to close the gaps in a plan before any code is written. Use after gathering context, or when the user asks to be grilled or to stress-test a plan.
---

# Grill

Turn a vague request into a plan with no open gaps. The user's time is the scarce resource: ask only
what needs their decision.

## Before asking
- Answer from the code, docs, git history and the issue whatever they can answer. Don't ask the user
  about facts you can look up.
- Write down the open questions, most fundamental first: a later answer often depends on an earlier one.

## Asking
- One question per message, on one topic. Wait for the answer.
- Give your recommended answer and a one-line reason. With 2–4 distinct choices, use AskUserQuestion with
  the recommended option first.
- Say why the question matters when it isn't obvious.
- Follow up when an answer opens a new gap or contradicts an earlier one. Point out the contradiction.
- Accept "you decide": take your recommendation and record it as your decision.

## Checkpoint every answer
Write each answer into the plan file immediately (`Decisions`, `Out of scope`, `Verification`, per the
`task-ledger` format), so nothing is lost if the session ends mid-interview.

## Done when
These are settled, from the user or from the code:
- the goal and who or what benefits;
- scope and explicit out-of-scope;
- acceptance criteria someone could check;
- constraints and risks (data, security, compatibility, cost);
- how to verify the result end to end.

Then summarize the decisions in a few lines and ask the user to confirm or correct before moving on.
Typical sessions take 5–20 questions; a large feature can take more. Stop earlier if the user says so.
