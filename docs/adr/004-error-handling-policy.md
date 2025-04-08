# ADR 004: Error Handling Policy

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

Color operations can fail in various ways including invalid inputs, out-of-gamut colors, mathematical precision issues,
and environmental constraints. Without a consistent approach to error handling, the library will behave unpredictably
for users and be difficult to debug. Clear principles are needed to guide how errors are communicated to library users.

## Decision

We will adopt the following error handling guidelines:

### Error Class Hierarchy

* **Base Error Class**: All Sai-specific errors will inherit from `Sai::Error < StandardError`
* **Category-based Subclasses**: Create a flat hierarchy of errors inheriting from the base class
  * `Sai::ValidationError < Sai::Error` - For input validation failures
  * `Sai::ConversionError < Sai::Error` - For errors during color conversions
  * `Sai::MathError < Sai::Error` - For mathematical operation failures
  * `Sai::ConfigurationError < Sai::Error` - For errors related to library configuration
* **Specific Error Types**: Create more specific errors that inherit from category errors
  * `Sai::OutOfGamutError < Sai::ValidationError`
  * `Sai::OutOfBoundsError < Sai::ValidationError`
  * `Sai::UnsupportedConversionError < Sai::ConversionError`

### Exception vs. Return Values Guidelines

* **Use Exceptions When**:
  * An operation cannot complete its intended purpose
  * The error represents a programming mistake
  * Invalid inputs are provided that cannot be reasonably processed
  * Configuration or environment problems prevent correct operation

* **Use Return Values When**:
  * A result is valid but has characteristics the caller should be aware of
  * Multiple outcomes are expected and normal
  * Performance is critical in a hot path (with appropriate documentation)

* **Never Silently Fail**: Operations should never return nil or false without indication of why

### Error Message Standards

* **Format**: `"<thing> is invalid. Expected <expectation>, got: <actual>"`
* **Content Requirements**:
  * Clear identification of what is invalid
  * Expected type, range, or format
  * Actual value received
  * Simple, direct phrasing that aids debugging
  * No internal details that aren't useful for users

* **Example**:
  * `"Red channel value is invalid. Expected 0.0..255.0, got: 300.0"`
  * `"Color is out of gamut. Expected values within sRGB gamut, got: Lab(90, -80, 70)"`

### Edge Case Handling

* **NaN and Infinity**:
  * Detect and fail early with clear error messages
  * Never propagate NaN/Infinity values through calculations
  * Document any cases where NaN/Infinity has special meaning

* **Extreme Values**:
  * Validate inputs at the boundary of operations
  * Document the behavior at extremes
  * Consider using epsilon values for floating-point comparisons

* **Type Errors**:
  * Check and convert types when reasonable (e.g., "255" → 255.0)
  * Fail with clear type expectation messages otherwise

### Common Scenarios

* **Out-of-gamut Colors**:
  * When converting between spaces with different gamuts:
    * Throw `OutOfGamutError` when requiring exact conversion
    * Provide optional gamut mapping when approximation is acceptable
    * Document the clipping or compression method used

* **Invalid Inputs**:
  * Check inputs early with descriptive validation messages
  * For channel values, include the valid range in error messages
  * For complex validations, provide a method to check validity before operations

* **Unsupported Operations**:
  * Use Ruby's built-in `NotImplementedError` for unimplemented features
  * Throw `Sai::UnsupportedConversionError` for operations that will never be supported
  * Suggest alternatives when possible

## Alternatives Considered

### Result Objects Pattern

* Using a `Result` object with `success?` and `error` methods
* Rejected due to added complexity and divergence from Ruby idioms
* May reconsider for specific complex operations in the future

### Null Object Pattern

* Returning "empty" or "default" objects instead of raising errors
* Rejected as it could mask problems and lead to confusing cascading effects

### Global Error Handler

* Using a centralized error handling mechanism
* Rejected in favor of standard Ruby exception handling to maintain simplicity

### Limited Error Types

* Using fewer, more general error classes
* Rejected as it would provide less specific information about error conditions

## Consequences

### Positive

* Consistent error handling improves API predictability
* Detailed error messages help users debug issues
* Clear documentation of error conditions supports better application design
* Class hierarchy enables specific error handling when needed

### Negative

* Requires diligence to maintain consistency across the library
* More error types could increase learning curve for handling errors
* Need to balance detail in error messages with simplicity

## Implementation Notes

* Create the error class hierarchy early in development
* Develop a shared error message formatting method for consistency
* Add specs that specifically test error cases and messages
* Review all public methods to ensure appropriate error handling
* Consider developing a guide specifically for error handling