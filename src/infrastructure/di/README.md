# DI Container Module

Dependency Injection Container for DevMorph SRP Master

## Overview

This module provides a POSIX-compliant dependency injection container that integrates with the shell abstraction layer and follows the Onion/Domain-Driven Design architecture.

## Features

- Cross-platform service container
- Singleton, transient, and scoped lifetime management
- Automatic dependency resolution
- Circular dependency detection
- Comprehensive error handling
- Factory patterns support

## Files

- `Container.impl` - Main container implementation
- `ServiceRegistry.impl` - Service registration system
- `ServiceResolver.impl` - Service resolution with dependency injection
- `LifetimeManager.impl` - Lifetime management system
- `CircularDependencyDetector.impl` - Circular dependency detection
- `exceptions/ExceptionHandling.impl` - Error handling utilities
- `factories/ServiceFactory.impl` - Service factory patterns
- `utils/DIUtils.impl` - Utility functions

## Testing

Unit and integration tests are located in the `tests/` directory and use the BATS testing framework.

## Usage

See `docs/infrastructure/di-container.md` for comprehensive documentation and usage examples.