# Workspace Manager Module

This module provides workspace management functionality for DevMorph AI
Studio, including creation, lifecycle management, and mode switching.

## Overview

The Workspace Manager allows users to create and manage development environments with different configurations based on their needs (development, production, testing, etc.).

## Commands

 - `devmorph workspace create` - Create a new workspace
 - `devmorph workspace start` - Start a workspace
 - `devmorph workspace stop` - Stop a workspace  
 - `devmorph workspace list` - List all workspaces
 - `devmorph workspace destroy` - Destroy a workspace
 - `devmorph workspace mode set` - Set workspace mode
 - `devmorph workspace mode show` - Show workspace mode
 
## Modes
 
 - **dev** - Development environment with hot-reload and debugging
 - **prod** - Production environment optimized and secure
 - **staging** - Staging environment for preview deployments
 - **test** - Testing environment for automated tests
 - **design** - Design environment with creative tools
 - **mix** - Hybrid environment combining dev and design tools