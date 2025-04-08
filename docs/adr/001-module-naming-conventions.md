# ADR 001: Module Naming Conventions

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

As the Sai color library grows, we need consistent guidelines for organizing and naming modules. Proper namespace
organization impacts code maintainability, discoverability, and the overall developer experience. Without clear
conventions, the codebase risks becoming inconsistent and difficult to navigate.

Sai (彩) means "color" or "coloring" in Japanese, which provides context for some naming decisions.

## Decision

We will adopt the following module naming conventions:

### Flexible Module Nesting

* Module nesting depth should be determined by domain organization needs
* Use deeper nesting to represent hierarchical relationships and categorizations
* Prioritize logical grouping over arbitrary limits on nesting depth

### Namespace Structure

* Top-level domains under `Sai` represent major functional areas
* Sub-domains should represent coherent subsets of functionality
* Internal implementation details can be placed in deeper nested modules

### Avoid Redundancy

* Since "Sai" already means "color," we'll use `Sai::Space` rather than `Sai::ColorSpace`
* Similarly, prefer concise naming that avoids repeating concepts implied by parent modules

### Module Organization

* Group related functionality in appropriate modules
* Common patterns include models, algorithms, core components, utilities, and mixins
* Module names should clearly indicate their purpose and domain

## Alternatives Considered

### Flat Namespace

* Would make the top-level namespace crowded and difficult to navigate
* Lacks categorization of related functionality

### Prefixing Instead of Nesting

* Less intuitive for organization, though may be used in special cases

### Color Space Focused Structure

* Would split related functionality across different namespaces based on color space
* Rejected in favor of functionality-based organization

## Consequences

### Positive

* Logical organization that matches the domain structure
* Clear categorization of related functionality
* Improved discoverability through module hierarchy
* Better IDE support for code navigation and completion
* Namespace that can evolve as the library grows

### Negative

* Potentially longer fully-qualified module names
* Some judgment required for determining appropriate nesting depth
* Module paths might need to be reorganized as the domain understanding evolves

## Implementation Notes

* All code must adhere to these guidelines
* For borderline cases, prefer clarity and consistency over arbitrary rules
* Module structure should reflect domain concepts rather than implementation details
* Consider the impact on users when designing the module hierarchy
* File structure should generally mirror the module structure