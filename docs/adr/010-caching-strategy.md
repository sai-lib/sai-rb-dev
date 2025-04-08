# ADR 010: Caching Strategy

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

Color space transformations and other color operations often involve complex mathematical calculations. Many of these
computations are deterministic—the same input will always produce the same output. In applications that work heavily
with color, these operations may be repeated frequently, especially in scenarios like batch processing, image
manipulation, or rendering.

Without a caching strategy, the library would recalculate the same values repeatedly, leading to unnecessary CPU usage
and slower performance. Given that many color transformations in Sai will be computationally expensive (particularly
those involving XYZ and Lab color spaces), we need an approach that balances performance, memory usage, and code
clarity.

Additionally, Sai is designed to be used in various contexts, from lightweight scripts to resource-intensive
applications. This necessitates a flexible caching approach that can adapt to different usage patterns and resource
constraints.

## Decision

We will implement a comprehensive caching system in Sai with the following characteristics:

### Cache Architecture

* **Multi-level Caching**: Implement a tiered cache system with:
  * Instance-level caching for values that are frequently reused within a color object
  * Library-level caching for color transformations that may be reused across objects

* **Cache Store Abstraction**: Create an abstract cache store interface that allows for different backing
  implementations, following the enum system described in ADR 009

* **Default Store Implementation**: Provide a thread-safe, LRU (Least Recently Used) cache as the default store

* **Alternative Stores**: Support additional store implementations:
  * Null store (for disabling caching)
  * Simple store (for memory-constrained environments)
  * Custom stores (allowing users to provide their own implementation)

### Caching Strategy

#### Key Composition: Use a combination of relevant attributes to form cache keys

* Source color model type
* Target color model type
* Channel values
* Transformation-specific parameters
* Configuration settings that affect the transformation

#### Cache Values and Immutability

* **Ruby Primitives Only**: Cache values must be limited to Ruby primitives:
  * `Integer`
  * `Float`
  * `String`
  * `Symbol`
  * `Array` (containing only primitives)
  * `Hash` (with primitive keys and values)
  * `nil`
  * `true`/`false`

* **All Values Must Be Frozen**:
  * Every value stored in the cache must be frozen with `Object#freeze`
  * For collections (Array, Hash), deep freezing must be applied to ensure all nested values are also immutable
  * Frozen values prevent accidental modification and ensure cache consistency

* **Value Transformation**: If a non-primitive object needs to be cached:
  * It must be transformed into a primitive representation before caching
  * The primitive representation must capture all relevant state
  * A restoration method must be provided to recreate the object from its primitive representation

#### Cache Invalidation

* Automatically invalidate instance caches when a color's properties change
* Allow manual cache clearing for library-level caches
* Use LRU eviction to prevent unbounded memory growth
* Adhere to immutability principles from ADR 003

#### Thread Safety
* Ensure all cache operations are thread-safe by default, aligning with the thread safety considerations in
  ADR 003

### Configuration

* **Cache Size**: Allow configuring maximum cache size (in bytes or entries)
  * Default to a reasonable size that balances memory usage and hit rate

* **Cache Enable/Disable**: Provide option to enable/disable caching globally or per operation type

* **Cache Metrics**: Optionally track and expose metrics like hit rate, miss rate, and eviction count

### Usage Pattern

* **Transparent Caching**: Cache usage should be transparent to library users, consistent with the API design principles
  in ADR 005

* **Automatic Key Generation**: Generate cache keys automatically based on the operation and its parameters

* **Cache Fetching Pattern**: Use a standardized pattern for all cache interactions:
  * Check cache for existing value
  * If missing, compute the value and store in cache
  * Return the value (either from cache or newly computed)

## Alternatives Considered

### No Caching

* Simplest implementation with minimal code complexity
* Rejected due to significant performance impact for repeated operations, contradicting the guidelines in
  ADR 006

### Memoization Only

* Using Ruby's built-in memoization pattern (||=) for simple instance-level caching
* Rejected as insufficient for cross-instance caching and lacks eviction strategies

### Global Hash-based Cache

* Using a simple global hash for caching all values
* Rejected due to memory concerns and lack of eviction capability

### External Cache Dependency

* Relying on an external caching library
* Rejected to avoid external dependencies per ADR 002

### Allowing Complex Objects in Cache

* Storing object instances directly in the cache
* Rejected due to potential memory leaks, thread safety issues, and complications with object lifecycle

### Per-Thread Caching

* Using thread-local storage for caching to avoid synchronization
* Rejected due to potential for memory leaks and duplicated caching across threads

## Consequences

### Positive

* Significant performance improvements for repeated operations
* Reduced CPU usage in color-intensive applications
* Flexible configuration to adapt to different resource constraints
* Clear separation of caching concerns from color transformation logic
* Improved thread safety with frozen cache values
* Reduced memory usage by limiting to primitive types
* Simplified debugging and testing due to immutable cache state

### Negative

* Increased code complexity to manage caching
* Additional memory usage for stored cache entries
* Potential for bugs related to cache invalidation
* Need for thorough testing of cache edge cases
* Extra work to transform complex objects to/from primitive representations

## Implementation Notes

* Start with a simple LRU implementation focusing on the most expensive operations
* Ensure proper synchronization to avoid race conditions
* Add robust key generation that captures all aspects affecting the transformation result
* Include cache statistics for debugging and optimization
* Provide clear documentation on cache behavior and configuration options following
  ADR 007
* Consider benchmark-driven development to validate performance improvements
* Design with extensibility in mind to allow for future optimizations
* Isolate cache implementation details to allow for changes without affecting the public API