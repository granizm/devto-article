---
title: "Orchestrating Multiple AI Agents with Claude Code Agent Teams"
published: false
description: "Learn how to coordinate multiple Claude Code instances working together as a team for parallel code reviews, debugging, and feature development"
tags: claudecode, ai, programming, productivity
---

## Introduction

Have you ever wished you could have multiple AI assistants working together on a complex task? Claude Code's new experimental "Agent Teams" feature makes this possible by letting you coordinate multiple Claude Code instances as a team.

In this article, I'll walk you through how Agent Teams work, when to use them, and share practical examples to get you started.

## What Are Agent Teams?

Agent Teams let you coordinate multiple Claude Code instances working together. One session acts as the **team lead**, coordinating work and assigning tasks. **Teammates** work independently, each in their own context window, and can communicate directly with each other.

Unlike subagents that can only report back to the main agent, teammates can:
- Message each other directly
- Share findings and challenge each other's conclusions
- Coordinate through a shared task list

## Agent Teams vs Subagents

| Feature | Subagents | Agent Teams |
|---------|-----------|-------------|
| Context | Own window; results return to caller | Own window; fully independent |
| Communication | Report to main agent only | Direct teammate messaging |
| Coordination | Main agent manages all work | Shared task list with self-coordination |
| Best for | Focused tasks where only results matter | Complex work requiring collaboration |
| Token cost | Lower | Higher |

## Getting Started

### Enable Agent Teams

Agent Teams are disabled by default. Add this to your `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Choose Your Display Mode

Two display modes are available:

- **In-process**: All teammates run in your main terminal. Use Shift+Up/Down to switch between them.
- **Split panes**: Each teammate gets its own pane. Requires tmux or iTerm2.

```json
{
  "teammateMode": "in-process"
}
```

## Best Use Cases

### 1. Parallel Code Review

Instead of one reviewer gravitating toward one type of issue, split criteria into independent domains:

```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

### 2. Competing Hypothesis Debugging

When the root cause is unclear, multiple investigators actively trying to disprove each other leads to better results:

```
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

### 3. New Feature Development

Each teammate can own a separate piece without stepping on each other:

```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

## Task Management

The shared task list coordinates work across the team:

- **Task states**: pending, in progress, completed
- **Dependencies**: tasks can depend on other tasks
- **Claiming**: teammates can self-claim or be assigned by the lead

### Delegate Mode

Press Shift+Tab to enable delegate mode, which restricts the lead to coordination-only tools—no implementing, just orchestrating.

## Best Practices

### 1. Provide Enough Context

Teammates don't inherit the lead's conversation history. Include task-specific details in the spawn prompt:

```
Spawn a security reviewer teammate with the prompt: "Review the authentication module
at src/auth/ for security vulnerabilities. Focus on token handling, session
management, and input validation."
```

### 2. Size Tasks Appropriately

- **Too small**: Coordination overhead exceeds the benefit
- **Too large**: Long work without check-ins, wasted effort risk
- **Just right**: Self-contained units with clear deliverables

### 3. Avoid File Conflicts

Two teammates editing the same file leads to overwrites. Break work so each teammate owns different files.

### 4. Monitor Progress

Check in on teammates, redirect approaches that aren't working, and synthesize findings as they come in.

## Known Limitations

- No session resumption with in-process teammates
- One team per session
- No nested teams (teammates can't spawn their own teams)
- Split panes not supported in VS Code terminal or Windows Terminal

## Conclusion

Claude Code Agent Teams opens up new possibilities for parallel work on complex tasks. Whether you're doing code reviews, debugging tricky issues, or developing new features, having multiple AI agents collaborate can significantly speed up your workflow.

Start with research and review tasks to get comfortable with the coordination model, then expand to more complex scenarios.

**Have you tried Agent Teams? Share your experience in the comments!**

## Resources

- [Official Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)
- [Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
