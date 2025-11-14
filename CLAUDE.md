# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Swift Prompt Builder is a declarative Swift library for building structured prompts using a result builder pattern. It provides a SwiftUI-like DSL for composing complex prompts for AI models, chatbots, or text generation scenarios.

## Development Commands

### Building
```bash
swift build
```

### Testing
```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose
```

### Clean Build
```bash
swift package clean
```

## Architecture

### Core Design Pattern

The library is built around Swift's **Result Builder** pattern (similar to SwiftUI's ViewBuilder). All code is in a single file: [Sources/PromptBuilder/PromptBuilder.swift](Sources/PromptBuilder/PromptBuilder.swift)

**Key architectural components:**

1. **PromptComponent Protocol** - The foundation protocol that all components conform to. Has a single `build() -> String` method.

2. **PromptBuilder Result Builder** - The `@resultBuilder` that enables declarative syntax. Implements:
   - `buildBlock` - Combines components
   - `buildArray` - Handles for-loops
   - `buildOptional` - Handles if statements
   - `buildEither` - Handles if-else branches
   - `buildExpression` - Converts strings and components
   - `buildFinalResult` - Produces final string

3. **Component Hierarchy:**
   - **Basic Components**: `Text`, `Line`, `ListItem`, `EmptyLine`, `Variable`
   - **Message Components**: `SystemMessage`, `UserMessage`, `AssistantMessage`
   - **Structure Components**: `Section`, `Conditional`, `ForEach`
   - **Internal**: `ComponentGroup` (for combining arrays)

### Important Implementation Details

- **Sendable Conformance**: All components and closures are `Sendable` for full Swift 6 concurrency support
- **String Extension**: `String` conforms to `PromptComponent` so bare strings work in builder contexts
- **Zero Dependencies**: Pure Swift, no external dependencies
- **Single File Design**: Entire library is in one well-documented file

### Component Output Patterns

Understanding how components format their output:
- `Text` - Raw string, no formatting
- `Line` - Appends `\n`
- `ListItem` - Prepends `"- "` and appends `\n`
- `EmptyLine` - Just `\n`
- `Section` - Prepends `\n`, optional uppercased title with `:`, then content
- Message types - Prepend `"System: "` / `"User: "` / `"Assistant: "` and append `\n`

## Coding Conventions

### When Adding New Components

1. Conform to `PromptComponent` protocol
2. Make struct `Sendable`
3. Add comprehensive DocC documentation with:
   - Summary description
   - Code examples in triple backticks
   - Example output in comments
4. Use `@PromptBuilder` for content closures
5. Mark closures as `@Sendable`

Example template:
```swift
/// A component that does XYZ.
///
/// Detailed description of behavior.
///
/// ```swift
/// Prompt {
///     MyComponent {
///         Text("example")
///     }
/// }
/// // Output: formatted example
/// ```
public struct MyComponent: PromptComponent, Sendable {
    public let content: PromptComponent

    public init(@PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.content = content()
    }

    public func build() -> String {
        // Format and return string
    }
}
```

### Testing Approach

Tests use Swift Testing framework (not XCTest). Located in [Tests/PromptBuilderTests/PromptBuilderTests.swift](Tests/PromptBuilderTests/PromptBuilderTests.swift).

When adding tests:
- Use `@Test` attribute (not `func test...`)
- Use `#expect(...)` for assertions (not XCTAssert)
- Import as `@testable import PromptBuilder`
- Test both the component's `build()` output and usage within `Prompt {}`

## Release Process

Releases are handled via GitHub Actions workflow (manual trigger):
- Navigate to Actions → Release workflow
- Choose release type: `patch`, `minor`, or `major`
- Workflow automatically bumps version, creates tag, and generates release notes

## Requirements

- Swift 5.5+ (uses result builders)
- Platforms: iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
