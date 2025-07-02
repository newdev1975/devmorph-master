---

# 📋 Clarification: Core Modules vs Application Features

## 🏛️ Core Modules (Fundamentalne, uniwersalne)
Te moduły są częścią **rdzenia systemu** i są **niezbędne** dla każdej aplikacji CLI:

```
/core-modules/
├── logger/                 # System logowania
├── plugin-manager/         # Zarządzanie pluginami
├── config-manager/         # System konfiguracji
├── cli-parser/             # Parser argumentów CLI
├── error-handler/          # Scentralizowana obsługa błędów
├── documentation-engine/   # Silnik dokumentacji
├── test-runner/            # Uniwersalny runner testów
├── git-integrator/         # Integracja z Git
├── security-validator/     # Walidator bezpieczeństwa
└── di-container/           # Kontener DI
```

## 🔧 Core Validation Modules (Specyficzne dla jakości)
```
/core-validation/
├── plugin-validator/       # Walidacja pluginów
├── module-validator/       # Walidacja modułów
├── architecture-validator/ # Walidacja architektury (DDD, DI, SRP)
├── code-style-validator/   # Walidator stylu kodu
└── commit-validator/       # Walidator Conventional Commits
```

## 🛠️ Core Integration Modules
```
/core-integration/
├── plugin-creator/         # Kreator pluginów
├── module-integrator/      # Integrator modułów
├── plugin-integrator/      # Integrator pluginów
├── template-engine/        # Silnik szablonów
└── build-system/           # System budowy
```

## 🚀 Application Features (Specyficzne dla aplikacji)
Te funkcjonalności są **opcjonalne** i zależą od konkretnego zastosowania:

```
/features/
├── code-generator/         # Generator kodu (specyficzny dla Qwen-Coder)
├── tui-interface/          # Interfejs tekstowy
├── api-server/             # Serwer API
├── gui-interface/          # Interfejs graficzny
├── performance-analyzer/   # Analizator wydajności
├── ai-assistant/           # Asystent AI
├── project-templater/      # Tworzenie szablonów projektów
└── dependency-manager/     # Zarządzanie zależnościami
```

---

## 🎯 Kluczowa Różnica

### Core Modules:
- **Zawsze obecne** w każdej aplikacji CLI
- **Uniwersalne** - nie zależą od konkretnej domeny
- **Fundamentalne** - bez nich system nie działa
- **Wspólne** dla wszystkich aplikacji opartych na tym fundamencie

### Application Features:
- **Opcjonalne** - wybierane przez użytkownika
- **Specyficzne** - zależą od konkretnego zastosowania
- **Rozszerzające** - dodają funkcjonalność
- **Wymienne** - można je dodawać/usuwać

---

## 📊 Przykład: DevMorph AI Studio CLI

### Zawsze obecne (Core):
- Logger, Plugin Manager, Config Manager, CLI Parser, Error Handler

### Walidatory (Core Validation):
- Plugin Validator, Module Validator, Architecture Validator, Commit Validator

### Integratory (Core Integration):
- Plugin Creator, Module Integrator, Template Engine

### Specyficzne dla DevMorph AI Studio CLI (Features):
- Code Generator (generowanie kodu AI)
- TUI Interface (interfejs dla programisty)
- AI Assistant (asystent Qwen)
- Project Templater (szablony projektów CLI)

---

## 🧩 Architektura Logiczna

```
[USER]
   ↓
[CLI INTERFACE] (TUI/GUI/API)
   ↓
[FEATURE MODULES] (opcjonalne)
   ↓
[CORE MODULES] (fundamentalne)
   ↓
[KERNEL] (rdzeń systemu)
```

---
