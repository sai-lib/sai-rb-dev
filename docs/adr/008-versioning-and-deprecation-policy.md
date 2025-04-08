# ADR 008: Versioning and Deprecation Policy

## Status

![Active](https://img.shields.io/badge/Active-green?style=for-the-badge)

## Context

The transition from a terminal color library to a colorimetry library represents a major breaking change. We need clear
policies on how we'll manage this transition and future changes to minimize disruption for users while allowing the
library to evolve.

Versioning choices significantly impact both library maintainers and users. A too-rigid versioning system can lead to
version number inflation, while an inconsistent approach makes version numbers meaningless for assessing upgrade safety.

## Decision

We will adopt [BreakVer](https://www.taoensso.com/break-versioning) for versioning and implement a structured
deprecation policy to provide clear guidance for both users and maintainers.

### Versioning Strategy

Sai will follow the BreakVer standard for versioning, which emphasizes the maximum potential impact of a version change.
The version format will be:

```
<breaking>.<non-breaking>
```

Where:

* **Breaking**: Incremented when making changes that could break users' code. The breaking significance determines
  whether to increment major or minor:
  * **Major Breaking**: Changes that affect core functionality, require significant user code changes, or alter
    fundamental behavior. These warrant a major version bump.
  * **Minor Breaking**: Changes that affect more peripheral or less commonly used functionality, or require minimal user
    code changes. These warrant a minor version bump.
* **Non-Breaking**: Incremented only when making changes guaranteed not to break any reasonable user code. This includes
  bug fixes, performance improvements, and new functionality that doesn't affect existing code.

Unlike SemVer, BreakVer does not distinguish between "minor" (new features) and "patch" (bug fixes) for non-breaking
changes - they are all just non-breaking changes.

### Deprecation Policy

#### Deprecation Process

1. **Marking**: Methods/classes to be deprecated will:

* Receive `@deprecated` YARD tag with version marked and version targeted for removal
* Include reference to the replacement functionality in documentation
* Emit console warnings when used, directing users to alternatives

2. **Removal Timeline**:

* Deprecated functionality will remain for at least one major version cycle
* Functionality marked as deprecated in version X.Y will be removed no earlier than version (X+1).0

3. **Documentation**:

* A CHANGELOG.md will track all deprecations and removals
* Release notes will prominently highlight deprecations
* Documentation will maintain a "Deprecated Features" section

#### Breaking Changes

All breaking changes must:

* Be documented in CHANGELOG.md
* Include migration guides for significant changes
* Be announced in release notes
* Have deprecation warnings in the previous version when feasible

### Terminal-to-Colorimetry Transition

For the transition from terminal color library to full colorimetry:

1. **Version Increment**: The transition will involve a minor version increment (from v0.4.0 to v0.5.0)

* This is only acceptable because we're still in the 0.x version range, which traditionally allows for more
  significant changes in minor versions
* Once we reach 1.0.0, this scale of change would require a major version increment

2. **Compatibility Layer**: We will provide a temporary compatibility layer to ease migration:

* Old terminal color functionality will be accessible but marked as deprecated
* New colorimetry functionality will be the primary documented API
* The compatibility layer will be removed in the next minor version

3. **Feature Flags**: We will implement feature flags to:

* Allow users to opt-in to specific new functionality
* Provide switch to enable legacy behavior when needed
* Control deprecation warnings

4. **Migration Guides**: Comprehensive documentation will be created to guide users through:

* How to migrate from terminal color to colorimetry
* Equivalent functionality between old and new APIs
* Best practices for the new API

## Alternatives Considered

### Semantic Versioning (SemVer)

* More widely recognized but doesn't distinguish between major and minor breaking changes
* Tends to lead to major version inflation
* Rejected in favor of BreakVer's pragmatic approach to breaking changes

### Calendar Versioning (CalVer)

* Would detach version numbers from breaking changes
* Could cause unpredictable breaking changes with each release
* Rejected due to unpredictable compatibility guarantees

### Maintaining Two Separate Libraries

* Terminal color and colorimetry as entirely separate packages
* Would fragment the ecosystem and create maintenance overhead
* Rejected in favor of a unified library with a migration path

## Consequences

### Positive

* Clear signal to users about the potential impact of version upgrades
* More nuanced approach to breaking changes than SemVer
* Structured deprecation process that respects existing users
* Smooth migration path from terminal color to colorimetry
* Flexibility to evolve the library while maintaining usability

### Negative

* May create confusion for users familiar with SemVer
* Requires judgment calls about what constitutes major vs. minor breaking changes
* Temporary compatibility layer adds maintenance overhead
* Feature flags increase testing complexity

## Implementation Notes

* All version-related documentation should follow the standards in ADR 007
* Version-sensitive API changes should respect the design principles in ADR 005
* Module structure should follow the conventions in ADR 001, especially for compatibility layers