//
//  PromptBuilderTests.swift
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

#if canImport(Testing)
import Testing
@testable import PromptBuilder

// MARK: - Basic Components Tests

@Test func textComponent() {
    let text = Text("Hello, world!")
    #expect(text.build() == "Hello, world!")
}

@Test func lineComponent() {
    let line = Line("Hello, world!")
    #expect(line.build() == "Hello, world!\n")
}

@Test func listItemComponent() {
    let item = ListItem("First item")
    #expect(item.build() == "- First item\n")
}

@Test func emptyLineComponent() {
    let empty = EmptyLine()
    #expect(empty.build() == "\n")
}

@Test func stringAsComponent() {
    let prompt = Prompt {
        "Hello, world!"
    }
    #expect(prompt == "Hello, world!")
}

// MARK: - Variable Component Tests

@Test func variableWithString() {
    let variable = Variable("test value")
    #expect(variable.build() == "test value")
}

@Test func variableWithInt() {
    let variable = Variable(42)
    #expect(variable.build() == "42")
}

@Test func variableWithCustomType() {
    struct Person {
        let name: String
    }
    let person = Person(name: "Alice")
    let variable = Variable(person)
    #expect(variable.build().contains("Alice"))
}

// MARK: - Message Components Tests

@Test func systemMessage() {
    let message = SystemMessage {
        "You are a helpful assistant."
    }
    #expect(message.build() == "System: You are a helpful assistant.\n")
}

@Test func userMessage() {
    let message = UserMessage {
        "What is the weather today?"
    }
    #expect(message.build() == "User: What is the weather today?\n")
}

@Test func assistantMessage() {
    let message = AssistantMessage {
        "The weather is sunny."
    }
    #expect(message.build() == "Assistant: The weather is sunny.\n")
}

@Test func messageWithMultipleComponents() {
    let message = SystemMessage {
        "You are a helpful assistant."
        "Be concise and accurate."
    }
    #expect(message.build() == "System: You are a helpful assistant.Be concise and accurate.\n")
}

// MARK: - Section Component Tests

@Test func sectionWithTitle() {
    let section = Section(title: "Instructions") {
        "Follow these steps"
    }
    #expect(section.build() == "\nINSTRUCTIONS:\nFollow these steps")
}

@Test func sectionWithoutTitle() {
    let section = Section {
        "Content without title"
    }
    #expect(section.build() == "\nContent without title")
}

@Test func sectionWithMultipleComponents() {
    let section = Section(title: "Tasks") {
        ListItem("Task 1")
        ListItem("Task 2")
    }
    #expect(section.build() == "\nTASKS:\n- Task 1\n- Task 2\n")
}

// MARK: - Conditional Component Tests

@Test func conditionalTrue() {
    let conditional = Conditional(true) {
        "This should appear"
    }
    #expect(conditional.build() == "This should appear")
}

@Test func conditionalFalse() {
    let conditional = Conditional(false) {
        "This should not appear"
    }
    #expect(conditional.build() == "")
}

@Test func conditionalWithElseTrue() {
    let conditional = Conditional(true,
        then: { "True branch" },
        else: { "False branch" }
    )
    #expect(conditional.build() == "True branch")
}

@Test func conditionalWithElseFalse() {
    let conditional = Conditional(false,
        then: { "True branch" },
        else: { "False branch" }
    )
    #expect(conditional.build() == "False branch")
}

// MARK: - ForEach Component Tests

@Test func forEachWithStrings() {
    let items = ["Apple", "Banana", "Cherry"]
    let loop = ForEach(items) { item in
        ListItem(item)
    }
    #expect(loop.build() == "- Apple\n- Banana\n- Cherry\n")
}

@Test func forEachWithEmptyArray() {
    let items: [String] = []
    let loop = ForEach(items) { item in
        ListItem(item)
    }
    #expect(loop.build() == "")
}

@Test func forEachWithSeparator() {
    let items = ["Swift", "Objective-C", "C++"]
    let loop = ForEach(items, separator: ", ") { item in
        Text(item)
    }
    #expect(loop.build() == "Swift, Objective-C, C++")
}

@Test func forEachWithNumbers() {
    let numbers = [1, 2, 3]
    let loop = ForEach(numbers) { number in
        Line("Number: \(number)")
    }
    #expect(loop.build() == "Number: 1\nNumber: 2\nNumber: 3\n")
}

// MARK: - Prompt Builder Integration Tests

@Test func simplePrompt() {
    let prompt = Prompt {
        "You are a helpful AI assistant."
        "Please respond to the following question:"
        "What is the capital of France?"
    }
    #expect(prompt == "You are a helpful AI assistant.Please respond to the following question:What is the capital of France?")
}

@Test func structuredConversation() {
    let prompt = Prompt {
        SystemMessage {
            "You are an expert Swift developer."
        }
        UserMessage {
            "How do I create a custom view in SwiftUI?"
        }
    }
    #expect(prompt == "System: You are an expert Swift developer.\nUser: How do I create a custom view in SwiftUI?\n")
}

@Test func promptWithVariables() {
    let userName = "Alice"
    let userAge = 25

    let prompt = Prompt {
        "Hello, \(userName)!"
        Line("I understand you are \(userAge) years old.")
        "How can I help you today?"
    }
    #expect(prompt.contains("Alice"))
    #expect(prompt.contains("25"))
}

@Test func promptWithListItems() {
    let prompt = Prompt {
        "Please help me with the following tasks:"
        ListItem("Review the code")
        ListItem("Write unit tests")
        ListItem("Update documentation")
    }
    #expect(prompt.contains("- Review the code\n"))
    #expect(prompt.contains("- Write unit tests\n"))
    #expect(prompt.contains("- Update documentation\n"))
}

@Test func promptWithConditionals() {
    let isUrgent = true
    let hasDeadline = false

    let prompt = Prompt {
        "Project Request"

        if isUrgent {
            Line("⚠️ URGENT: This request requires immediate attention")
        }

        if hasDeadline {
            "Deadline: Tomorrow"
        } else {
            "No specific deadline"
        }
    }
    #expect(prompt.contains("URGENT"))
    #expect(prompt.contains("No specific deadline"))
    #expect(!prompt.contains("Deadline: Tomorrow"))
}

@Test func promptWithLoops() {
    let features = ["Authentication", "Data persistence", "UI components"]

    let prompt = Prompt {
        "The app should include:"

        for feature in features {
            ListItem(feature)
        }

        EmptyLine()
        "Please provide implementation details for each feature."
    }
    #expect(prompt.contains("- Authentication\n"))
    #expect(prompt.contains("- Data persistence\n"))
    #expect(prompt.contains("- UI components\n"))
    #expect(prompt.contains("implementation details"))
}

@Test func complexPromptWithAllFeatures() {
    let userName = "Bob"
    let isAdmin = true
    let tasks = ["Deploy", "Monitor", "Report"]

    let prompt = Prompt {
        SystemMessage {
            "You are a project management assistant."
        }

        UserMessage {
            "Hello, my name is \(userName)."
        }

        Section(title: "User Status") {
            if isAdmin {
                Line("Role: Administrator")
                Line("Access Level: Full")
            } else {
                Line("Role: User")
                Line("Access Level: Limited")
            }
        }

        Section(title: "Tasks") {
            for task in tasks {
                ListItem(task)
            }
        }

        EmptyLine()
        "Please summarize my responsibilities."
    }

    #expect(prompt.contains("System: You are a project management assistant.\n"))
    #expect(prompt.contains("User: Hello, my name is Bob.\n"))
    #expect(prompt.contains("USER STATUS:"))
    #expect(prompt.contains("Role: Administrator"))
    #expect(prompt.contains("TASKS:"))
    #expect(prompt.contains("- Deploy\n"))
    #expect(prompt.contains("- Monitor\n"))
    #expect(prompt.contains("- Report\n"))
}

// MARK: - Component Group Tests

@Test func componentGroupBuilding() {
    let group = ComponentGroup(components: [
        Text("First"),
        Text(" Second"),
        Text(" Third")
    ])
    #expect(group.build() == "First Second Third")
}

@Test func componentGroupEmpty() {
    let group = ComponentGroup(components: [])
    #expect(group.build() == "")
}

// MARK: - Edge Cases

@Test func emptyPrompt() {
    let prompt = Prompt {
        Text("")
    }
    #expect(prompt == "")
}

@Test func nestedSections() {
    let prompt = Prompt {
        Section(title: "Outer") {
            "Outer content"
            Section(title: "Inner") {
                "Inner content"
            }
        }
    }
    #expect(prompt.contains("OUTER:"))
    #expect(prompt.contains("INNER:"))
}

@Test func multipleEmptyLines() {
    let prompt = Prompt {
        "Start"
        EmptyLine()
        EmptyLine()
        EmptyLine()
        "End"
    }
    #expect(prompt == "Start\n\n\nEnd")
}

@Test func forEachWithNestedComponents() {
    let items = ["A", "B"]
    let prompt = Prompt {
        ForEach(items) { item in
            Section(title: item) {
                ListItem("Item \(item)")
            }
        }
    }
    #expect(prompt.contains("A:"))
    #expect(prompt.contains("B:"))
    #expect(prompt.contains("- Item A\n"))
    #expect(prompt.contains("- Item B\n"))
}

#elseif canImport(XCTest)

// XCTest fallback for Swift versions without Testing framework
import XCTest
@testable import PromptBuilder

final class PromptBuilderTests: XCTestCase {

    // MARK: - Basic Components Tests

    func testTextComponent() {
        let text = Text("Hello, world!")
        XCTAssertEqual(text.build(), "Hello, world!")
    }

    func testLineComponent() {
        let line = Line("Hello, world!")
        XCTAssertEqual(line.build(), "Hello, world!\n")
    }

    func testListItemComponent() {
        let item = ListItem("First item")
        XCTAssertEqual(item.build(), "- First item\n")
    }

    func testEmptyLineComponent() {
        let empty = EmptyLine()
        XCTAssertEqual(empty.build(), "\n")
    }

    func testStringAsComponent() {
        let prompt = Prompt {
            "Hello, world!"
        }
        XCTAssertEqual(prompt, "Hello, world!")
    }

    // MARK: - Variable Component Tests

    func testVariableWithString() {
        let variable = Variable("test value")
        XCTAssertEqual(variable.build(), "test value")
    }

    func testVariableWithInt() {
        let variable = Variable(42)
        XCTAssertEqual(variable.build(), "42")
    }

    func testVariableWithCustomType() {
        struct Person {
            let name: String
        }
        let person = Person(name: "Alice")
        let variable = Variable(person)
        XCTAssertTrue(variable.build().contains("Alice"))
    }

    // MARK: - Message Components Tests

    func testSystemMessage() {
        let message = SystemMessage {
            "You are a helpful assistant."
        }
        XCTAssertEqual(message.build(), "System: You are a helpful assistant.\n")
    }

    func testUserMessage() {
        let message = UserMessage {
            "What is the weather today?"
        }
        XCTAssertEqual(message.build(), "User: What is the weather today?\n")
    }

    func testAssistantMessage() {
        let message = AssistantMessage {
            "The weather is sunny."
        }
        XCTAssertEqual(message.build(), "Assistant: The weather is sunny.\n")
    }

    func testMessageWithMultipleComponents() {
        let message = SystemMessage {
            "You are a helpful assistant."
            "Be concise and accurate."
        }
        XCTAssertEqual(message.build(), "System: You are a helpful assistant.Be concise and accurate.\n")
    }

    // MARK: - Section Component Tests

    func testSectionWithTitle() {
        let section = Section(title: "Instructions") {
            "Follow these steps"
        }
        XCTAssertEqual(section.build(), "\nINSTRUCTIONS:\nFollow these steps")
    }

    func testSectionWithoutTitle() {
        let section = Section {
            "Content without title"
        }
        XCTAssertEqual(section.build(), "\nContent without title")
    }

    func testSectionWithMultipleComponents() {
        let section = Section(title: "Tasks") {
            ListItem("Task 1")
            ListItem("Task 2")
        }
        XCTAssertEqual(section.build(), "\nTASKS:\n- Task 1\n- Task 2\n")
    }

    // MARK: - Conditional Component Tests

    func testConditionalTrue() {
        let conditional = Conditional(true) {
            "This should appear"
        }
        XCTAssertEqual(conditional.build(), "This should appear")
    }

    func testConditionalFalse() {
        let conditional = Conditional(false) {
            "This should not appear"
        }
        XCTAssertEqual(conditional.build(), "")
    }

    func testConditionalWithElseTrue() {
        let conditional = Conditional(true,
            then: { "True branch" },
            else: { "False branch" }
        )
        XCTAssertEqual(conditional.build(), "True branch")
    }

    func testConditionalWithElseFalse() {
        let conditional = Conditional(false,
            then: { "True branch" },
            else: { "False branch" }
        )
        XCTAssertEqual(conditional.build(), "False branch")
    }

    // MARK: - ForEach Component Tests

    func testForEachWithStrings() {
        let items = ["Apple", "Banana", "Cherry"]
        let loop = ForEach(items) { item in
            ListItem(item)
        }
        XCTAssertEqual(loop.build(), "- Apple\n- Banana\n- Cherry\n")
    }

    func testForEachWithEmptyArray() {
        let items: [String] = []
        let loop = ForEach(items) { item in
            ListItem(item)
        }
        XCTAssertEqual(loop.build(), "")
    }

    func testForEachWithSeparator() {
        let items = ["Swift", "Objective-C", "C++"]
        let loop = ForEach(items, separator: ", ") { item in
            Text(item)
        }
        XCTAssertEqual(loop.build(), "Swift, Objective-C, C++")
    }

    func testForEachWithNumbers() {
        let numbers = [1, 2, 3]
        let loop = ForEach(numbers) { number in
            Line("Number: \(number)")
        }
        XCTAssertEqual(loop.build(), "Number: 1\nNumber: 2\nNumber: 3\n")
    }

    // MARK: - Prompt Builder Integration Tests

    func testSimplePrompt() {
        let prompt = Prompt {
            "You are a helpful AI assistant."
            "Please respond to the following question:"
            "What is the capital of France?"
        }
        XCTAssertEqual(prompt, "You are a helpful AI assistant.Please respond to the following question:What is the capital of France?")
    }

    func testStructuredConversation() {
        let prompt = Prompt {
            SystemMessage {
                "You are an expert Swift developer."
            }
            UserMessage {
                "How do I create a custom view in SwiftUI?"
            }
        }
        XCTAssertEqual(prompt, "System: You are an expert Swift developer.\nUser: How do I create a custom view in SwiftUI?\n")
    }

    func testPromptWithVariables() {
        let userName = "Alice"
        let userAge = 25

        let prompt = Prompt {
            "Hello, \(userName)!"
            Line("I understand you are \(userAge) years old.")
            "How can I help you today?"
        }
        XCTAssertTrue(prompt.contains("Alice"))
        XCTAssertTrue(prompt.contains("25"))
    }

    func testPromptWithListItems() {
        let prompt = Prompt {
            "Please help me with the following tasks:"
            ListItem("Review the code")
            ListItem("Write unit tests")
            ListItem("Update documentation")
        }
        XCTAssertTrue(prompt.contains("- Review the code\n"))
        XCTAssertTrue(prompt.contains("- Write unit tests\n"))
        XCTAssertTrue(prompt.contains("- Update documentation\n"))
    }

    func testPromptWithConditionals() {
        let isUrgent = true
        let hasDeadline = false

        let prompt = Prompt {
            "Project Request"

            if isUrgent {
                Line("⚠️ URGENT: This request requires immediate attention")
            }

            if hasDeadline {
                "Deadline: Tomorrow"
            } else {
                "No specific deadline"
            }
        }
        XCTAssertTrue(prompt.contains("URGENT"))
        XCTAssertTrue(prompt.contains("No specific deadline"))
        XCTAssertFalse(prompt.contains("Deadline: Tomorrow"))
    }

    func testPromptWithLoops() {
        let features = ["Authentication", "Data persistence", "UI components"]

        let prompt = Prompt {
            "The app should include:"

            for feature in features {
                ListItem(feature)
            }

            EmptyLine()
            "Please provide implementation details for each feature."
        }
        XCTAssertTrue(prompt.contains("- Authentication\n"))
        XCTAssertTrue(prompt.contains("- Data persistence\n"))
        XCTAssertTrue(prompt.contains("- UI components\n"))
        XCTAssertTrue(prompt.contains("implementation details"))
    }

    func testComplexPromptWithAllFeatures() {
        let userName = "Bob"
        let isAdmin = true
        let tasks = ["Deploy", "Monitor", "Report"]

        let prompt = Prompt {
            SystemMessage {
                "You are a project management assistant."
            }

            UserMessage {
                "Hello, my name is \(userName)."
            }

            Section(title: "User Status") {
                if isAdmin {
                    Line("Role: Administrator")
                    Line("Access Level: Full")
                } else {
                    Line("Role: User")
                    Line("Access Level: Limited")
                }
            }

            Section(title: "Tasks") {
                for task in tasks {
                    ListItem(task)
                }
            }

            EmptyLine()
            "Please summarize my responsibilities."
        }

        XCTAssertTrue(prompt.contains("System: You are a project management assistant.\n"))
        XCTAssertTrue(prompt.contains("User: Hello, my name is Bob.\n"))
        XCTAssertTrue(prompt.contains("USER STATUS:"))
        XCTAssertTrue(prompt.contains("Role: Administrator"))
        XCTAssertTrue(prompt.contains("TASKS:"))
        XCTAssertTrue(prompt.contains("- Deploy\n"))
        XCTAssertTrue(prompt.contains("- Monitor\n"))
        XCTAssertTrue(prompt.contains("- Report\n"))
    }

    // MARK: - Component Group Tests

    func testComponentGroupBuilding() {
        let group = ComponentGroup(components: [
            Text("First"),
            Text(" Second"),
            Text(" Third")
        ])
        XCTAssertEqual(group.build(), "First Second Third")
    }

    func testComponentGroupEmpty() {
        let group = ComponentGroup(components: [])
        XCTAssertEqual(group.build(), "")
    }

    // MARK: - Edge Cases

    func testEmptyPrompt() {
        let prompt = Prompt {
            Text("")
        }
        XCTAssertEqual(prompt, "")
    }

    func testNestedSections() {
        let prompt = Prompt {
            Section(title: "Outer") {
                "Outer content"
                Section(title: "Inner") {
                    "Inner content"
                }
            }
        }
        XCTAssertTrue(prompt.contains("OUTER:"))
        XCTAssertTrue(prompt.contains("INNER:"))
    }

    func testMultipleEmptyLines() {
        let prompt = Prompt {
            "Start"
            EmptyLine()
            EmptyLine()
            EmptyLine()
            "End"
        }
        XCTAssertEqual(prompt, "Start\n\n\nEnd")
    }

    func testForEachWithNestedComponents() {
        let items = ["A", "B"]
        let prompt = Prompt {
            ForEach(items) { item in
                Section(title: item) {
                    ListItem("Item \(item)")
                }
            }
        }
        XCTAssertTrue(prompt.contains("A:"))
        XCTAssertTrue(prompt.contains("B:"))
        XCTAssertTrue(prompt.contains("- Item A\n"))
        XCTAssertTrue(prompt.contains("- Item B\n"))
    }
}

#endif
