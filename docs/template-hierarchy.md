# DevMorph Studio Template Hierarchy Documentation

This document explains the template inheritance system in DevMorph Studio, which follows a hierarchical approach to enable maximum reusability and maintainability.

## 🏗️ Hierarchical Structure

### Tier 1: Base Templates
Located in `templates/base/`, these provide the foundational structure that all other templates inherit from:

- `docker-compose.tpl` - Core docker-compose structure with networking and volume definitions
- `env.tpl` - Standard environment variables for all applications  
- `devcontainer.tpl` - Base development container configuration

### Tier 2: Service Templates
Located in `templates/services/`, these define individual infrastructure services that can be composed together:

- Database Services: `postgres.tpl`, `mysql.tpl`, `mongodb.tpl`
- Caching: `redis.tpl`
- Web Servers: `nginx.tpl`, `apache.tpl`, `caddy.tpl`, `traefik.tpl`
- CSS Processors: `scss.tpl`, `less.tpl`, `stylus.tpl`, `tailwind.tpl`, `bootstrap.tpl`, `bulma.tpl`, `materialize.tpl`
- Other Services: `elasticsearch.tpl`, `rabbitmq.tpl`, etc.

### Tier 3: Technology Templates
These inherit from base templates and add language-specific configurations:

- `nodejs.tpl` → builds on base templates + Node.js specific configs
- `php.tpl` → builds on base templates + PHP specific configs
- `python.tpl` → builds on base templates + Python specific configs
- `java.tpl` → builds on base templates + Java specific configs
- `dotnet.tpl` → builds on base templates + .NET specific configs
- `ruby.tpl` → builds on base templates + Ruby specific configs
- `go.tpl` → builds on base templates + Go specific configs
- `rust.tpl` → builds on base templates + Rust specific configs

### Tier 4: Framework Templates
These inherit from the appropriate technology template and add framework-specific configurations:

- `laravel.tpl` → extends `php.tpl` + Laravel specific services
- `express.tpl` → extends `nodejs.tpl` + Express.js specific services
- `django.tpl` → extends `python.tpl` + Django specific services
- `spring-boot.tpl` → extends `java.tpl` + Spring Boot specific services
- `react.tpl` → extends `nodejs.tpl` + React specific services
- `wordpress.tpl` → extends `php.tpl` + WordPress specific services

### Tier 5: Application Category Templates
These combine multiple services and frameworks for specific application types:

- `cms.tpl` → CMS applications
- `ecommerce.tpl` → E-commerce platforms
- `social.tpl` → Social media applications
- `business.tpl` → Business applications

### Tier 6: Application Type Templates
These focus on specific architectural patterns:

- `spa.tpl` → Single Page Applications
- `pwa.tpl` → Progressive Web Apps
- `api.tpl` → API-only services
- `static.tpl` → Static site generators

## 🔁 Inheritance Mechanism

The inheritance mechanism works as follows:

1. **Base Template Inheritance**: All templates start with the base template structure
2. **Service Composition**: Framework and application templates compose multiple service templates
3. **Environment Specialization**: Each tier can specialize environment variables
4. **Configuration Override**: Higher tiers can override lower tier configurations

## 🎨 Workspace Modes Integration

The template hierarchy also supports different workspace modes:

- `docker-compose.dev.yml` → optimized for development
- `docker-compose.prod.yml` → optimized for production
- `docker-compose.staging.yml` → staging environment
- `docker-compose.test.yml` → testing environment
- `docker-compose.design.yml` → design-focused workflow
- `docker-compose.mix.yml` → combined dev/design workflow

Each workspace mode can utilize any template type while applying environment-specific configurations.

## 🛠️ Implementation Guidelines

When creating new templates:
1. Always start with the appropriate base template
2. Follow the inheritance hierarchy
3. Use environment variables for configuration
4. Maintain consistent naming conventions
5. Document template-specific environment variables

This architecture ensures that changes at lower levels propagate to higher levels while maintaining the flexibility to customize at each level.