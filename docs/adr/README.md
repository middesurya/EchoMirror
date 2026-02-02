# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records for EchoMirror.

## What is an ADR?

An ADR is a document that captures an important architectural decision made along with its context and consequences.

## ADR Index

| ID | Title | Status | Date |
|----|-------|--------|------|
| [001](001-on-device-ml.md) | On-Device ML for Privacy-First Analysis | Accepted | Jan 2026 |
| [002](002-riverpod-state-management.md) | Riverpod for State Management | Accepted | Jan 2026 |

## Template for New ADRs

```markdown
# ADR XXX: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
[What is the issue that we're seeing that is motivating this decision?]

## Decision
[What is the change that we're proposing and/or doing?]

## Rationale
[Why did we choose this approach?]

## Consequences
[What becomes easier or harder as a result?]

## Alternatives Considered
[What other options were evaluated?]

## References
[Links to relevant resources]
```

## Why ADRs?

- **Onboarding**: New team members understand why decisions were made
- **Consistency**: Prevents re-litigating settled decisions
- **Learning**: Documents trade-offs for future reference
- **Portfolio**: Shows technical decision-making ability to employers
