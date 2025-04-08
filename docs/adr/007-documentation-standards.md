# ADR 007: Documentation Standards

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

The Sai library is transitioning from a terminal color library to a comprehensive colorimetry library, which will
involve a much larger and more complex API surface. Without consistent documentation standards, we risk inconsistent,
incomplete, or unclear documentation that will make the library difficult to use and maintain. This is especially
critical for a scientific library where precision in communication is essential.

## Decision

We will adopt comprehensive YARD-based documentation standards for all code elements in the Sai library, ensuring
consistent, complete, and clear documentation across the entire codebase.

### General Documentation Requirements

* All classes and modules must be documented with a clear description of their purpose and responsibility
* Documentation should focus on what a component does, not how it works internally
* Documentation should be written in clear, concise language
* Documentation should be grammatically correct and free of typos
* Documentation tone should be consistent, using direct verbs (e.g., "Get", "Check") rather than phrases like
  "This gets" or "Checks if"

### YARD Tag Requirements

#### Classes and Modules

* **@since** - Required for all classes and modules, indicating the version when the element was introduced
* **@api** - Required if the class/module is not intended for public use (e.g., `@api private`)
* **@example** - Rarely needed for classes/modules; should only be included when showing a complex usage pattern that
  isn't obvious from the methods

#### Methods

* **@param** - Required for all method parameters, describing purpose and expected types
* **@option** - Required when a parameter is an options hash, documenting all supported options
* **@return** - Required for all methods that return a value; methods without a `@return` tag are assumed to return
  `void`
* **@raise** - Required for all exceptions that might be raised by the method
* **@example** - Required for all public methods unless usage is immediately obvious
* **@since** - Required only if the method was introduced in a later version than its containing class/module
* **@deprecated** - Required for deprecated methods, must include alternative approach if available
* **@api** - Not required for private methods if the class/module is already marked as private, or if the method is
  under Ruby's `private` visibility modifier

#### Constants

* **@return** - Required for all constants, documenting their type and purpose
* **@since** - Required if introduced in a different version than the containing class/module
* **@example** - Rarely needed; should only be included for constants with complex usage patterns

### Code Example Standards

* All `@example` tags must contain executable Ruby code
* Examples should demonstrate typical use cases
* Examples should be concise but complete enough to be understood in isolation
* Complex examples should include comments explaining key aspects
* Public method examples should demonstrate successful usage
* Examples should avoid unnecessary dependencies on other parts of the library

### API Visibility Documentation

* Public APIs should be thoroughly documented with comprehensive descriptions, parameter details, and examples
* Protected APIs should have the same level of documentation as public APIs
* Private APIs require parameter and return type documentation but have relaxed requirements for examples
* Internal implementation details should be documented only when necessary for maintenance
* Methods without an `@api private` tag (directly or inherited) are assumed to be public

### Version and Deprecation Documentation

* All classes and modules must specify the version they were introduced with `@since`
* Methods introduced after their containing class/module must specify their introduction version
* Deprecated elements must include:
  * The `@deprecated` tag
  * The version in which the deprecation occurred
  * The version in which the element will be removed (if known)
  * Alternative approaches or replacement functionality

### Documentation for Edge Cases and Errors

* Document parameters' valid range of values and behavior outside those ranges
* Document all exceptions that can be raised by a method, including conditions that trigger them
* Document performance implications for operations that might be expensive in certain circumstances
* Document thread safety considerations where applicable

## Alternatives Considered

### Minimal Documentation Standards

* Only requiring documentation for public APIs
* Rejected as insufficient for maintaining a complex scientific library

### External Documentation Only

* Focusing on external guides and examples rather than inline code documentation
* Rejected as making it harder to maintain accurate documentation as code evolves

### Different Documentation Tool

* Using a different documentation tool instead of YARD
* Rejected as YARD is well-established in the Ruby ecosystem and provides the needed features

## Consequences

### Positive

* Improved developer experience through consistent, comprehensive documentation
* Reduced time spent understanding code during maintenance
* Better IDE integration through structured documentation
* Clearer boundaries between public, protected, and private APIs
* Easier to identify breaking changes through version tagging

### Negative

* Increased time required for writing and maintaining documentation
* Risk of documentation becoming outdated if not rigorously maintained
* Potential redundancy in some documentation elements due to strict requirements

## Implementation Notes

* Documentation standards should be enforced through code reviews
* Consider implementing automated documentation checks in CI pipeline
* Create documentation templates for common patterns to ensure consistency
* Schedule regular documentation reviews to identify and address gaps or inconsistencies
* New code should not be merged without meeting documentation standards