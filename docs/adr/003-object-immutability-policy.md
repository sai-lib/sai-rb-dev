# ADR 003: Object Immutability Policy

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

Color operations often involve transformations that could be implemented as either mutations or new object creations.
Inconsistent approaches to immutability lead to unpredictable behavior and bugs. As a scientific library dealing with
precise color calculations, predictability and correctness are paramount concerns.

Mutable objects can lead to several problems:

* Side effects that are difficult to trace
* Thread safety issues in concurrent environments
* Unexpected behavior when objects are shared across different parts of code
* Difficulty reasoning about object state at any given point

However, strict immutability can introduce performance considerations, especially for computation-heavy operations where
object creation overhead might be significant.

## Decision

Sai will adopt a comprehensive immutability approach for all core domain objects, with carefully documented exceptions
where necessary. The following principles will guide our implementation:

### Immutability by Default

* All color models, color spaces, and transformation objects should be immutable
* All methods that appear to transform an object should return a new instance rather than mutating the original
* Core domain objects should be frozen after initialization to prevent accidental mutation

### Permitted Exceptions

Mutable objects will only be permitted in the following circumstances:
* Builder pattern implementations explicitly designed for constructing complex objects
* Performance-critical inner loops where object creation would create measurable overhead
  (must be justified with benchmarks)
* Internal cache structures that do not expose mutation methods in the public API

### Implementation Approach

* Use of `#freeze` on objects after initialization
* Private setter methods to prevent unintended mutation
* Return of new instances rather than mutation of existing ones
* Thread-safe caching mechanisms for expensive computations

### Naming Conventions

Methods will follow these naming conventions to clearly indicate their behavior:
* Methods that return a new instance should use transformation verbs: `with_*`, `to_*`, etc.
* Methods that might be mistaken as mutators should explicitly indicate they return a new instance in documentation
* Any exceptional methods that do mutate state (in permitted exception cases) must use the bang `!` suffix
  (e.g., `add_component!`)

## Alternatives Considered

### Selective Immutability

* Making only certain classes immutable based on usage patterns
* Rejected due to inconsistency in API behavior and increased cognitive load

### Copy-on-Write Approach

* Using internal mutability with defensive copying
* Rejected due to complexity and potential for bugs

### Pure Functional Approach

* Using entirely stateless functions operating on data structures
* Rejected as too different from typical Ruby idioms

### No Immutability Guarantees

* Allowing mutation throughout the codebase
* Rejected due to high likelihood of bugs and inconsistent behavior

## Consequences

### Positive

* Elimination of entire classes of bugs related to unexpected mutations
* Thread safety by default
* Simpler reasoning about object state
* More predictable API behavior
* Better alignment with functional programming principles
* Support for method chaining patterns

### Negative

* Potential performance overhead from object creation
* Additional complexity for implementing efficient caching
* Possible increase in memory usage
* Need for disciplined implementation approach

## Implementation Notes

* All public objects should be safe to use in concurrent contexts without external synchronization
* Lazy initialization should use thread-local caching or other thread-safe techniques
* Any permitted mutable objects must document their thread safety characteristics
* Performance-critical code may use thread-local object pools if object creation becomes a bottleneck