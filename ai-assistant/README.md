# AI Assistant Module Documentation

## Overview

The AI Assistant module provides a comprehensive set of tools for integrating with various AI models, both local and cloud-based. It includes functionality for code assistance, design generation, analysis, suggestions, and interactive chat.

## Architecture

The system is built with a modular architecture:

- **Core Libraries**: `lib/` contains reusable shell libraries
- **Model Management**: Scripts for managing local and cloud AI models
- **CLI Commands**: User-facing commands for interacting with AI
- **Configuration**: JSON configuration for model settings
- **Tests**: Unit, integration, and performance tests

## Core Components

### Libraries

- `lib/hardware-detector.sh`: Detects system hardware capabilities to determine optimal model selection
- `lib/model-selector.sh`: Selects the best AI model based on hardware and availability
- `lib/context-manager.sh`: Manages context for AI interactions (files, workspaces, conversation history)
- `lib/session-manager.sh`: Tracks AI sessions with metadata and usage statistics

### Model Integration

- `local-ai.sh`: Manages local AI model execution using Docker containers
- `cloud-ai.sh`: Handles cloud-based AI model requests using API calls
- `ai-model-manager.sh`: Controls Docker containers for local models
- `model-health-check.sh`: Monitors and manages AI model health

### CLI Commands

- `ai-code.sh`: Provides AI-powered code assistance
- `ai-design.sh`: Generates designs and images
- `ai-analyze.sh`: Performs code and system analysis
- `ai-suggest.sh`: Provides suggestions and recommendations
- `ai-chat.sh`: Enables interactive chat with AI

## Model Support

### Local Models

The system supports several local AI models via Docker:

- **Llama.cpp**: For text generation and code assistance
- **Stable Diffusion**: For image generation
- **Whisper**: For audio transcription

### Cloud Models

The system supports several cloud AI services:

- **Qwen Code**: For coding assistance
- **OpenAI**: For general AI tasks
- **Claude**: For conversational AI

## Hardware Detection

The system automatically detects hardware capabilities:

- CPU cores and architecture
- Memory (RAM) size
- GPU type and VRAM
- Available disk space

Based on this information, it selects the most appropriate AI model to use.

## Context Management

The system maintains context across AI interactions:

- **Files**: Relevant files can be added to context
- **Workspaces**: Project directories can be associated
- **Conversation History**: Maintains history for continuity
- **Session Tracking**: Tracks usage statistics

## Usage

### Basic Usage

```bash
# Code assistance
./ai-code.sh "optimize this database query"

# Design generation  
# ./ai-design.sh "a modern logo for a tech startup"

# Code analysis
./ai-analyze.sh -t security "review authentication system"

# Interactive chat
./ai-chat.sh
```

### Advanced Usage

```bash
# Use specific context and workspace
./ai-code.sh -c myproject -w ./src "refactor this function"

# Force cloud model usage
./ai-suggest.sh --model cloud "suggest improvements"

# Interactive chat with specific model
./ai-chat.sh --model local
```

## Configuration

Model configuration is stored in `config/ai-models.json`. API keys for cloud services should be set as environment variables:

```bash
export QWEN_CODE_API_KEY='your-key-here'
export OPENAI_API_KEY='your-key-here' 
export CLAUDE_API_KEY='your-key-here'
```

## Docker Integration

Local models run in Docker containers managed by `ai-model-manager.sh`:

```bash
# Start all model containers
./ai-model-manager.sh start

# Check status
./ai-model-manager.sh status

# Stop containers
./ai-model-manager.sh stop
```

## Requirements

- POSIX-compliant shell
- Docker (for local models)
- Docker Compose (for local models)
- curl (for API requests)
- jq (for JSON processing, recommended)

## Testing

The system includes comprehensive tests:

- Unit tests for individual libraries
- Integration tests for CLI commands
- Performance tests for core functionality

Run tests with BATS:

```bash
bats tests/unit/
bats tests/integration/
bats tests/performance/
```