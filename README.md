# Swift Prompt Builder

A declarative Swift library for building structured prompts using a result builder pattern. Perfect for creating complex prompts for AI models, chatbots, or any text generation scenarios.

## Features

- **Declarative Syntax**: Use SwiftUI-like result builders to construct prompts
- **Modular Components**: Mix and match different prompt components
- **Conditional Logic**: Include content based on conditions
- **Loops and Arrays**: Iterate over data to generate dynamic content
- **Message Types**: Built-in support for system, user, and assistant messages
- **Type Safe**: Leverage Swift's type system for safer prompt construction
- **Sendable**: Full concurrency support with Sendable conformance

## Installation

### Swift Package Manager

Add this to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/jagreenwood/swift-prompt-builder.git", from: "0.1.0")
]
```

Or add it through Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version and add to your target

## Basic Usage

### Simple Text Prompt

```swift
import PromptBuilder

let prompt = Prompt {
    "You are a helpful AI assistant."
    "Please respond to the following question:"
    "What is the capital of France?"
}

print(prompt)
```

### Structured Messages

```swift
let conversation = Prompt {
    SystemMessage {
        "You are an expert Swift developer."
        "Provide concise and accurate answers."
    }

    UserMessage {
        "How do I create a custom view in SwiftUI?"
    }
}
```

### Using Variables

```swift
let userName = "Alice"
let userAge = 25

let personalizedPrompt = Prompt {
    "Hello, \(userName)!"
    "I understand you are \(userAge) years old."
    "How can I help you today?"
}
```

### Lists and Structure

```swift
let taskPrompt = Prompt {
    "Please help me with the following tasks:"

    ListItem("Review the code")
    ListItem("Write unit tests")
    ListItem("Update documentation")

    EmptyLine()

    "Priority: High"
}
```

### Conditional Content

```swift
let isUrgent = true
let hasDeadline = false

let requestPrompt = Prompt {
    "Project Request"

    if isUrgent {
        "⚠️ URGENT: This request requires immediate attention"
    }

    if hasDeadline {
        "Deadline: Tomorrow"
    } else {
        "No specific deadline"
    }
}
```

### Loops and Dynamic Content

```swift
let features = ["Authentication", "Data persistence", "UI components"]

let featurePrompt = Prompt {
    "The app should include:"

    for feature in features {
        ListItem(feature)
    }

    EmptyLine()
    "Please provide implementation details for each feature."
}
```

## Available Components

### Basic Components

- `Text()` - Plain text content
- `Line()` - Text with a newline
- `ListItem()` - Bulleted list item
- `EmptyLine()` - Blank line for spacing
- `Variable()` - Dynamic content injection

### Message Components

- `SystemMessage {}` - System-level instructions
- `UserMessage {}` - User input or questions
- `AssistantMessage {}` - AI assistant responses

### Structure Components

- `Section(title:) {}` - Titled sections
- `Conditional() {}` - Conditional content inclusion
- `ForEach() {}` - Loop over collections

## Requirements

- Swift 5.5+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Jeremy Greenwood
