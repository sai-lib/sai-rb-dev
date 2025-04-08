# ADR 002: External Dependency Policy

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

As we develop the Sai color library, we need to determine our approach to external dependencies. Dependencies introduce
several considerations:

* They increase the size of the dependency tree
* They create potential security vulnerabilities
* They can introduce breaking changes during version upgrades
* They may have conflicting licenses
* They increase cognitive overhead for contributors
* They can introduce unexpected behavior
* They may have their own dependencies, compounding the above issues

Sai will be a substantial library with comprehensive colorimetry functionality, which makes controlling bloat from
external dependencies particularly important.

## Decision

We will minimize external dependencies and prefer custom-tailored internal implementations whenever feasible. External
dependencies will only be integrated when all of the following criteria are met:

1. The functionality provided by the dependency is **far beyond** the scope of what we can reasonably implement
   ourselves
2. The dependency solves a complex problem that would require significant development time to replicate
3. The dependency has a stable API with a proven track record
4. The dependency's license is compatible with our project
5. The dependency does not introduce excessive sub-dependencies

Each potential dependency must be carefully evaluated against these criteria, and we will document the rationale for
including any dependency that is accepted.

## Alternatives Considered

### Rely Heavily on External Dependencies

* Advantages: Faster development, leveraging community-maintained code
* Disadvantages: Bloated dependency tree, security concerns, version conflicts, license issues
* Rejected as it contradicts our goal of a lightweight, maintainable library

### Zero Dependencies Policy

* Advantages: Complete control, no external risks
* Disadvantages: Reinventing solutions to complex problems, slower development
* Rejected as too restrictive for cases where a dependency provides essential functionality that would be impractical
  to implement

### Case-by-Case Evaluation Without Formal Policy

* Advantages: Flexibility
* Disadvantages: Inconsistent decision-making, potential dependency creep
* Rejected in favor of having clear criteria to guide decisions

## Consequences

### Positive

* Minimal external attack surface
* Reduced risk of breaking changes from dependencies
* Smaller installation footprint
* Better understanding of all code in the project
* Simplified maintenance
* Custom implementations tailored to our specific needs

### Negative

* More code to maintain ourselves
* Potential reinvention of existing solutions
* Longer development time for certain features
* Missing out on community improvements and bug fixes

## Implementation Notes

* All proposed dependencies must be discussed and approved before integration
* Existing dependencies should be periodically reviewed to determine if they're still necessary
* Custom implementations should be well-documented and tested
* When evaluating a dependency, consider:
  * Maintenance activity and community support
  * Size and complexity
  * Performance characteristics
  * API stability
  * Licensing terms
* In rare cases where dependencies are deemed necessary, consider techniques to isolate their impact, such as adapters
  or facades