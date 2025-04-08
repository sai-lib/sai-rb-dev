# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the Sai color library.

ADRs are used to document significant architectural decisions made during the development of the project. Each ADR
describes the context, the decision that was made, alternatives that were considered, and the consequences of the
decision.

## Index of ADRs

* [ADR 001: Module Naming Conventions](./001-module-naming-conventions.md)
* [ADR 002: External Dependency Policy](./002-external-dependency-policy.md)
* [ADR 003: Object Immutability Policy](./003-object-immutability-policy.md)
* [ADR 004: Error Handling Policy](./004-error-handling-policy.md)
* [ADR 005: API Design Principles](./005-api-design-principles.md)
* [ADR 006: Performance Considerations](./006-performance-considerations.md)
* [ADR 007: Documentation Standards](./007-documentation-standards.md)
* [ADR 008: Versioning and Deprecation Policy](./008-versioning-and-deprecation-policy.md)
* [ADR 009: Enum System for Magic Value Elimination](./009-enum-system-for-magic-value-elimination.md)

## ADR Statuses

|                                     Status                                      | Description                                                       |
|:-------------------------------------------------------------------------------:|-------------------------------------------------------------------|
|   ![Proposed](https://img.shields.io/badge/Proposed-blue?style=for-the-badge)   | A decision is being considered but has not been finalized         |
|    ![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)     | A decision has been accepted and is currently being implemented   |
| ![Deprecated](https://img.shields.io/badge/Deprecated-red?style=for-the-badge)  | A decision has been superseded by a new decision                  |
| ![Superseded](https://img.shields.io/badge/Superseded-gray?style=for-the-badge) | A decision that is no longer relevant (superseded by another ADR) |

## Creating New ADRs

When creating a new ADR, use the following naming convention:

```
NNN-short-title.md
```

Where `NNN` is the next sequential number after the highest existing ADR number.

Each ADR should follow this general template structure:

```markdown
# ADR NNN: Title

## Status

[Proposed | Active | Deprecated | Superseded] (use one of the badges above)

## Context

[Describe the problem or situation that led to this decision]

## Decision

[Describe the decision that was made]

## Alternatives Considered

[Describe alternatives that were considered and why they were rejected]

## Consequences

### Positive

[Describe positive consequences of the decision]

### Negative

[Describe negative consequences or trade-offs of the decision]

## Implementation Notes

[Any specific notes about implementation of the decision]
```
