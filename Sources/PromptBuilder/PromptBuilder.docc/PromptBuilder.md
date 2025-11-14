# ``swift-prompt-builder``

A declarative Swift library for building structured prompts using result builders.

## Overview

Swift Prompt Builder provides a SwiftUI-like declarative syntax for constructing text prompts. It's designed for creating complex, structured prompts for AI models, chatbots, or any text generation scenarios where maintainability and readability are important.

The library uses Swift's result builder feature to enable a natural, compositional API that feels familiar to SwiftUI developers while being purpose-built for text generation tasks.

### Key Features

- **Declarative Syntax**: Build prompts using a familiar result builder pattern
- **Type-Safe**: Leverage Swift's type system for compile-time safety
- **Sendable Support**: Full Swift Concurrency compatibility
- **Modular Components**: Mix and match components to build complex prompts
- **Control Flow**: Native support for conditionals, loops, and optionals

### Quick Start

Create a simple prompt using the ``Prompt(_:)`` function:

```swift
import PromptBuilder

let greeting = Prompt {
    "Hello, world!"
    "Welcome to Swift Prompt Builder."
}
```

Build structured conversations with message components:

```swift
let conversation = Prompt {
    SystemMessage {
        "You are a helpful assistant."
    }
    
    UserMessage {
        "What is Swift?"
    }
}
```

Use control flow to create dynamic prompts:

```swift
let tasks = ["Code review", "Testing", "Documentation"]

let prompt = Prompt {
    "Project tasks:"
    
    for task in tasks {
        ListItem(task)
    }
    
    EmptyLine()
    
    if tasks.count > 3 {
        "This is a complex project."
    }
}
```

## Topics

### Essentials

- ``Prompt(_:)``
- ``PromptComponent``
- ``PromptBuilder``

### Basic Components

- ``Text``
- ``Line``
- ``ListItem``
- ``EmptyLine``
- ``Variable``

### Message Components

- ``SystemMessage``
- ``UserMessage``
- ``AssistantMessage``

### Structural Components

- ``Section``
- ``Conditional``
- ``ForEach``
- ``ComponentGroup``
