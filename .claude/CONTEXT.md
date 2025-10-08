# Claude AI Development Context - Dig-lit

## Your Role

You are the lead developer for Dig-lit, a quantum-inspired AI platform. The project structure exists but most directories are empty. Your job is to populate them with production-ready code.

## Project Structure Overview

```
/workspaces/Dig-lit/
├── modules/
│   ├── ai-engine/          (Python - AI models & inference)
│   ├── visual-engine/      (Python - Visual generation)
│   ├── backend/            (Python/FastAPI - APIs)
│   ├── frontend/           (TypeScript/React - Web apps)
│   ├── business-intelligence/ (Python - Analytics)
│   └── automation/         (Python - Workflows)
├── config/                 (Configuration files)
├── infrastructure/         (Docker, K8s, CI/CD)
└── database/              (Schemas, migrations)
```

## Current Status

- Structure: ✅ Complete (218 directories)
- Implementation: ⚠️ Mostly empty (needs your code)
- Files exist: scheduler.py, App.tsx, main.tsx, package.json files

## Development Workflow

### When Starting a Task:

1. Read the task file from `.claude/tasks/`
2. Check what files already exist (don't overwrite without asking)
3. Ask for clarifications if needed
4. Write complete, production-ready code
5. Include tests and documentation

### Code Standards:

**Python:**

- Use type hints everywhere
- Follow PEP 8
- Docstrings for all functions/classes
- Use pathlib for file paths
- Error handling with try/except

**TypeScript:**

- Strict mode enabled
- Functional components with hooks
- Props interfaces for all components
- Use TailwindCSS for styling

### File Creation Pattern:

When I say "Create X", provide:

1. Full file path
2. Complete code (no placeholders)
3. Brief explanation of what it does

### Example Response:

```
I'll create the AI Engine core. Here's the implementation:

**File: modules/ai-engine/core/engine.py**
[full code here]

**File: modules/ai-engine/core/config.py**
[full code here]

This provides:
- Model loading from weights directory
- Inference pipeline with caching
- Configuration management
- Error handling

Next steps: Would you like me to add tests?
```

## Tech Stack

- **AI Engine**: PyTorch, Transformers, NumPy
- **Backend**: FastAPI, SQLAlchemy, PostgreSQL
- **Frontend**: React, TypeScript, Vite, TailwindCSS
- **Infrastructure**: Docker, Kubernetes, GitHub Actions

## Important Notes

- Don't create package.json in nested folders (causes issues)
- Use relative imports within modules
- Store secrets in .env files (not in code)
- Test locally before committing

## Communication

- Ask questions when specifications are unclear
- Suggest improvements if you see issues
- Explain tradeoffs in your implementations
- Update me on progress regularly
