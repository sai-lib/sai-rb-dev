# ADR 009: Enum System for Magic Value Elimination

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

The Sai color library will require various configuration options, algorithm selections, and other parameters throughout
its API. Without a standardized approach, users would need to rely on "magic values" - hardcoded strings and symbols
that present several challenges:

* They lack type safety and IDE completion support
* They create implicit coupling between components
* They offer no documentation at the point of use
* They lead to inconsistent usage patterns
* They force eager loading of components even when they're not needed

As we design the library's public API, we need a consistent mechanism to represent these values that provides better
developer experience while maintaining performance through lazy loading.

## Decision

We will implement an enumeration system that provides multiple consistent interfaces for accessing constant values while
enabling lazy loading of components.

The enum system will support the following access patterns:

* Constant-style access: `Sai::Enum::CacheStore::MEMORY`
* Method-style access: `Sai.enum.cache_store.memory`
* Hash-style access: `Sai.enum[:cache_store][:memory]`
* Path-based access: `Sai.enum.dig(:cache_store, :memory)`

Each enum value will lazily resolve to its actual implementation only when needed, with implementation details of this
resolution mechanism being internal to the enum system.

### Integration With Other ADRs

* This approach supports the API design principles in ADR 005 by providing consistent, well-documented parameter options
* The lazy loading mechanism aligns with the performance considerations in ADR 006
* Enums will be fully documented according to ADR 007
* The implementation will follow the immutability principles in ADR 003

## Alternatives Considered

### Simple Constants

* Example: `Sai::CacheStore::MEMORY = :memory`
* Rejected as it doesn't provide lazy loading capabilities, lacks method-based access patterns, and doesn't
  encapsulate the relationship between the enum and its resolved value

### Symbol-based Enum

* Example: Using symbols like `:memory`, `:null` directly
* Rejected because they lack type safety, documentation, and IDE completion support

### External Gem Dependencies

* Example: Using gems like `ruby-enum` or `dry-types`
* Rejected to minimize external dependencies per ADR 002 and to implement a solution specifically
  tailored to our lazy-loading needs

### Nested Module Structure Without Lazy Loading

* Example: `Sai::CacheStore::Memory` modules that are always loaded
* Rejected because it would require eager loading of all components, increasing memory usage

## Consequences

### Positive

* Eliminates magic strings/symbols from the public API
* Provides multiple intuitive access patterns for different user preferences
* Enables lazy loading to reduce initial memory footprint
* Improves type safety and IDE completion support
* Creates discoverability through module introspection
* Centralizes enum definitions for easier maintenance
* Enables documentation at the point of definition

### Negative

* Introduces a custom implementation rather than using existing gems
* Slightly more complex than directly using symbols or strings
* Requires discipline to ensure all magic values are represented in the enum system
* May introduce a small performance overhead for value resolution

## Implementation Notes

* All public-facing API methods that accept option values should use this enum system
* Enum values should be documented with YARD to enable good IDE support
* The implementation should prioritize thread safety for concurrent environments
* The enum system should provide introspection capabilities to discover available values
* When adding new options or algorithms to the library, corresponding enum values must be added
* Testing should verify both the enum system itself and its integration with components that use it