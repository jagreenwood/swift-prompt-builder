//
//  PromptBuilder.swift
//
//  Created by Jeremy Greenwood on 8/6/25.
//
//  MIT License
//
//  Copyright (c) 2025 Jeremy Greenwood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

// MARK: - Prompt Component Protocol

/// A protocol that defines a component that can be used to build prompts.
///
/// Types conforming to `PromptComponent` can be composed together using the `@PromptBuilder`
/// result builder to create structured prompts for language models or other text-based systems.
///
/// ## Topics
/// ### Building Components
/// - ``build()``
public protocol PromptComponent: Sendable {
    /// Builds and returns the string representation of this prompt component.
    ///
    /// - Returns: A string containing the formatted prompt content.
    func build() -> String
}

// MARK: - Component Group (for handling arrays)

/// A component that groups multiple prompt components together.
///
/// `ComponentGroup` is primarily used internally by the `@PromptBuilder` result builder
/// to combine multiple components into a single component. When built, it concatenates
/// the output of all contained components.
public struct ComponentGroup: PromptComponent, Sendable {
    /// The array of components contained in this group.
    public let components: [PromptComponent]

    public func build() -> String {
        components.map { $0.build() }.joined()
    }
}

// MARK: - Basic Components

/// A basic text component that renders its content as-is.
///
/// Use `Text` to include plain text content in your prompts without any formatting.
///
/// ```swift
/// Prompt {
///     Text("Hello, world!")
/// }
/// ```
public struct Text: PromptComponent, Sendable {
    /// The text content to be rendered.
    public let content: String

    /// Creates a text component with the specified content.
    ///
    /// - Parameter content: The text to include in the prompt.
    public init(_ content: String) {
        self.content = content
    }

    public func build() -> String {
        content
    }
}

/// A list item component that formats content as a bullet point.
///
/// `ListItem` automatically prepends a dash and appends a newline to create
/// formatted list items in your prompts.
///
/// ```swift
/// Prompt {
///     ListItem("First item")
///     ListItem("Second item")
/// }
/// // Output:
/// // - First item
/// // - Second item
/// ```
public struct ListItem: PromptComponent, Sendable {
    /// The content of the list item.
    public let content: String

    /// Creates a list item with the specified content.
    ///
    /// - Parameter content: The text to include in the list item.
    public init(_ content: String) {
        self.content = content
    }

    public func build() -> String {
        "- \(content)\n"
    }
}

/// A line component that renders content with a trailing newline.
///
/// Use `Line` when you want to ensure content appears on its own line.
///
/// ```swift
/// Prompt {
///     Line("This is a line")
///     Line("This is another line")
/// }
/// ```
public struct Line: PromptComponent, Sendable {
    /// The content of the line.
    public let content: String

    /// Creates a line component with the specified content.
    ///
    /// - Parameter content: The text to include on the line.
    public init(_ content: String) {
        self.content = content
    }

    public func build() -> String {
        "\(content)\n"
    }
}

/// An empty line component that renders a single newline character.
///
/// Use `EmptyLine` to add vertical spacing in your prompts.
///
/// ```swift
/// Prompt {
///     Text("Paragraph 1")
///     EmptyLine()
///     Text("Paragraph 2")
/// }
/// ```
public struct EmptyLine: PromptComponent, Sendable {
    public func build() -> String {
        "\n"
    }
}

// MARK: - Variable/Placeholder Component

/// A variable component for including dynamic values in prompts.
///
/// `Variable` allows you to interpolate values of any type into your prompts.
/// The value is converted to a string using Swift's `String(describing:)` initializer.
///
/// ```swift
/// let userName = "Alice"
/// let userAge = 30
///
/// Prompt {
///     Text("User: ")
///     Variable(userName)
///     Text(", Age: ")
///     Variable(userAge)
/// }
/// ```
public struct Variable: PromptComponent, Sendable {
    /// The string representation of the value.
    public let value: String

    /// Creates a variable component with a string value.
    ///
    /// - Parameter value: The string value to include.
    public init(_ value: String) {
        self.value = value
    }

    /// Creates a variable component with any value type.
    ///
    /// The value is converted to a string using `String(describing:)`.
    ///
    /// - Parameter value: The value to convert and include.
    public init<T>(_ value: T) {
        self.value = String(describing: value)
    }

    public func build() -> String {
        value
    }
}

// MARK: - Section Components

/// A section component that groups related content under an optional title.
///
/// `Section` creates a logical grouping of prompt content, optionally preceded by
/// an uppercased title. Sections are separated by newlines for visual clarity.
///
/// ```swift
/// Prompt {
///     Section(title: "Instructions") {
///         Line("Follow these steps:")
///         ListItem("Step 1")
///         ListItem("Step 2")
///     }
/// }
/// // Output:
/// //
/// // INSTRUCTIONS:
/// // Follow these steps:
/// // - Step 1
/// // - Step 2
/// ```
public struct Section: PromptComponent, Sendable {
    /// The optional title for this section.
    public let title: String?
    
    /// The content contained within this section.
    public let content: PromptComponent

    /// Creates a section with an optional title and content.
    ///
    /// - Parameters:
    ///   - title: An optional title for the section. If provided, it will be uppercased.
    ///   - content: A closure that builds the section's content using `@PromptBuilder`.
    public init(title: String? = nil, @PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.title = title
        self.content = content()
    }

    public func build() -> String {
        var result = "\n"
        if let title = title {
            result += title.uppercased() + ":\n"
        }
        result += content.build()
        return result
    }
}

/// A system message component for representing system-level instructions.
///
/// `SystemMessage` formats content as a message from the system, typically used
/// to provide context or instructions to a language model.
///
/// ```swift
/// Prompt {
///     SystemMessage {
///         Text("You are a helpful assistant.")
///     }
/// }
/// // Output: System: You are a helpful assistant.
/// ```
public struct SystemMessage: PromptComponent, Sendable {
    /// The content of the system message.
    public let content: PromptComponent

    /// Creates a system message with the specified content.
    ///
    /// - Parameter content: A closure that builds the message content using `@PromptBuilder`.
    public init(@PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.content = content()
    }

    public func build() -> String {
        "System: " + content.build() + "\n"
    }
}

/// A user message component for representing user input.
///
/// `UserMessage` formats content as a message from the user, typically used
/// in conversational prompts or chat-based interfaces.
///
/// ```swift
/// Prompt {
///     UserMessage {
///         Text("What is the weather today?")
///     }
/// }
/// // Output: User: What is the weather today?
/// ```
public struct UserMessage: PromptComponent, Sendable {
    /// The content of the user message.
    public let content: PromptComponent

    /// Creates a user message with the specified content.
    ///
    /// - Parameter content: A closure that builds the message content using `@PromptBuilder`.
    public init(@PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.content = content()
    }

    public func build() -> String {
        "User: " + content.build() + "\n"
    }
}

/// An assistant message component for representing assistant responses.
///
/// `AssistantMessage` formats content as a message from an assistant, typically used
/// to show example responses or previous assistant outputs in a conversation.
///
/// ```swift
/// Prompt {
///     AssistantMessage {
///         Text("The weather today is sunny.")
///     }
/// }
/// // Output: Assistant: The weather today is sunny.
/// ```
public struct AssistantMessage: PromptComponent, Sendable {
    /// The content of the assistant message.
    public let content: PromptComponent

    /// Creates an assistant message with the specified content.
    ///
    /// - Parameter content: A closure that builds the message content using `@PromptBuilder`.
    public init(@PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.content = content()
    }

    public func build() -> String {
        "Assistant: " + content.build() + "\n"
    }
}

// MARK: - Conditional Component

/// A conditional component that includes content based on a boolean condition.
///
/// `Conditional` allows you to include or exclude content from your prompts based
/// on runtime conditions. It supports both simple if-then and if-then-else patterns.
///
/// ```swift
/// let includeWarning = true
/// let debugMode = false
///
/// Prompt {
///     Conditional(includeWarning) {
///         Text("⚠️ Warning: This is important!")
///     }
///
///     Conditional(debugMode,
///         then: { Text("Debug information...") },
///         else: { Text("Production mode") }
///     )
/// }
/// ```
public struct Conditional: PromptComponent, Sendable {
    /// The content to include based on the condition.
    public let content: PromptComponent

    /// Creates a conditional component with a then clause.
    ///
    /// - Parameters:
    ///   - condition: A boolean value determining whether to include the content.
    ///   - then: A closure that builds the content to include if the condition is true.
    public init(_ condition: Bool, @PromptBuilder then: @Sendable () -> PromptComponent) {
        self.content = condition ? then() : Text("")
    }

    /// Creates a conditional component with then and else clauses.
    ///
    /// - Parameters:
    ///   - condition: A boolean value determining which content to include.
    ///   - then: A closure that builds the content to include if the condition is true.
    ///   - else: A closure that builds the content to include if the condition is false.
    public init(_ condition: Bool,
                @PromptBuilder then: @Sendable () -> PromptComponent,
                @PromptBuilder else: @Sendable () -> PromptComponent) {
        self.content = condition ? then() : `else`()
    }

    public func build() -> String {
        content.build()
    }
}

// MARK: - Loop Component

/// A loop component that iterates over a collection and builds content for each item.
///
/// `ForEach` allows you to generate prompt content from arrays or other sequences.
/// It supports both direct concatenation and custom separators between items.
///
/// ```swift
/// let tasks = ["Write code", "Test code", "Deploy code"]
///
/// Prompt {
///     ForEach(tasks) { task in
///         ListItem(task)
///     }
///
///     // With separator
///     ForEach(["Swift", "Objective-C", "C++"], separator: ", ") { language in
///         Text(language)
///     }
/// }
/// ```
public struct ForEach<Item: Sendable>: PromptComponent, Sendable {
    /// The content generated from the items.
    public let content: PromptComponent

    /// Creates a loop component that iterates over items.
    ///
    /// Each item is passed to the content closure, which builds a component for that item.
    /// The resulting components are concatenated directly without separators.
    ///
    /// - Parameters:
    ///   - items: The array of items to iterate over.
    ///   - content: A closure that builds a component for each item.
    public init(_ items: [Item], @PromptBuilder content: @Sendable (Item) -> PromptComponent) {
        let components = items.map { content($0) }
        self.content = ComponentGroup(components: components)
    }

    /// Creates a loop component that iterates over items with a separator.
    ///
    /// Each item is passed to the content closure, and the resulting strings are
    /// joined with the specified separator.
    ///
    /// - Parameters:
    ///   - items: The array of items to iterate over.
    ///   - separator: A string to insert between each item.
    ///   - content: A closure that builds a component for each item.
    public init(_ items: [Item], separator: String, @PromptBuilder content: @Sendable (Item) -> PromptComponent) {
        let mapped = items.map { content($0).build() }
        self.content = Text(mapped.joined(separator: separator))
    }

    public func build() -> String {
        content.build()
    }
}

// MARK: - Result Builder

/// A result builder that enables declarative prompt construction.
///
/// `PromptBuilder` is a Swift result builder that allows you to compose prompt components
/// using a declarative, SwiftUI-like syntax. It supports standard control flow including
/// conditionals, loops, and optional values.
///
/// The result builder is used automatically when you use the `@PromptBuilder` attribute
/// on closure parameters, enabling a clean DSL for building prompts.
///
/// ```swift
/// @PromptBuilder
/// func buildPrompt() -> PromptComponent {
///     Text("Hello")
///     if shouldIncludeExtra {
///         Text(" Extra content")
///     }
///     for item in items {
///         ListItem(item)
///     }
/// }
/// ```
@resultBuilder
public struct PromptBuilder: Sendable {
    /// Combines multiple components into a single component group.
    public static func buildBlock(_ components: PromptComponent...) -> PromptComponent {
        ComponentGroup(components: components)
    }

    /// Builds a component from an array of components.
    public static func buildArray(_ components: [PromptComponent]) -> PromptComponent {
        ComponentGroup(components: components)
    }

    /// Handles optional components, providing an empty text component for nil values.
    public static func buildOptional(_ component: PromptComponent?) -> PromptComponent {
        component ?? Text("")
    }

    /// Handles the first branch of an if-else statement.
    public static func buildEither(first component: PromptComponent) -> PromptComponent {
        component
    }

    /// Handles the second branch of an if-else statement.
    public static func buildEither(second component: PromptComponent) -> PromptComponent {
        component
    }

    /// Converts a prompt component expression into a component.
    public static func buildExpression(_ expression: PromptComponent) -> PromptComponent {
        expression
    }

    /// Converts a string expression into a text component.
    public static func buildExpression(_ expression: String) -> PromptComponent {
        Text(expression)
    }

    /// Builds the final string result from a component.
    public static func buildFinalResult(_ component: PromptComponent) -> String {
        component.build()
    }
}

// MARK: - Main Prompt Function

/// Creates a prompt string using the declarative prompt builder syntax.
///
/// The `Prompt` function provides the entry point for building prompts. It accepts
/// a closure annotated with `@PromptBuilder` that returns a string representation
/// of the composed prompt components.
///
/// ```swift
/// let prompt = Prompt {
///     SystemMessage {
///         Text("You are a helpful assistant.")
///     }
///
///     UserMessage {
///         Text("What is the weather like today?")
///     }
/// }
///
/// print(prompt)
/// // System: You are a helpful assistant.
/// // User: What is the weather like today?
/// ```
///
/// - Parameter content: A closure that builds the prompt content using `@PromptBuilder`.
/// - Returns: The final string representation of the prompt.
public func Prompt(@PromptBuilder _ content: @Sendable () -> String) -> String {
    content()
}

/// Extends String to conform to PromptComponent for convenience.
///
/// This extension allows strings to be used directly in prompt builder contexts
/// without wrapping them in a `Text` component.
extension String: PromptComponent {
    public func build() -> String { self }
}
