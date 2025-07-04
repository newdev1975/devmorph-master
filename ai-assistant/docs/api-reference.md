# AI Assistant API Reference

## Overview

This document describes the internal APIs and interfaces used by the AI Assistant module.

## Library APIs

### Hardware Detection API (`lib/hardware-detector.sh`)

The hardware detection library provides functions for identifying system capabilities.

#### Functions

- `detect_os()`: Returns the operating system type (linux, macos, windows, unknown)
- `get_cpu_info()`: Outputs CPU core count and model information
- `get_memory_info()`: Outputs system RAM information
- `detect_gpu()`: Detects GPU type and VRAM, returns 0 if GPU detected, 1 otherwise
- `get_disk_info()`: Outputs available disk space information
- `is_suitable_for_local_ai()`: Checks if hardware is suitable for running local AI models, returns 0 if suitable, 1 otherwise
- `run_hardware_detection()`: Runs comprehensive hardware detection and outputs a full report

### Model Selection API (`lib/model-selector.sh`)

The model selection library chooses the optimal AI model based on hardware and availability.

#### Functions

- `select_best_model()`: Selects the best model based on hardware and availability, sets `SELECTED_MODEL_TYPE` and `SELECTED_MODEL_PROVIDER` global variables
- `prepare_model_environment()`: Prepares the selected model environment
- `get_cloud_api_endpoint(provider)`: Returns the API endpoint URL for the given cloud provider
- `get_local_api_endpoint(provider)`: Returns the local API endpoint URL for the given local provider
- `check_model_availability(model_type, model_provider)`: Checks if the specified model is available, returns 0 if available, 1 otherwise

### Context Management API (`lib/context-manager.sh`)

The context management library handles AI interaction context.

#### Functions

- `init_context_system()`: Initializes the context management system
- `create_context(context_name)`: Creates a new context with the given name
- `load_context([context_name])`: Loads a context by name (defaults to "default")
- `add_file_to_context(file_path)`: Adds a file to the current context
- `remove_file_from_context(file_path)`: Removes a file from the current context
- `set_context_workspace(workspace_path)`: Sets the workspace directory for the current context
- `add_conversation_to_context(role, content)`: Adds a conversation entry to the current context
- `list_contexts()`: Lists all available contexts
- `get_context_data()`: Returns the data for the current context
- `get_context_files()`: Returns a list of files in the current context
- `get_conversation_history()`: Returns the conversation history for the current context

### Session Management API (`lib/session-manager.sh`)

The session management library tracks AI sessions and usage statistics.

#### Functions

- `init_session_system()`: Initializes the session management system
- `create_session([session_name])`: Creates a new session with the given name (defaults to timestamp-based name)
- `load_session(session_id)`: Loads an existing session by ID
- `update_session_metadata(field, value)`: Updates a metadata field in the current session
- `increment_interaction_count()`: Increments the interaction counter for the current session
- `update_tokens_used(tokens)`: Updates the tokens used counter for the current session
- `end_session()`: Ends the current session
- `list_sessions()`: Lists all available sessions
- `get_session_data()`: Returns the data for the current session
- `get_current_session_id()`: Returns the ID of the current session
- `has_active_session()`: Checks if there's an active session, returns 0 if active, 1 otherwise
- `get_session_stats()`: Returns usage statistics for the current session

## Model Integration APIs

### Local AI API (`local-ai.sh`)

#### Functions

- `prepare_local_models(model_type, [size])`: Downloads and prepares local models
- `start_local_models()`: Starts local AI model services
- `stop_local_models()`: Stops local AI model services
- `check_model_status()`: Checks the status of local model services
- `send_local_request(model_type, prompt, [endpoint])`: Sends a request to a local model
- `run_local_ai(task_type, input_data)`: Runs a local AI task

### Cloud AI API (`cloud-ai.sh`)

#### Functions

- `send_qwen_code_request(prompt, [max_tokens])`: Sends a request to Qwen Code API
- `send_openai_request(prompt, [model], [max_tokens])`: Sends a request to OpenAI API
- `send_claude_request(prompt, [model], [max_tokens])`: Sends a request to Claude API
- `send_cloud_request(provider, prompt, [model], [max_tokens])`: Sends a request to the specified cloud provider
- `select_best_cloud_provider()`: Selects the best available cloud provider
- `run_cloud_ai(task_type, input_data, [model_preference])`: Runs a cloud AI task
- `check_cloud_config()`: Checks cloud provider configuration
- `test_cloud_connectivity([provider])`: Tests connectivity to cloud providers

## Model Management API (`model-health-check.sh`)

#### Functions

- `check_model_health(model_type, model_provider)`: Checks the health of a model service
- `check_local_model_health(provider)`: Checks the health of a local model
- `check_cloud_model_health(provider)`: Checks the health of a cloud model
- `run_health_checks()`: Runs health checks on all configured models
- `restart_unhealthy_models()`: Restarts unhealthy model services
- `monitor_model_resources(provider)`: Monitors resource usage for a provider
- `get_model_usage_stats()`: Gets model usage statistics
- `perform_model_maintenance()`: Performs model maintenance tasks

## Docker Management API (`ai-model-manager.sh`)

#### Functions

- `check_docker()`: Checks if Docker is available
- `check_docker_compose()`: Checks if Docker Compose is available
- `check_gpu()`: Checks for GPU availability
- `start_models()`: Starts AI model containers
- `stop_models()`: Stops AI model containers
- `restart_models()`: Restarts AI model containers
- `status_models()`: Checks the status of AI model containers
- `pull_images()`: Pulls latest AI model images
- `show_logs([service_name])`: Shows logs for AI model containers