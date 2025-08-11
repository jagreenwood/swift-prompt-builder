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
public protocol PromptComponent: Sendable {
    func build() -> String
}

// MARK: - Component Group (for handling arrays)
public struct ComponentGroup: PromptComponent, Sendable {
    public let components: [PromptComponent]

    public func build() -> String {
        components.map { $0.build() }.joined()
    }
}

// MARK: - Basic Components
public struct Text: PromptComponent, Sendable {
    public let content: String

    public init(_ content: String) {
        self.content = content
    }

    public func build() -> String {
        content
    }
}

public struct ListItem: PromptComponent, Sendable {
    public let content: String

    public init(_ content: String) {
        self.content = content
    }

    public func build() -> String {
        "- \(content)\n"
    }
}

public struct Line: PromptComponent, Sendable {
    public let content: String

    public init(_ content: String) {
        self.content = content
    }

    public func build() -> String {
        "\(content)\n"
    }
}

public struct EmptyLine: PromptComponent, Sendable {
    public func build() -> String {
        "\n"
    }
}

// MARK: - Variable/Placeholder Component
public struct Variable: PromptComponent, Sendable {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public init<T>(_ value: T) {
        self.value = String(describing: value)
    }

    public func build() -> String {
        value
    }
}

// MARK: - Section Components
public struct Section: PromptComponent, Sendable {
    public let title: String?
    public let content: PromptComponent

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

public struct SystemMessage: PromptComponent, Sendable {
    public let content: PromptComponent

    public init(@PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.content = content()
    }

    public func build() -> String {
        "System: " + content.build() + "\n"
    }
}

public struct UserMessage: PromptComponent, Sendable {
    public let content: PromptComponent

    public init(@PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.content = content()
    }

    public func build() -> String {
        "User: " + content.build() + "\n"
    }
}

public struct AssistantMessage: PromptComponent, Sendable {
    public let content: PromptComponent

    public init(@PromptBuilder _ content: @Sendable () -> PromptComponent) {
        self.content = content()
    }

    public func build() -> String {
        "Assistant: " + content.build() + "\n"
    }
}

// MARK: - Conditional Component
public struct Conditional: PromptComponent, Sendable {
    public let content: PromptComponent

    public init(_ condition: Bool, @PromptBuilder then: @Sendable () -> PromptComponent) {
        self.content = condition ? then() : Text("")
    }

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
public struct ForEach<Item: Sendable>: PromptComponent, Sendable {
    public let content: PromptComponent

    public init(_ items: [Item], @PromptBuilder content: @Sendable (Item) -> PromptComponent) {
        let components = items.map { content($0) }
        self.content = ComponentGroup(components: components)
    }

    public init(_ items: [Item], separator: String, @PromptBuilder content: @Sendable (Item) -> PromptComponent) {
        let mapped = items.map { content($0).build() }
        self.content = Text(mapped.joined(separator: separator))
    }

    public func build() -> String {
        content.build()
    }
}

// MARK: - Result Builder
@resultBuilder
public struct PromptBuilder: Sendable {
    public static func buildBlock(_ components: PromptComponent...) -> PromptComponent {
        ComponentGroup(components: components)
    }

    public static func buildArray(_ components: [PromptComponent]) -> PromptComponent {
        ComponentGroup(components: components)
    }

    public static func buildOptional(_ component: PromptComponent?) -> PromptComponent {
        component ?? Text("")
    }

    public static func buildEither(first component: PromptComponent) -> PromptComponent {
        component
    }

    public static func buildEither(second component: PromptComponent) -> PromptComponent {
        component
    }

    public static func buildExpression(_ expression: PromptComponent) -> PromptComponent {
        expression
    }

    public static func buildExpression(_ expression: String) -> PromptComponent {
        Text(expression)
    }

    public static func buildFinalResult(_ component: PromptComponent) -> String {
        component.build()
    }
}

// MARK: - Main Prompt Function
public func Prompt(@PromptBuilder _ content: @Sendable () -> String) -> String {
    content()
}

extension String: PromptComponent {
    public func build() -> String { self }
}
