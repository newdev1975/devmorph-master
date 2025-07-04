# AI Assistant Command Line Interface Guide

## Overview

The AI Assistant CLI provides several commands for interacting with AI models to assist with development, design, and analysis tasks.

## Commands

### ai-code.sh

AI-powered code assistance and generation.

#### Usage
```bash
./ai-code.sh [OPTIONS] <prompt>
```

#### Options
- `-c, --context NAME`: Use specific context (default: default)
- `-w, --workspace PATH`: Set workspace directory
- `-m, --model TYPE`: Model type: auto, local, cloud (default: auto)
- `-t, --temperature N`: Set temperature (0.0-1.0, default: 0.7)
- `-k, --tokens N`: Max tokens to generate (default: 2048)
- `-h, --help`: Show help message

#### Examples
```bash
# Basic code optimization
./ai-code.sh "optimize this database query"

# With workspace context
./ai-code.sh -c myproject -w ./src "refactor this function"

# Force cloud model
./ai-code.sh --model cloud "write unit tests for UserAuth module"
```

### ai-design.sh

AI-powered design and image generation.

#### Usage
```bash
./ai-design.sh [OPTIONS] <prompt>
```

#### Options
- `-c, --context NAME`: Use specific context (default: default)
- `-w, --workspace PATH`: Set workspace directory
- `-m, --model TYPE`: Model type: auto, local, cloud (default: auto)
- `-s, --size WxH`: Image size (default: 512x512)
- `-n, --number N`: Number of images to generate (default: 1)
- `-h, --help`: Show help message

#### Examples
```bash
# Basic image generation
./ai-design.sh "a futuristic cityscape at sunset"

# With branding context
./ai-design.sh -c branding -w ./designs "logo for tech startup"

# High-resolution image
./ai-design.sh --model cloud --size 1024x1024 "photorealistic mountain landscape"
```

### ai-analyze.sh

AI-powered code and system analysis.

#### Usage
```bash
./ai-analyze.sh [OPTIONS] <prompt>
```

#### Options
- `-c, --context NAME`: Use specific context (default: default)
- `-w, --workspace PATH`: Set workspace directory
- `-m, --model TYPE`: Model type: auto, local, cloud (default: auto)
- `-t, --type TYPE`: Analysis type: general, security, performance, architecture (default: general)
- `-h, --help`: Show help message

#### Examples
```bash
# Security analysis
./ai-analyze.sh "analyze this codebase for potential security issues"

# Performance review
./ai-analyze.sh -t performance -w ./my-project "review database queries"

# Architecture assessment
./ai-analyze.sh --model cloud --context architecture-review "assess microservices design"
```

### ai-suggest.sh

AI-powered suggestions and recommendations.

#### Usage
```bash
./ai-suggest.sh [OPTIONS] <prompt>
```

#### Options
- `-c, --context NAME`: Use specific context (default: default)
- `-w, --workspace PATH`: Set workspace directory
- `-m, --model TYPE`: Model type: auto, local, cloud (default: auto)
- `-t, --type TYPE`: Suggestion type: general, code, docs, tests, refactoring (default: general)
- `-h, --help`: Show help message

#### Examples
```bash
# Code improvements
./ai-suggest.sh "suggest improvements for this function"

# Refactoring ideas
./ai-suggest.sh -t refactoring -w ./src "recommend code structure improvements"

# Documentation suggestions
./ai-suggest.sh --model cloud --context docs "suggest README improvements"
```

### ai-chat.sh

Interactive AI chat.

#### Usage
```bash
./ai-chat.sh [OPTIONS] [prompt]
```

#### Options
- `-c, --context NAME`: Use specific context (default: default)
- `-l, --lines N`: Number of history lines to include (default: 50)
- `-m, --model TYPE`: Model type: auto, local, cloud (default: auto)
- `-t, --temperature N`: Set temperature (0.0-1.0, default: 0.7)
- `--clear`: Clear the current chat context
- `-h, --help`: Show help message

#### Examples
```bash
# Interactive chat session
./ai-chat.sh

# Single question
./ai-chat.sh "What's the best practice for error handling?"

# Cloud-based chat
./ai-chat.sh --model cloud "Explain quantum computing"
```

## Context Management

All commands support context management:

- **Default Context**: Uses "default" context if none specified
- **Named Contexts**: Use `-c` or `--context` to specify a named context
- **Workspace Integration**: Use `-w` or `--workspace` to associate a directory with the context
- **File Tracking**: Context remembers files that were relevant to the session

## Model Selection

The system automatically selects the best model based on:

1. **Hardware capabilities**: GPU VRAM, CPU cores, RAM
2. **Model availability**: What models are configured and running
3. **User preference**: Explicit model choice with `--model` option
4. **Task appropriateness**: Matching model type to task

## Environment Variables

### Cloud API Keys
```bash
export QWEN_CODE_API_KEY='your-qwen-api-key'
export OPENAI_API_KEY='your-openai-api-key'
export CLAUDE_API_KEY='your-claude-api-key'
```

### Local Model Configuration
```bash
export MODEL_PATH='/path/to/local/models'  # For Llama models
export SD_MODELS_PATH='/path/to/sd-models'  # For Stable Diffusion models
export WHISPER_MODELS_PATH='/path/to/whisper-models'  # For Whisper models
export SD_OUTPUT_PATH='/path/for/sd-output'  # Where generated images are saved
```

## Performance Considerations

- Local models require significant computing resources
- Cloud models require API keys and network connectivity
- Large contexts may impact response times
- Consider using specific contexts for different projects