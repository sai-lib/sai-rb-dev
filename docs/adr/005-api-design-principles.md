# ADR 005: API Design Principles

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

The Sai library will have a complex API with many interrelated methods across different color models. Without consistent
API design, users will face a steep learning curve and unexpected behaviors. Clear principles will ensure the API feels
cohesive and intuitive despite its complexity.

Colorimetry involves numerous transformation operations, conversions between models, and specialized calculations. To
create a usable and maintainable library, we need to establish consistent patterns that users can rely on across all
components.

## Decision

We will adopt the following API design principles for the Sai library:

### Method Naming Conventions

* Use verb-first naming for actions (e.g., `to_xyz`, `convert_to`, `calculate_distance`)
* Use identical method names for similar operations across different models
* Avoid redundancy in method names (e.g., use `RGB#channels` not `RGB#rgb_channels`)
* Use consistent prefixes:
  * `to_*` for conversions to other models
  * `with_*` for creating new instances with modified properties (supporting the immutability policy from ADR 003)
  * `calculate_*` for computation-heavy operations

### Parameter Design

* Limit positional parameters to a maximum of 2
* Use keyword arguments for:
  * Optional parameters
  * Boolean flags
  * Methods with more than 2 parameters
* Boolean parameters should always be keyword arguments unless they are the only parameter
* Order keyword parameters:
  1. Required parameters alphabetically
  2. Optional parameters alphabetically

### Return Types

* Similar methods should have consistent return types
* Methods should raise exceptions for error conditions rather than returning nil/special values
* Transformation methods should return instances of the appropriate model
* Methods that perform queries should return appropriate data types for their purpose (Boolean, numeric, etc.)
* Return newly created objects rather than mutating existing ones

### Public vs. Private API Boundaries

* Methods should be private by default unless specifically designed for end-user usage
* Public methods should have comprehensive documentation
* Internal implementation details should be private
* Helper methods should be private unless they provide general utility
* Deprecating public APIs:
  1. Mark methods with `@deprecated` tags in documentation
  2. Add console warnings that suggest alternative methods
  3. Remove deprecated methods in the next major version release

### Polymorphism and Conversion

* Use explicit interfaces for polymorphic behavior
* Implement `to_<other>` methods for all model conversions (e.g., `RGB#to_hsl`)
* Method overloading should be used when necessary to support different parameter types
* Conversion chains should be supported (`rgb.to_hsl.to_xyz.to_lab`)
* Each conversion should return a new instance, not mutate the original

### Parameter Design for Conversions

* Conversion methods should accept the same option parameters between models
* Options that affect conversion behavior should be consistently named across all models
* Default option values should be provided where appropriate
* Use enums for options with fixed sets of values

## Alternatives Considered

### Noun-First Method Naming

* Example: `rgb_to_hsl` instead of `to_hsl`
* Rejected as less intuitive and more verbose

### Mutable Objects with Transformations

* Example: `color.convert_to_hsl!` that modifies the object in place
* Rejected due to immutability principles and potential for confusing state changes

### Parameter Objects Instead of Keyword Arguments

* Example: `to_xyz(conversion_params)` instead of `to_xyz(standard: :srgb, gamma: 2.2)`
* Rejected as less intuitive for simple cases, though may be used for very complex parameter sets

### Separate Factory Methods vs. Instance Methods

* Example: `HSL.from_rgb(rgb)` instead of `rgb.to_hsl`
* Rejected as less chainable and intuitive, though both may be supported in some cases

## Consequences

### Positive

* Consistent, predictable API that's easier to learn and remember
* Reduced cognitive load when working with different color models
* Better IDE support through predictable patterns
* Support for method chaining for complex transformations
* Clear boundaries between public and internal APIs

### Negative

* More restrictions on API design may occasionally force less natural interfaces
* Consistent parameter ordering might not always match the most intuitive order for specific methods
* Some duplication in conversion path implementations
* More verbose than approaches that prioritize brevity over consistency

## Implementation Notes

* Use the consistent naming patterns throughout the codebase
* Document API patterns clearly so users understand the conventions
* Create helper methods or base classes to facilitate consistency
* Consider creating API review checklists for pull requests