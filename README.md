# DevMorph Studio - Full-Stack Unified Workspace

DevMorph Studio is an AI-powered Dev-Design Shell Framework that provides a comprehensive, modular approach for creating full-stack applications with Docker Compose. The platform supports multiple technologies, frameworks, and application types with a focus on the "Dev-Design" paradigm.

## 🎯 Core Philosophy

The DevMorph Studio follows the "Where the Code meets Design" principle, providing templates and tools that bridge development and design workflows. The system is built on:

- **Modularity**: Everything is pluggable and replaceable
- **Inheritance**: Templates build on each other following a hierarchy
- **Flexibility**: Support for multiple tech stacks and application types
- **Production Ready**: All templates include production, staging, and development configurations

## 🏗️ Template Hierarchy

### Base Templates
- `templates/base/docker-compose.tpl` - Foundation for all applications
- `templates/base/env.tpl` - Standard environment variables
- `templates/base/devcontainer.tpl` - Dev container configuration

### Service Templates
- `templates/services/*` - Infrastructure services (database, caching, web servers)
- CSS Processing Services (SCSS, LESS, Stylus, Tailwind, Bootstrap, Bulma, Materialize)

### Technology Templates
- `templates/nodejs.tpl` - Node.js applications
- `templates/php.tpl` - PHP applications
- `templates/python.tpl` - Python applications  
- `templates/java.tpl` - Java applications
- `templates/dotnet.tpl` - .NET applications
- `templates/ruby.tpl` - Ruby applications
- `templates/go.tpl` - Go applications
- `templates/rust.tpl` - Rust applications

### Framework Templates
- `templates/laravel.tpl` - Laravel (extends PHP)
- `templates/express.tpl` - Express.js (extends Node.js)
- `templates/django.tpl` - Django (extends Python)
- `templates/spring-boot.tpl` - Spring Boot (extends Java)
- `templates/react.tpl` - React (extends Node.js)
- `templates/wordpress.tpl` - WordPress (extends PHP)

### Application Category Templates
- `templates/cms.tpl` - Content Management Systems
- `templates/ecommerce.tpl` - E-commerce platforms
- `templates/social.tpl` - Social media applications
- `templates/business.tpl` - Business applications

### Application Type Templates
- `templates/spa.tpl` - Single Page Applications
- `templates/pwa.tpl` - Progressive Web Apps
- `templates/api.tpl` - API-only services
- `templates/static.tpl` - Static site generators

## 🚀 Usage

### Workspace Modes
The system supports multiple workspace modes:

- `docker-compose.dev.yml` - Development with hot-reload
- `docker-compose.prod.yml` - Production optimized
- `docker-compose.staging.yml` - Staging environment
- `docker-compose.test.yml` - Testing environment
- `docker-compose.design.yml` - Design-focused workflow
- `docker-compose.mix.yml` - Combined dev/design workflow

### Quick Start
1. Choose your technology stack template
2. Customize environment variables in `.env`
3. Run with your preferred workspace mode

## 🛠️ Supported Technologies

### Backend Languages
- Node.js, PHP, Python, Java, .NET, Ruby, Go, Rust

### Databases
- PostgreSQL, MySQL, MongoDB, Redis

### Web Servers
- Nginx, Apache, Caddy, Traefik

### CSS Processing
- SCSS/Sass, LESS, Stylus, Tailwind CSS, Bootstrap, Bulma, Materialize

### Frameworks & CMS
- Laravel, Express, Django, Spring Boot, React, WordPress, and more

## 📋 Application Types

The platform supports multiple application architectures:
- Traditional Web Applications
- API Services
- Static Sites (JAMstack)
- Progressive Web Apps (PWA)
- Single Page Applications (SPA)

## 🧩 Modularity & Extensibility

Each component is designed to be modular:
- Services can be mixed and matched
- Templates support inheritance
- Configuration is separated from logic
- Easy to extend with custom services

## 📄 License

DevMorph Studio - Where the Code meets Design
AI Powered Dev-Design Shell Framework Studio